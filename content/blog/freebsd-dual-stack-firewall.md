Title: FreeBSD Dual Stack Firewall
Date: 2022-08-16 11:11:35
Tags: freebsd, network, ipv4, ipv6, firewall, pf
Author: meka


The idea is very simple: everything works. But what is "everything" in this
case? I want my host and jails to have IPv4 and IPv6 address, register those
addresses in DNS and all to be accessible in the network and via Internet. To
make my life easier, I programmed [Reggae](https://github.com/cbsd/reggae) to
initialize rtadvd, jail with isc-dhcpd for IPv4 and IPv6 and DNS, pf with the
base configuration.

[TOC]

## Host

If there were no jails, the configuration would be simple: just use dhcpcd for
everything. There's not even need for some special firewall rules. To do that,
you need to run:

```sh
pkg install dhcpcd
echo 'dhclient_program=/usr/local/sbin/dhcpcd' >/etc/rc.conf.d/network
```

On next reboot or netif start all your DHCP ifaces will use dhcpcd and it will
configure DHCPv4, SLAAC and DHCPv6. Admitedly you will have two IPv6 addresses:
one SLAAC configured and one acquired through DHCPv6. The DHCP addresses will
be registered in DNS. That's basically it.


## Jail

In the jail itself it is the same as host: install dhcpcd and use it and DHCP
addresses are registered in DNS. If all you need is some kind of dual stack,
that's it, but if you need it on a server with jails, stuff gets a little bit
more complex. First, to achieve that host and jails get the address from the
same router, you need to bridge your physical interface and epairs.

```sh
cloned_interfaces="bridge0"
ifconfig_bridge0="addm igb0"
ifconfig_bridge0_ipv6="inet6 fd10:6c79:8ae5:8b91::5 -ifdisabled auto_linklocal"
```

The example uses "private IP range" in IPv4 terms, or unique local addresses as
IPv6 terminology defines them. There are two main problems with this setup:
DHCPv6 will not work and firewall will do too much. For DHCPv6 the reason it
doesn't work is that you have to allow dhcpv6-client messages to arrive. You
didn't need it for host-only setup, but to allow those messages to reach jails,
you need.

```
pass in quick inet6 proto udp from fe80::/10 port dhcpv6-server to fe80::/10 port dhcpv6-client
```

When you put egress interface (igb0 in my case) into bridge, it will see all
traffic for jails, too, so you have to allow packets which are not destined to
the host. To achieve that, pf offers <self>.

```
block in log from any to <self>
```

That way you are filtering everything for the host, but leave jail traffic
alone.


## Router

Maybe the easiest thing to do is converting Reggae setup into your router. All
you need to do is add physical interfaces like re1 and wlan0, to your bridge
and that's it. As all services inside network jail (the one with DHCP and DNS)
are listening on epair which is part of bridge, no other actions is needed.


## Reggae

Reggae will initialize your network, services and network jail in dual stack
mode. You can disable IP version by setting `USE_IPV4=no` or `USE_IPV6=no`, but
it will issue an error if you disable both. It will also write /etc/pf.conf if
one doesn't already exist and setup local_unbound, so you should be all set
after initializing Reggae the usual way.
