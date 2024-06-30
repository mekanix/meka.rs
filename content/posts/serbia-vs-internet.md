+++
title = 'Serbia vs Internet'
date = 2020-12-09T12:20:00
tags = ['serbia', 'internet', 'ipv6', 'ppp', 'pppoe', 'freebsd']
+++


Dear reader,

I really wish that you're somewhere nice and you read this story with "in a
land far away" at the beginning, wondering how strange we are. I really wish
that place exists, because if we're all and I mean ALL dealing with this, we
screwed up as a global IT community.

This story starts 2.5 weeks ago when we decided to switch the Internet package we
use. New one has 2 times download and 4 times upload compared to the old one, and
why not. Also, we decided to take static IP so I don't have to juggle dynamic
DNS. It's Monday, and we have to go to their office. It's corona time, and we
have to GO TO THE OFFICE!!! It's even worse. We had to wait outside, it's
almost December at that time and I'm on northern hemisphere, so it's fucking
cold! We knew that it takes forever for any Serbian ISP to do anything, so my
wife called, first, explaining what we want to do, so they wrote it down and
said "just go to our office, show them your ID and it's all done once you
sign".  Ha! We fell for that again!? But yeah, it was shorter than without the
preparation. The system didn't work well, so it took eons to finish those
papers. At the end the clerk said "I'll send you an SMS once it's done, so you
don't have to wait". OK, so it took half eternity to do that and a few hours
later we had a faster Internet. The fact is that with [MTS](https://mts.rs/) you
never know the speed of the Internet you're signing for, because there is one
speed declared on their site, one on their pamphlet and one printed out in
their office. Of course, I'm talking about the same package! But OK, after
speedtest you know what you have, and it's 400/150MBit/s.

Now that was the easy part. Yeah, freezing my ass off was the easy part! Until
tomorrow morning we didn't get static IP no matter what I reset or reboot. I
wrote them on the chat on their site and 30 minutes later, I have no Internet
connection. The IP can not get more static than this, that's for sure! I have
no idea how many times we called, wrote to them, cried on twitter and whatnot.
First support call came on Friday! I mean, by Friday you can have a heart
operation, and it's 4 days that it takes for MTS to even call (and ask for the
imposibilionth time "what are the symptoms?"). Naturally, I didn't wait for
them to do something, I had better things to do. First, I noticed that when I
restart their modem with factory settings, I can ping an IP for a short period
after it boots. OK, so it means it connects, I have some connection, it fetches
config from ISP server or wherever, loads it and all connections die. Now I know
it's not something physically broken, which would take a hell to freeze over
before some ISP's operator decided to go outside. Now all I need is admin
user/pass to fix the modem config. Luckily, most providers here don't practice
security, so admin pass is
[all over the Internet](https://www.google.com/search?hl=en&q=mts%20password%20HG8245H).
As a security expert I should be advocating for this to change, but HELL NO! How
am I going to fix their screw ups if they change all the passwords?

The Internet is back, and I notice their device can be configured in bridged mode.
In the same WEB interface you have user/pass fields pre-filled, and you can see
it's PPPoE connection. Fine! Inspecting the pass element in the browser gave me what I
thought is the password. Better looking at it, it had only numbers and letters
A to F. Damn! I hoped it's not hash, but here we are. One thousand calls later
I'm talking to a guy who can actually give me a user/pass for PPPoE. In the meantime,
waiting for them to find somebody who knows what I'm talking about I
configured ppp.conf in FreeBSD. I know it's a good config because the error I
get is "wrong password". Here is the part of that conversation:

<pre>
me: I need a PPPoE username and password
him: Username is &lt;username&gt;
me: ... and?
him: That's it.
me: If I give you a username for Facebook, can you login?
me: There has to be more!
him: Well, write this down (and he dictates my static IP)
me: I already have that data, I need the password.
him: telekom/telekom on 192.168.1.1
me: That's your router and user/pass for it. I need a PPPoE password.
me: P-P-P-O-E!!!
him: I'll have to call you back.

him: Your password is &lt;curse in Serbian&gt;
me: I'm sure somebody was listening to my talks!
</pre>

By the way, he didn't provide the whole username, because it's in the form of
&lt;user&gt;@open.telekom.rs (or something similar), but I didn't care, it's
written in the WEB interface of an ISP device. Bridge mode, here I come! But damn, my
speed is 40/40MBit/s. Looking around I found net/mpd5 and it got me to 200/150.
OK, that's nice! I read somewhere that igb has problems with PPPoE (something
about not using all card's queues). Luckily I have APU1 to replace that APU2.
With APU1 now I have full speed. Hell yeah! But it's not perfect, as AES-NI
support in hardware came with APU2, so all VPNs will be slow. As a remedy for
that, I can forward port to a home server and have a VPN concentrator there, but
it's not perfect.

Now we come to the fun part. One more reason why we need static IP is because
IPv6 is a myth: everybody's talking about it, but it can not be spotted in the
wild. You know how your ISP is all nice and sweet when they need to push new
technology or they just started giving some service? That's when you need to
strike! That's a rare chance to get to somebody technical really fast and then
ask real questions. Needles to say, when MTS started offering fibre optics,
they started sending sales personnel to persuade people to switch their ISP. I
asked them for IPv6 and the sales guy didn't know, of course. So in a few days he
came with a technical guy, we sat down and I asked a lot of questions, but once
I got to IPv6, he said he has no idea what that is, but he has a number of the
guy who probably knows about it. He called and gave me the phone. Needles to
say, the third guy in a row has no idea what I'm talking about, so the answer
is probably "no IPv6 address for you". There was literally nobody else to call
and ask for IPv6.

No IPv6 means I can use [HE tunnel](https://tunnelbroker.net/) to get IPv6 over
IPv4, and at least start learning about the technology and stack and whatnot.
Once we had static IP, I realized DMZ is not going to work for that tunnel, so
I needed to set the ISP device as a bridge, hence the above hassle. The tunnel broker
is really nice as it gives you exact commands to type in your terminal as root
for every operating system there is, so it's the next best thing to having an
actual IPv6.

I have APU1 currently working, APU2 that gave me headache and APU4 laying on my
table waiting for me to configure it and try if it gives me full Internet speed
while being able to utilize hardware AES-NI. One of these days, I'll be on the
Internet like it's a normal thing in the 21st century.
