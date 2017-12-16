Title: CBSD Reggae
Date: 2017-11-20 03:00
Tags: cbsd, freebsd, reggae, jail, ansible, devops
Author: meka


If you didn't get it by now, I'm huge CBSD fan. Actually, I'm CBSD developer
now. :o) One of the things I play with is Reggae, and some people asked me to
describe it and make a demo. So here goes an explanation why I created it, how
to use it and what are my plans for it in the future.

As CBSD is used for almost everything in Reggae, I won't discuss jails much as
they just work. So, besides jails, there are the topics I tried to cover with
Reggae:

* network and pf being static
* environment for bhyve VMs
* ansible provisioning
* development envrionemnt

Let me explain in a bit more detail. If you use CBSD as Oleg (lead developer)
likes it, it will do all the magic for you: configure bridge interface for VMs,
dynamically change PF rules when jails go up and so on. While this is
absolutely great feature, I know bunch of admins that would like to try CBSD
but don't like other software to alter their firewall rules (me included).
To automate the process of CBSD initialization with PF rules that don't change
and interfaces that are fixed (except tap and epair), I created command
`reggae init`. You can think of it as a test: it creates static config for
CBSD network so you can test if everything is working as you would like it. As
script grew, it became obvious to me that it can also be used to initialize
the server, not just test weird CBSD config and such. Network interfaces are
configured only because you have to NAT using interface names so those had to
be static as much as possible. I like the setup where jails are on lo1 and
virtual machines on bridge1. In /etc/pf.conf that's


```
jail_if = "lo1"
bridge_if = "bridge1"
nat on $ext_if from { ($jail_if:network), ($bridge_if:network) } to any -> ($ext_if)
```

So that's basically use case for the static network and how I tried to solve
it. I'm sure there are better ways to do it, but I wanted to create proof of
concept that we can comment.

As for VMs you need DHCP server to make it easier to work with, `reggae init`
will also setup two jails: dhcp and resolver. DHCP will lease IPs to VMs and
register them in DNS (resolver). What you'll notice is that only jail on
bridge1 is DHCP, and that's because it has to be on the same bridge as the VMs.
Also, DHCP server is ISC's Kea which has control socket file you can use to get
statistics and to reconfigure/reload Kea. I still didn't poke that socket, but
I hope that in the future it will provide enough stats that CBSD can use it
internally. Having resolver working, jails registration was straight forward:
master_poststart.d / master_prestop.d hooks that use nsupdate and RNDC key to
add/delete jail's IP to/from the zone. So now Reggae has two zones, my.domain
and vm.my.domain, as IPs assigned to jails and VMs are from different IP ranges
and I want to be clear is it a jail or VM just from looking at the name.

For Ansible to provision jails you have to use jail connection instead ssh.
Also, as Ansible expects python binary to be installed in /usr/bin, you have
to tell Ansible where python is on FreeBSD machines. So this is how the
inventory of one jail looks like:

```
jail1 ansible_connection=jail ansible_python_interpreter='"/usr/bin/env python"'
```

To make it easier for me to run Ansible on a jail, I created some Makefiles to
help me with common tasks. If you create hierarchy in your repo the way Reggae
expects it, you can "just write Ansible playbook" and it will be applied to your
jail with one `make`. I could use a shell script for that, too, but I wanted to
leave room for parallelism in the future.

To be able to reach your jail with Ansible once it's on the server, Reggae will
create `provision` user, give it sudo priviledges and add public key to it's
ssh. What it does is
`cp ~/.ssh/id_rsa.pub <jail-data>/home/provision/.ssh/authorized_keys`. It is a
bit hardcoded, but it will get better support in the future. The idea is to use
SSH's ProxyCommand to make your host jump box to jail. As Ansible knows how to
use jump box, you can provision or update your jails on the server.

To make all this possible, I created extra files like jail profile, skel, etc,
but there is also script which switches your DNS entry in /etc/resolv.conf from
the one DHCP provided (or you entered, if you use static IP) to the resolver
(jail where BIND9 is running), there are hooks for (de)registering jails, ...
What I'm also trying to achieve is to have my dev environment be exactly the
same (yeah, right, like that's possible) as my production. Reggae also has
development mode, in which it will mount your resository's directory on host to
/usr/src inside jail, create devel user with same UID:GID inside jail that user
running make has on the host has and it adds one more target, so when you run
`make && make devel` on yet uninitialized repository, it will provision it if
needed, run `/usr/src/bin/init.sh` and `/usr/src/bin/devel.sh`, so by
implementing those scripts you choose what happens on `make devel`.

Some examples of repos using Reggae:

* [Tilda Center website](https://github.com/tilda-center/website) (development
  mode example)
* [EMail service](https://github.com/mekanix/jail-mail) (Ansible example)

What I'd like to have in the future is much of this work merged into CBSD on
one way or another. This is what makes my development experience nicer, and as
such I'd like it to be less hackish at some parts. Sometimes, it's hackish
because of a CBSD bug, sometimes because I can't think of a better solution at
the time. As I use it for testing CBSD in "uncharted theritories", I like being
able to find bugs that wouldn't pop up otherwise. Also, as I'd like to use CBSD
in every situation I can think of, hence making dev env as close to production
as possible, some extra tools or CBSD features are needed and Reggae is one of
them, at least for me. The parts that proove to be useful to other people will
probably go into CBSD or some more official CBSD repository.
