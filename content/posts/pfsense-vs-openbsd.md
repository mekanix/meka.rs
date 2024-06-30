+++
title = 'pfSense vs OpenBSD'
date = 2015-06-07T22:00:00
tags = ['openbsd', 'pfsense']
+++


I've had pfSense on my router for some time now. To be honest, about a year. The
reason I decided to switch to OpenBSD should be obvious, but I'll write about it
anyway. Let me introduce you to the background of the two choices.

PfSense is based on FreeBSD. To be more precise, version 2.1 which was latest
stable release up to few months ago, is based on FreeBSD 8, while 2.2 is based
on FreeBSD 10. To be honest, FreeBSD is one of the most exciting projects ever.
In my opinion mostly because of the technologies it ported from other operating
systems like ZFS and DTrace from OpenSolaris and PF from OpenBSD, to name the
few. With such diversity of ported projects, it has my deep respect if for
nothing else, than for being able to incorporate and maintain them in a secure
and stable way. If you ever tried to continuously port and maintain a software
from other platform, you know what it takes. For me, firewall is the most
important part of routing OS, and FreeBSD having incorporated the best one,
makes it great.

But, it's not all that great. For example, PF in FreeBSD is based on OpenBSD's
implementation (which is original) from 4 years ago. Although FreeBSD and
OpenBSD have different plans and courses for their implementation of PF, I like
OpenBSD's syntax better. Another thing that made me switch to OpenBSD is DHCP+DNS
on pfSense. I don't know if it's up to FreeBSD or pfSense, but once a machine
gets IP, it takes too long (as in 15 minutes) for it to be registered in DNS.
All of this was enough for me to at least try OpenBSD. Hmmmm ... try. Let me
tell you I'm not going back to pfSense, but I might give FreeBSD a chance. I like
to experiment, so we'll see.

I've also ditched ubound and dhcpd in favor of DNSMasq which serves great as a
DHCP+DNS server. WiFi hostap works like a charm, and almost every system config
file is in /etc. The way to make console redirect to serial port is to enter 2
lines in /etc/boot.conf (you have to use proper pfSense image to do that). All
that and the fact that Cisco and Apple is PF makes me feel warm. :o) No,
seriously, what makes me have this feeling of security is what I've heard from
a friend few years back: "OpenBSD policy that the mistake in the documentation
is the mistake in the code".

One of these days I'll be writing a script to automate the provisioning of my
router which will portrait the ease of using OpenBSD more than this post.
