Title: FreeBSD Cloud and DevOps 3
Date: 2017-10-01 12:34
Slug: freebsd-cloud-and-devops-3
Tags: freebsd, cloud, devops, cbsd, jail, consul
Author: meka


By now you know [how to manage jails with Makefile](/blog/2017/04/04/freebsd-cloud-and-devops-2/).
It's nice, but I took it a bit further this past few months. I realized that
Makefile can effectively replace Vagrant, so I created program called
[Reggae](https://github.com/mekanix/reggae): REGister Globaly Access Everywhere.
In short it consists of few scripts that (de)register jail in/from
[Consul](https://consul.io). As Consul acts as DNS, too, that means that when
your jail is up, other jails using Consul as DNS will know about it. Also,
Consul can be used for other things, but it's a different topic.

From the last blog post in this series you know how to use Makefile for these
tasks, but I'll run through some of the Makefiles from my project. There are 3
.mk files in Reggae:

* project.mk
* service.mk
* ansible.mk

So let me explain how it works on the example of the first project I used it
with: mail server. If you look at the mail as a project, it consists of few
services like ldap, webmail, mail (dovecot + postfix) and so on. I have
mail/Makefile which looks like this:

```Makefile
REGGAE_PATH = /usr/local/share/reggae
SERVICES = letsencrypt https://github.com/mekanix/jail-letsencrypt \
           ldap https://github.com/mekanix/jail-ldap \
           mail https://github.com/mekanix/jail-mail \
           jabber https://github.com/mekanix/jail-jabber \
           webmail https://github.com/mekanix/jail-webmail \
           web https://github.com/mekanix/jail-web \
           webconsul https://github.com/mekanix/jail-webconsul
DOMAIN=lust4trust.com

.include <${REGGAE_PATH}/mk/project.mk>
```

Yes, that's the whole file! The core of the Reggae is SERVICES in project.mk, so
let's see how it deals with it:

```Makefile
up: fetch setup
.if defined(service)
	@echo "=== ${service} ==="
	@${MAKE} ${MAKEFLAGS} -C services/${service} up
.else
.for service url in ${SERVICES}
	@echo "=== ${service} ==="
	@${MAKE} ${MAKEFLAGS} -C services/${service} up
.endfor
.endif
```

Lets break it down. First, `up` target depends on `fetch` and `setup`. Once
everything needed is downloaded and initialized, one of the two `if` branches
will be triggered. You can run it with `make up` or `make service=ldap up`.
Former runs `up` on all services (or jails in our case) and later get's only
ldap jail up. So the if is there to see if `service=<something>` is present on the
command line. If it's not, biggest problem for Reggae starts. That for loop is
where I lost most time figuring out how to have something I would call "list of
tuples" in Python. After a lot of experimenting, I realized that if I use
`service` and `url` as indexes in the same loop, it will do what I want. With
`down` target you have to do it in reverse, as some jails might depend on other
jails (for nullfs mount, perheps?). As `SERVICES` is array, not array of pairs,
you have to reverse the indexes, too: `url` and `service` in for loop.

```Makefile
down: setup
.if defined(service)
	@${MAKE} ${MAKEFLAGS} -C services/${service} down
.else
.for url service in ${SERVICES:[-1..1]}
	@${MAKE} ${MAKEFLAGS} -C services/${service} down
.endfor
.endif
```

Service uses all the same Makefile tricks, so let me just show how I provision
the jails. I implemented ansible.mk as an example, but Reggae is not Ansible
centric. First thing is to mark the default target to run:

```Makefile
.MAIN: up
```

This way it doesn't matter which target is first, `up` will be triggered if you
just type `make`. This also solves the problem of adding targets wherever you
like thus extending what can be done with your project. So let's look at how
provisioning works.

```Makefile
provision:
	@touch .provisioned
.if target(do_provision)
	@${MAKE} ${MAKEFLAGS} do_provision
.endif
```

This is in `service.mk` in Reggae. If you defined `do_provision` or included
ansible.mk from Reggae, provision will run it. As a matter of fact, this is how
ldap service Makefile looks like:

```Makefile
SERVICE = ldap
REGGAE_PATH = /usr/local/share/reggae
CUSTOM_TEMPLATES = templates

.include <${REGGAE_PATH}/mk/ansible.mk>
.include <${REGGAE_PATH}/mk/service.mk>
```

Including `ansible.mk` before `service.mk` ensures that `do_provision` is
defined when `provision` target from service.mk is parsed. Also, `.MAIN` will
ensure that running just `make` doesn't run the first target from ansible.mk.

If you need to mount something extra in your jail, you can define `EXTRA_FSTAB`
with the value of path to fstab containing extra mounts. Also, in order for
provision to work, some files had to be generated from templates, so this is the
directory hierarchy you need in your service repo:

* templates/site.yml.tpl
* playbook/group_vars
* playbook/inventory
* playbook/roles

You should know what those are if you ever used Ansible. Also, playbook
directories are the ones where Reggae will either generate some files (that
should be in .gitignore) or expect other files to be.

The last piece is registering with Consul. So, this is how I configured my
/etc/rc.conf.d/consul:

```sh
consul_enable="YES"
consul_args="-bind=127.0.2.1 -client=127.0.2.1 -recursor=8.8.8.8 -ui -server -bootstrap"
```

You can run Consul in jail, too. As a matter of fact, I do and it's IP is
special: 127.0.2.1. If you do that, Reggae will just work with Consul. In some
of the future posts I'll explain how you can use Ansible with Consul to
provision your jails. If you're inpatient, you can check out my
[mail project](https://github.com/mekanix/mail).
