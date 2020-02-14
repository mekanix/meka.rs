Title: FreeBSD Cloud and DevOps 2
Date: 2017-04-04 12:17
Tags: freebsd, cloud, devops, cbsd, jail
Author: meka


So you have all the pieces installed and configured. Let's do something on top
of that. I don't like Vagrant, now that CBSD and Jails are around, but it's
perfect for DevOps jobs. I remember a friend of mine using Makefile for DevOps,
even if under it is Docker or Vagrant. It's small, portable and available on
every OS worth mentioning. Nice way to keep everything low on resource usage.

So, let's say we want to have at least 2 targets: up and setup. Setup would set
up config files, where up would do the actual job. For example:

```Makefile
PROJECT=myproj

up: setup
	@sudo cbsd jstart ${PROJECT} || true

setup:
	@sed -e "s:PROJECT:${PROJECT}:g" provision/inventory.tpl >provision/inventory
	@sed -e "s:PROJECT:${PROJECT}:g" provision/group_vars/all.tpl >provision/group_vars/all
	@sed -e "s:PROJECT:${PROJECT}:g" provision/localhost.yml.tpl >provision/localhost.yml
	@sed -e "s:PROJECT:${PROJECT}:g" provision/site.yml.tpl >provision/site.yml
	@sudo cbsd jcreate jconf=${PWD}/cbsd.conf || true
	@sudo sh -c 'sed -e "s:PWD:${PWD}:g" -e "s:PROJECT:${PROJECT}:g" fstab.conf >/cbsd/jails-fstab/fstab.${PROJECT}'
```

You can see that `up` target is using cbsd.conf and fstab.conf. You can generate
cbsd.conf with `cbsd jconstruct-tui`, like usual, just choose not to start it
once you configure it and CBSD will save the config in temporary file you can
use as a template. The fstab.conf is simple:

```sh
/cbsd/jails-data/PROJECT-data/etc /etc nullfs rw 0 0
/cbsd/jails-data/PROJECT-data/root /root nullfs rw 0 0
/cbsd/jails-data/PROJECT-data/tmp /tmp nullfs rw 0 0
/cbsd/jails-data/PROJECT-data/usr/home /usr/home nullfs rw 0 0
/cbsd/jails-data/PROJECT-data/usr/local /usr/local nullfs rw 0 0
/cbsd/jails-data/PROJECT-data/usr/compat /usr/compat nullfs rw 0 0
/cbsd/jails-data/PROJECT-data/var /var nullfs rw 0 0
PWD /usr/home/devel/workdir nullfs rw 0 0
```

One nice thing Vagrant has is it will provision your VM if it has provisioner
configured if it's the first time you're starting that VM. Let's add that:

```Makefile
up: setup
	@sudo cbsd jcreate jconf=${PWD}/cbsd.conf || true
.if !exists(.provisioned)
	@${MAKE} ${MAKEFLAGS} provision
.endif

provision:
	@sudo ansible-playbook -i provision/inventory provision/site.yml
	@touch .provisioned
```

Instead of `vagrant ssh` I added `make login`:

```Makefile
login: up
	@sudo cbsd jlogin ${PROJECT}
```

Finally, there are tear down targets, as well:

```Makefile
down: setup
	@sudo cbsd jstop ${PROJECT} || true
	@sudo ansible-playbook -i provision/inventory provision/teardown.yml

destroy: down
	@rm -f provision/inventory provision/site.yml provision/group_vars/all .provisioned
	@sudo cbsd jremove ${PROJECT}
```

All that's left now is to write Ansible playbook, but I'll leave that for some
other post.
