+++
title = 'FreeBSD Dual Stack Jails'
date = 2022-01-22T09:35:00
tags = ['freebsd', 'network', 'ipv4', 'ipv6', 'jail']
+++


There are 3 ways to have IPv6 in VNET jails that I'm going to describe. In terms
of IPv4, those would be:

* private address
* public address
* public address behind router

Private addresses in IPv6 world are called "unique local", and they start with
"fd" in hexadecimal notation. Please note that there are also site-local
addresses, but they are deprecated. Something like a MAC address is called "link
local address" and they start with "fe80" in hex. In this example, all addresses
starting with 2001 are global or in IPv4 notation, they are public. These are
not the only types of addresses, nor addresses starting with 2001 are the only
global ones. I'm just trying to keep it simple by narrowing it down to 3 types.


## Jail Setup

As CBSD renames jail's end of epair to eth0 writing rules/config is simplified.
In all jails the setup of /etc/rc.conf is:

```ini
ifconfig_eth0_ipv6="inet6 -ifdisabled accept_rtadv auto_linklocal"
rtsold_enable="YES"
```

CBSD will run DHCP client before running init, so that part is taken care of if
you choose REALDHCP as address assigning method.


## Unique Local Addresses

I use this setup for development as I don't want everything I do to be public
all the time. The principles are the same as with IPv4: assign jails private
addresses and then NAT them to the world. The relevant portion of /etc/rc.conf
is:

```ini
ifconfig_re0="DHCP"
ifconfig_re0_ipv6="inet6 -ifdisabled auto_linklocal accept_rtadv"
ipv6_gateway_enable="YES"
ipv6_defaultrouter="fe80::5a9c:fcff:fe10:6c2c%re0"
rtsold_enable="YES"

# CBSD
ifconfig_bridge0_name="cbsd0"
ifconfig_cbsd0="inet 172.16.0.254 netmask 255.255.255.0 description lagg0"
ifconfig_cbsd0_alias0="inet 172.16.1.254 netmask 255.255.255.0"
ifconfig_cbsd0_ipv6="inet6 fd10:6c79:8ae5:8b91::1 -ifdisabled auto_linklocal"
```

As I use CBSD and Reggae, I like to create dedicated bridge interface for it
and rename it so it's easier to tell what is what. I also have two IPv4 ranges:
one for DHCP assigned addresses and one for CBSD generated ones. For IPv6 I have
one address from the same range jails get their addresses. The configuration of
/etc/rtadvd.conf:

```ini
cbsd0:addr="fd10:6c79:8ae5:8b91::"
```

For NAT /etc/pf.conf is:

```md
# Macros and tables
ext_if = "lagg0"
table <cbsd> persist

# Options
set block-policy drop
set skip on lo0

# Normalization
scrub in all

# NAT
rdr-anchor "cbsd/*" on $ext_if
nat on $ext_if inet from <cbsd> to any -> ($ext_if)
nat on $ext_if inet6 from cbsd0:network to any -> ($ext_if:0)

# Quick rules
antispoof quick log for ($ext_if)

# Rules
block in log on $ext_if
pass out
pass proto tcp to any port ssh
pass proto { icmp, igmp, icmp6 }
```

There is a bit more than a bare minimum, but the important lines are those
starting with "nat". First rule is for IPv4 and it will NAT for all addresses
CBSD/Reggae puts in <cbsd> table. Second rule is for IPv6 and it is important
to use $ext_if:0 not just $ext_if because it will otherwise try to NAT using
all IPv6 addresses. In this case it would use the proper address as well as
link-local one.


## Global Unicast Address

This setup should be almost the same as the previous one. Keep in mind that in
the following setup re0 and cbsd0 must use same prefix, or in IPv4 terms: they
have to be in the same network. In practice, that means that both interfaces
must have IPv6 address which starts with `2001:aaaa:bbbb:cccc:`. Equally
important is to not add re0 to cbsd0 bridge as that would make local DHCP server
running in a jail leak out through re0 towards the rest of the physical network.

/etc/rc.conf:

```ini
ifconfig_re0="DHCP"
ifconfig_re0_ipv6="inet6 -ifdisabled auto_linklocal accept_rtadv"
ipv6_gateway_enable="YES"
ipv6_defaultrouter="fe80::5a9c:fcff:fe10:6c2c%re0"
rtsold_enable="YES"

# CBSD
ifconfig_bridge0_name="cbsd0"
ifconfig_cbsd0="inet 172.16.0.254 netmask 255.255.255.0 description lagg0"
ifconfig_cbsd0_alias0="inet 172.16.1.254 netmask 255.255.255.0"
ifconfig_cbsd0_ipv6="inet6 2001:aaaa:bbbb:cccc::1 -ifdisabled auto_linklocal"
```

/etc/rtadvd.conf:

```ini
cbsd0:addr="2001:aaaa:bbbb:cccc::"
```

/etc/pf.conf:

```md
# Macros and tables
ext_if = "lagg0"
table <cbsd> persist

# Options
set block-policy drop
set skip on lo0

# Normalization
scrub in all

# NAT
rdr-anchor "cbsd/*" on $ext_if
nat on $ext_if inet from <cbsd> to any -> ($ext_if)

# Quick rules
antispoof quick log for ($ext_if)

# Rules
block in log on $ext_if
pass out
pass proto tcp to any port ssh
pass proto { icmp, igmp, icmp6 }
```


## Global Unicast Address Behind Router

This setup is mostly for the server behind a router. The idea is to put all
physical (in this case one) and virtual (in this case epair interfaces) into
the same bridge. Bridge acts like a switch, so the network will behave like we
somehow plugged all physical and virtual interfaces into the same switch.
In practice it means that DHCP and rtadv/rtsol packets will got to/from the
router, directly. As it is a server, all configuration is static, so there's
no rtsold/rtadvd present.

/etc/rc.conf:

```ini
ifconfig_igb0="inet 192.168.111.201 netmask 255.255.255.0"
ifconfig_igb0_ipv6="inet6 2001:aaaa:bbbb:cccc::4 -ifdisabled auto_linklocal"
ipv6_defaultrouter="fe80::5a9c:fcff:fe10:6c2c%igb0"
defaultrouter="192.168.111.254"

# CBSD
cloned_interfaces="bridge0"
ifconfig_bridge0_name="cbsd0"
ifconfig_cbsd0="description igb0 addm igb0"
```

/etc/pf.conf:

```md
# Macros and tables
ext_if = "igb0"
dhcp_ports = "{ bootps, bootpc }"
table <cbsd> persist

# Options
set block-policy drop
set skip on lo0

# Normalization
scrub in all

# Rules
block in log on $ext_if
pass out
pass in from <cbsd> to any
pass in on $ext_if from any to $ext_if:network
pass proto tcp to any port ssh
pass proto { icmp, igmp, icmp6 }
pass in proto udp from any to any port $dhcp_ports
```

Note that in this setup NAT and antispoof are missing while it's essential to
have `pass in on $ext_if from any to $ext_if:network`. NAT is not needed as
router will do it in this setup and antispoof is not applicable here because it
practically says "any packet with source address from igb0 network coming from
interface other than igb0 should be blocked". That's the problem because VNET
jails will have epair interfaces using the same address range and antispoof
would block those packets as well because they physically pass through igb0 and
are visible. The extra `pass` rule is for the same reason.

[Previous](/blog/2022/01/15/freebsd-dual-stack-network/)
