+++
title = 'FreeBSD Dual Stack Network'
date = 2022-01-15T22:55:00
tags = ['freebsd', 'network', 'ipv4', 'ipv6', 'tunnel']
+++


Idea is to build dual stack network, which means working IPv4 and IPv6. Support
on router and client side is needed for network to work without glitches. For
example, switching from ethernet to WiFi should be seamless. On top, as my ISP
is not providing IPv6, I'll show you how tunnels like Hurricane Electric work,
which in layman terms means "how to have public IPv6 addresses on all my devices
although ISP doesn't provide it". If you have native IPv6 support from your
provider, that's great and just use it, otherwise you can use
[Huricane Electric Tunnel Broker](https://tunnelbroker.net/) to setup IPv6.


## Router

The following is the simplified picture of a network. There is a switch missing
and WiFi is just one line between laptop and router but it's good enough for
explaining what will be configured. On the left of the router is IPv4 connection
that ISP provides, and on the left is IPv6 connection that HE tunnel provides.
There are few services to keep everyone happy, like DHCP server inside CBSD 
based jail, Router Advertisment daemon (rtadvd) to "disperse" IPv6 addresses, 
and so on.

```md
.------.   .--------.   .---------.
| IPv4 |<->| Router |<->| HE IPv6 |
.______.   .________.   ._________.
               /|\
              / | \
             /  |  \
            /   |   \
           /    |    \
          /     |     \
 .--------. .---------. .---------.
 | Laptop | | Seerver | | Desktop |
 |________| |_________| |_________|
```

There are are 3 ethernet ports on APU and one WiFi interface. One ethernet port
is used for connection to ISP, two remaining ports and WiFi are bridged into
one interface. There are few services on the router to make it work:

  * Router Advertisment (rtadvd)
  * Host AP daemon (hostapd)
  * DHCP in jail (isc-dhcpd)
  * Unbound for DNS (local_unbound)
  * Firewall (pf)
  * PPP daemon based on netgraph (mpd5)
  * Jail management (cbsd)
  * Protection from ssh brute force (blacklistd)

/etc/rc.conf:
```ini
# Network
cloned_interfaces="bridge0 bridge1"
ifconfig_re0="inet 192.168.100.254 netmask 255.255.255.0"
ifconfig_re1="up"
ifconfig_re2="up"
ifconfig_bridge0_name="cbsd0"
ifconfig_bridge1_name="lan"
ifconfig_lan="addm re1 addm re2 addm wlan0 stp re1 stp re2 stp wlan0"
ifconfig_lan_alias0="inet 192.168.111.254 netmask 255.255.255.0"
ifconfig_lan_ipv6="inet6 2001:aaaa:bbbb:cccc::3 auto_linklocal -ifdisabled"
wlans_ath0="wlan0"
ifconfig_wlan0_ipv6="inet6 -ifdisabled"
create_args_wlan0="wlanmode hostap"
ifconfig_wlan0="txpower 50 channel 149 up"
hostapd_enable="YES"
rtadvd_enable="YES"
gateway_enable="YES"
ipv6_gateway_enable="YES"
local_unbound_enable="YES"
local_unbound_tls="NO"

# HE IPv6 tunnel
gif_interfaces="gif0"
gifconfig_gif0="MyIPv4 HE-IPv4"
ifconfig_gif0_ipv6="inet6 2001:aaaa:bbbb:cccc::2 2001:aaaa:bbbb:cccc::1 prefixlen 128"
ipv6_defaultrouter="2001:aaaa:bbbb:cccc::1"

# Firewall
pflog_enable="YES"
pf_enable="YES"

# CBSD
ifconfig_cbsd0="inet 172.16.0.254 netmask 255.255.255.0 description ng0"
ifconfig_cbsd0_alias0="inet 172.16.1.254 netmask 255.255.255.0"
cbsd_workdir="/usr/cbsd"
cbsdrsyncd_enable="YES"
cbsdrsyncd_flags="--config=/usr/cbsd/etc/rsyncd.conf"
cbsdd_enable="YES"
rcshutdown_timeout="900"
```

The CBSD portion is present on all machines as I use it to manage my jails, but
I won't repeat it in every configuration.

To turn my WiFi into AP I use hostapd with the following configuration.

/etc/hostapd.conf
```ini
interface=wlan0
debug=1
ctrl_interface=/var/run/hostapd
ctrl_interface_group=wheel
ssid=myssid
wpa=2
wpa_passphrase=Secrit
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
```

As my ISP uses PPPoE I have to use mpd5. It performs much faster than PPP 
included in base. I could get about 200Mbit/s with the one from base, while I
have full 400Mbit/s with mpd5.

/usr/local/etc/mpd5/mpd.conf
```rst
default:
  load mts

mts:
  create bundle static B1
  set iface route default
  set iface enable tcpmssfix
  set ipcp ranges 0.0.0.0/0 0.0.0.0/0
  
  create link static L1 pppoe
  set link action bundle B1
  set auth authname isp_username@open.telekom.rs
  set auth password isp_password
  set link max-redial 0
  set link keep-alive 10 60
  set pppoe iface re0
  set pppoe service ""
  open
```

/etc/pf.conf
```md
# Macros and tables
ext_if = "ng0"
modem_if = "re0"
modem = 192.168.100.1

# Options
set block-policy drop
set skip on lo0

# Normalization
scrub in all

# NAT
nat on $ext_if inet from lan:network to any -> ($ext_if)
nat on $modem_if inet from lan:network to any -> ($modem_if)

# Quick rules
antispoof quick for ($ext_if)
anchor "blacklistd/*" in on $ext_if

# Rules
block in log on $ext_if
pass out
pass proto tcp to any port ssh
pass proto { icmp, igmp, icmp6 }
```

The default prefix is 64, so the configuration is short. Note that you can use
two forms to assign value to an attribute: attribute#value which is the same as
attribute="value".

/etc/rtadvd.conf
```md
lan:addr="2001:aaaa:bbbb:cccc::"
```

In jail DHCP for IPv4 is running with the following configuration in
/usr/local/etc/dhcpd.conf:

```md
server-identifier my.domain.tld;
authoritative;
log-facility local7;
omapi-port 7911;


subnet 172.16.0.0 netmask 255.255.255.0 {
  option domain-name "my.domain.tld";
  option domain-name-servers 172.16.0.254;
  range 172.16.0.1 172.16.0.200;
  option routers 172.16.0.254;
  option broadcast-address 172.16.0.255;
  default-lease-time 3600;
  max-lease-time 7200;
  on commit {
    set clientIP = binary-to-ascii(10, 8, ".", leased-address);
    set clientHost = pick-first-value(option fqdn.hostname, option host-name, "");
    execute("/usr/local/bin/dhcpd-hook.sh", "add", clientIP, clientHost, "my.domain.tld");
  }
  on release {
    set clientIP = binary-to-ascii(10, 8, ".", leased-address);
    set clientHost = pick-first-value(option fqdn.hostname, option host-name, "");
    execute("/usr/local/bin/dhcpd-hook.sh", "delete", clientIP, clientHost, "my.domain.tld");
  }
  on expiry {
    set clientIP = binary-to-ascii(10, 8, ".", leased-address);
    set clientHost = pick-first-value(option fqdn.hostname, option host-name, "");
    execute("/usr/local/bin/dhcpd-hook.sh", "delete", clientIP, clientHost, "my.domain.tld");
  }
}
```

The configuration could be much smaller without hooks, but this way you have
enough information how I register jails in DNS. This part will be detailed on
[cbsd.io](cbsd.io).


## Laptop

It's important to set wlan0 MAC address to be the same as your ethernet. In my
case it is em0. For some reason, rtsold which comes with the FreeBSD base
doesn't work stable and my current workaround is to add `ipv6_defaultrouter`.
It does kinda defeat the purpose of software called "router advertisement", but
until [this bug](https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=261129) is
resolved, it is good enough for me, as I have small number of machines. You
might think I could use dhcpcd for IPv4 and IPv6, but there's a problem with
that: no matter how I configure jails, they just can't get IPv6 when I'm using
dhcpcd on the host. More on that in a later post.

/etc/rc.conf:
```ini
# Network
cloned_interfaces="lagg0"
wlans_iwn0="wlan0"
ifconfig_wlan0="ether f0:de:bb:aa:c2:2a WPA up"
ifconfig_em0="up"
create_args_wlan0="country US regdomain FCC"
ifconfig_lagg0="laggproto failover laggport em0 laggport wlan0 DHCP"
ifconfig_lagg0_ipv6="inet6 -ifdisabled accept_rtadv auto_linklocal"
gateway_enable="YES"
ipv6_gateway_enable="YES"
ipv6_defaultrouter="2001:aaaa:bbbb:cccc::3"
```


# Server

On server I like to set static IPv4 and IPv6 addresses.

/etc/rc.conf:
```ini
ifconfig_igb0="inet 192.168.111.201 netmask 255.255.255.0"
ifconfig_igb0_ipv6="inet6 2001:aaaa:bbbb:cccc::4 -ifdisabled auto_linklocal"
ipv6_defaultrouter="fe80::5a9c:fcff:fe10:6c2c%igb0"
defaultrouter="192.168.111.254"
```

Not that "%igb0" means something like "search for this link-local address on
igb0 interface".


[Next](/blog/2022/01/22/freebsd-dual-stack-jails/)
