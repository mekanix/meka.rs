+++
title = 'FreeBSD and IPv6 Tunnel'
date = 2021-12-19T21:48:00
tags = ['freebsd', 'hacking', 'ipv6', 'tunnel']
+++


Huricane Electric is one of IPv6 tunnel providers and this post is specifically
about setting up FreeBSD router with a tunnel and the configuration for IPv6
autoconfig caller Router Advertisment (RS, on the router) and Router Solisticion
(RS, on desktop or laptop). If you know how DHCP for IPv4 works, you will find
it a bit weird how IPv6 works. First, in IPv6 world what is called DHCPv6 is
closer to what DHCPv4 does than RA/RS. Here, RA/RS setup will be described. The
end result is that router and clients have access to IPv4 and IPv6 at the same
time, or in how it's called "Dual Stack".

### Router

Although Huricane Electric will give you exact commands/config for operating
system of your choice, I'm showing here whole configuration for completeness.
The address range `fd12:c09a:85be:4851::` is just a dummy one, you should use
the one HE provides.

In /etc/rc.conf:

```bash
ifconfig_re1="up"
ifconfig_re2="up"
ifconfig_bridge1_name="lan"
ifconfig_lan="addm re1 addm re2 addm wlan0 stp re1 stp re2 stp wlan0"
ifconfig_lan_alias0="inet 192.168.0.1 netmask 255.255.255.0"
ifconfig_lan_ipv6="inet6 fd12:c09a:85be:4851::3 auto_linklocal -ifdisabled"

# HE IPv6 tunnel
gif_interfaces="gif0"
gifconfig_gif0="<MyIPv4> <HEIPv4>"
ifconfig_gif0_ipv6="inet6 fd12:c09a:85be:4851::2 fd12:c09a:85be:4851::1 prefixlen 128"
ipv6_defaultrouter="fd12:c09a:85be:4851::1"
```

In /etc/rtadvd.conf:

```bash
lan:\
  :addrs#1\
  :addr="fd12:c09a:85be:4851::"\
  :prefixlen#64\
  :tc=ether\
  :rltime#0\
  :rdnss="fd12:c09a:85be:4851::3"\
  :dnssl="meka.rs"
```

In /etc/rc.conf.d/rtadvd:

```bash
rtadvd_enable="YES"
rtadvd_interfaces="lan"
```


### Desktop/Laptop

In /etc/rc.conf:

```bash
cloned_interfaces="lagg0"
wlans_iwn0="wlan0"
ifconfig_wlan0="ether f0:de:f1:64:2c:3b WPA up"
ifconfig_em0="up"
create_args_wlan0="country US regdomain FCC"
ifconfig_lagg0="laggproto failover laggport em0 laggport wlan0 DHCP"
ifconfig_lagg0_ipv6="inet6 accept_rtadv -ifdisabled"
ipv6_defaultrouter="fd12:c09a:85be:4851::3"
rtsold_enable="YES"
```

Configuration is based on
[Router and Laptop on FreeBSD](/blog/2016/12/24/freebsd-wifi-and-ethernet-bridging-and-aggregation/).
It can be simplified if you use only wlan, which probably means you don't need 
bridge at all hence you should configure wlan0, for example.
