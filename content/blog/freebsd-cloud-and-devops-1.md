Title: FreeBSD Cloud and DevOps 1
Date: 2017-01-08 16:00
Tags: freebsd, cloud, devops, cbsd, jail, vm, zfs
Author: meka


The reason I tried FreeBSD in August, after 11 years of being happy with Gentoo
then Debian was the article about Docker on FreeBSD. I knew about PF, ZFS and
DTrace from the past, but ability to run Linux images was just too good to be
true. To the extent, it is too good, and the reason is that ABI Linux support is
not complete. If you happen to need that missing bit in ABI, it's a show stopper
for anybody.

Poor was the result, I'm afraid, but there's a positive side: Docker is not why
I'm stuck with FreeBSD now. :o) There are so much better implementations of
container technologies, I abandoned Docker completely. That and
[Docker's continuous failure](https://thehftguy.com/2016/11/01/docker-in-production-an-history-of-failure/)
make you think of changing the tech stack completely. In this serie, I'll walk
you through my current stack for production and devops.

For start, let me give you some of the vocabulary:

* ZFS - File system and volume manager.
* Jail - Container technology, most similar to Linux LXC or Solaris Zones. Some
think of it as chroot on steroids.
* PF - Packet Filter - firewall.
* BHyve - Type 2 hypervizor, or what provides VMs - virtual machines.
* DNSMasq - DHCP and DNS server - keeps track of which virtual machine is where.
* CBSD - Manages jails and virtual machines - create, up, down, destroy.
* Sudo - Execute stuff as root when needed - devops side, mostly.
* Make{,file} - Make is similar to GNU make with all it's rules in Makefile.
* Resolvconf - Software which configures /etc/resolv.conf

For this post I want you to get a working CBSD env. I'll just assume you have
machine which you'll dedicate to FreeBSD only. Tips for install: use "Guided ZFS
partitioning" and create user when asked. You'll get to know the ZFS over time,
but for now think of it as a requirement for easier jail and VM management. So,
the only thing you have after install is FreeBSD base system on ZFS pool (by
default, it's name is zroot), root user and a regular user. As root prepare the
CBSD:

```
# zfs create -o mountpoint=/cbsd zroot/cbsd
# pkg install cbsd dnsmasq bind-tools tightvnc
# env workdir="/cbsd" /usr/local/cbsd/sudoexec/initenv
# mkdir /usr/local/etc/dnsmasq.d
```

What this does is creates ZFS dataset which will be mounted on /cbsd as soon as
`zfs create` finishes. For now you can think of a dataset as of a partition
which can be created and destroyed while ZFS pool is mounted. Don't worry if you
don't undestand ZFS features, it's really complex piece of software.

After ZFS dataset creation, `pkg` installs CBSD and CBSD is initialized. I have
few tips for the initialization, as it's interactive: don't enable NAT, use
172.16.0.1 for DNS and "10.0.0.0/16 10.0.0.1/32" for IP range. Although CBSD
does great job at figuring out what PF rules it should insert/remove, I like all
the rules in one place, /etc/pf.conf:

```
ext_if = "re0"
jail_if = "lo1"
bridge_if = "bridge1"

set skip on { lo0, $jail_if, $bridge_if }

scrub in all

nat on $ext_if from { ($jail_if:network), ($bridge_if:network) } to any -> ($ext_if)

block in log all
pass out all keep state
pass proto tcp to any port ssh
pass inet proto { icmp, igmp }
```

You can see lo1 and bridge1 interfaces, so they have to be configured. That's
done in /etc/rc.conf:

```
cloned_interfaces="bridge1 lo1"
ifconfig_bridge1="description re0 172.16.0.1"
ifconfig_lo1="up"
```

A bit of an explanation is needed. First, lo1 will be used for jails, bridge1
for VMs. As CBSD does great job of automating VM management, it also creates
bridge and tap interface(s). As I wanted the network part to be as static as
possible, I'm creating bridge1 the way CBSD would and give it the IP which VMs
will use as DNS server and gateway. My only network card on desktop is re0,
hence the description. Disclaimer: all this CBSD network mangling is more
appropriately done by patching /cbsd/vnet.subr and /cbsd/vnet-tui.subr.

You have to enable PF, of course. I like to do it in /etc/rc.conf.d directory for
DevOps purposes I'll talk about later. There are two files for PF: pf and pflog.

/etc/rc.conf.d/pf:
```
pf_enable="YES"
```

/etc/rc.conf.d/pflog:
```
pflog_enable="YES"
```

As CBSD doesn't provide DHCP or DNS for VMs, we'll use DNSMasq. For devops on
your desktop/laptop it's enough and even for small to mid size cloud setups it
would work. On large scale deployments you probably have BIND, already. To enable
DNSMasq, first make it start on boot.

/etc/rc.conf.d/dnsmasq:
```
dnsmasq_enable="YES"
```

You need to edit the config in /usr/local/etc/dnsmasq.conf. These are the
options I changed:

```
domain=vm
dhcp-range=172.16.0.50,172.16.0.250,12h
interface=lo0
interface=bridge1
bind-interfaces
resolv-file=/usr/local/etc/dnsmasq.d/resolvconf
conf-dir=/usr/local/etc/dnsmasq.d/,*.conf
```

All options are present in the file initially, but commented out. In short, this
config provides DHCP and DNS service only on bridge1 which is dedicated for VMs
while allowing for on-the-fly VM info changing by including everything from
/usr/local/etc/dnsmaq.d directory which ends with .conf.

For easier URLs, you can use DNSMasq as your DNS server through 127.0.0.1. To do
that this is what you need to have in /etc/resolvconf.conf:

```
name_servers=127.0.0.1
dnsmasq_resolv=/usr/local/etc/dnsmasq.d/resolvconf
```

Whenever your DNS settings change, resolvconf will write the info into the file
which will make DNSMasq re-read it.

The last thing to do is configure BHyve. You'll need to load the modules and let
CBSD take care of the rest, so add these lines to /boot/loader.conf:

```
zfs_load="YES"
vmm_load="YES"
if_tap_load="YES"
if_bridge_load="YES"
nmdm_load="YES"
```

ZFS and VMM are self explainatory module names, while TAP and Bridge are two
kinds of interfaces used to emulate network stack inside VM. Null Modem or nmdm
is used to get the terminal output through a serial line and tmux.

Reboot and you should be able to create new jails and virtual machines:

```
# cbsd jconstruct-tui
# cbsd jstart <jail>
# cbsd jlogin <jail>
# cbsd jstop <jail>
# cbsd jremove <jail>
```

With `cbsd jconstruct-tui` you have to choose lo1 for the interface, once you're
greeted with the dialog based form. Commands for VMs are the same, just prepend
them with `b` instead of `j`, e.g. `cbsd bconstruct-tui`. The lo1 interface is
only for jails, so for VMs you don't have to do anything special.

Nice thing about bstart is that it will start bhyve process in tmux so `tmux a`
will open it. Another nice thing is that if booting from CD-ROM image, BHyve
will wait for the VNC connection to start the boot process. That means that
booting will not start the second you issued `cbsd bstart`, but once you start
`vncviewer localhost`, so you can see all the messages.

Now, go and play with it a bit. Don't worry, you don't need any images or
anything, CBSD will download them for you when you select appropriate template.
