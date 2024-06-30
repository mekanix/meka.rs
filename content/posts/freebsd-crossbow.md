+++
title = 'FreeBSD Crossbow'
date = 2020-02-18T17:48:00
tags = ['freebsd']
+++


Once I started learning about containers and surrounding technologies, I heard
about Solaris Zones and Crossbow. In short, zones are containers, like jails,
and crossbow is something like a vnet. They say it's way more flexible and
powerful. One of the things it can do is prevent you from setting up static IP.
I thought that's pretty important thing and I wanted to have that. With
CBSD/Reggae I'm a little closer to saying "we have it". Reggae sets up a jail
named `cbsd` and inside it `/dev/pf` and DHCP server are configured in a very
special way. Because DHCP process is running as dhcp user, and that user can
not run `pfctl`, unless `/dev/pf` owning group is the same as DHCP process
group. Luckily, devfs.rules allows one set of rules for host and other set for
the jail. That means `/dev/pf` on host is owned by `root:root` while it's owned
by `root:unbound` inside the jail and mode is 660. Of course, DHCP runs under
group unbound. The reason is that unbound files from host are nullfs mounted
inside the jail. That way DHCP can edit unbound zones and add leased addresses
to PF table. On host, that PF table is used to configure NAT, so basically
allowing jails to reach Internet.

Let's face it. What I just described is nowhere near to Solaris crossbow, but
it's the closest I can get.
