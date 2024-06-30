+++
title = 'FreeBSD WiFi and Ethernet Bridging and Aggregation'
date = 2016-12-24T22:27:00
tags = ['freebsd', 'bsd', 'network', 'wifi', 'ethernet']
+++


The title is cumbersome but the topic is quite ordinary life, to be honest. Idea
is to have WiFi and Ethernet cards unified. On the router that means that
whether you're getting your address over Wifi or Ethernet, you get the same
range. On the client (usually laptop) we want to not be able to distinguish if
we're on Wifi or Ethernet connection, but we do prefer Ethernet.


Router Configuration
-------------------------

When you think about it, what we need is described in lame terms as "I want wifi
and ethernet interface to have same IPv4 address". As that's kindda imposible,
you can have a bridge with Spanning Tree Protocol (or STP for short), which is
the next best thing. Bridge is just one virtual interface which binds, or
bridges, two or more interfaces. In my case, ethernet interface is re1 and wifi
interface is wlan0. To create a bridge with STP (to be totally honest, FreeBSD
defaults to RSTP or Rapid STP which is STP compatible) you'll add the following
to /etc/rc.conf:

```sh
# WiFi config
wlans_ath0="wlan0"
create_args_wlan0="wlanmode hostap mode 11gn"
ifconfig_wlan0="ssid mywifi channel 8"
hostapd_enable="YES"

# Bridge config
ifconfig_re1="up"
cloned_interfaces="bridge0"
ifconfig_bridge0="addm re1 addm wlan0 stp re1 stp wlan0"
ifconfig_bridge0_alias0="inet 192.168.5.1 netmask 255.255.255.0"
```

That's it. You'll notice that we enabled hostapd, too. It is what provides WPA2
on WiFi. It's config is:

```sh
interface=wlan0
debug=1
ctrl_interface=/var/run/hostapd
ctrl_interface_group=wheel
ssid=mywifi
wpa=2
wpa_passphrase=password
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
```

I found tutorials which set MAC address of all three interfaces: wifi, ethernet
and bridge to the same value. I tried it and it doesn't work. As a matter of
fact, the config show here will produce that you see the same MAC of your router
no matter how you connect to it: Wifi or Ethernet.

What you probably want is NAT enabled router. My prefered tool is PF. To enable
PF and logger, add the following to /etc/rc.conf:

```sh
pf_enable="YES"
pflog_enable="YES"
gateway_enable="YES"
```

The simplest rules for this use case are:

```sh
ext_if = "re0"
int_if = "bridge0"

set skip on lo0

scrub in all

nat on $ext_if from $int_if:network to any -> ($ext_if)

block in all
pass out all keep state
pass proto tcp to any port ssh
pass inet proto { icmp, igmp }
```


Laptop Configuration
-------------------------

What we want on laptop is quite the opposite of the router: instead all bridged
interfaces to work at the same time, we want only one to be active. The rule for
activation is: if there's no signal (or carier) on the Ethernet interface, use
WiFi. That kind of virtual interface is called lagg or Link Aggregation. One
lagg has master interface (in our case Ethernet one) and slaves. Master
interface is the one that is added to the lagg the first. To aggregate WiFi and
Ethernet on em0 interface, add the following to /etc/rc.conf:

```sh
cloned_interfaces="lagg0"
wlans_iwn0="wlan0"
create_args_wlan0="country US regdomain FCC"

ifconfig_lagg0="laggproto failover laggport em0 laggport wlan0 DHCP"
ifconfig_wlan0="ether f0:de:f1:64:2c:3b WPA"
ifconfig_em0="up"

```

There are 3 important parts. First, wlan0 MAC is set to be the same as the one
found on em0. This minifies the time it takes to switch between the two
interfaces. Second, don't put DHCP anywhere except on the lagg0. Third, you have
to bring all the interfaces you use up (hence the last line).

With the router that leases the addresses only from one pool, and interfaces
that are effectively on the same IP range, aggregating interfaces on laptop with
the same MAC address will give you the same IP no matter how you're connecting.
Also, as FreeBSD PF doesn't have egress, having all outbound traffic on one
interface, be it virtual or hardware, makes things easier to filter and route.
