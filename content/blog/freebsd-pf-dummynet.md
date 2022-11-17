Title: FreeBSD PF and Dummynet
Date: 2022-11-17 11:57
Tags: freebsd, network, pf, dummynet
Author: meka


In 14-CURRENT there is now support for dummynet in PF. That means that you can
slow down packets based on some criteria. MacOS users probably know how this
works as that OS got support for PF+dummynet years ago. For example, you can do
the following in /etc/pf.conf:

```
pass in quick inet from 192.168.1.1 to any dnpipe 1
```

That way all traffic from 192.168.1.1 will go through dummynet pipe. To create
and configure the pipe you use:

```
dnctl pipe 1 config bw 300KByte/s
```

I gave it a really low bandwidth because I want it to be really noticeable if
packets are going through dummynet or not. You can change the pipe's bandwidth
by using the same command just changing the numbers. Note that K and B have to
be upper case. You can, of course, use all the usual suffixes like M and G but
note that dummynet has a limit on the bandwidth it can configure.

To see what is configured you can use:

```
dnctl pipe show
```

With dnctl, show is an alias for list, so you will get the same results using
either.

I didn't make it so that packets generated on the machine itself be processed
by dummynet, but it might be intentional. What does work is VNET so your jails
can have different PF and dummynet configuration than the host.

One annoying thing is that there is no dnctl rc.d service, so you will probably
write `dnctl` commands in something like `rc.local` or something. I do plan to
create rc.d service for myself and when I learn more about dummynet, to publish
it hoping it will become part of base so we can easily configure it.
