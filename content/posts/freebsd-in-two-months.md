+++
title = 'FreeBSD In Two Months'
date = 2016-10-28T00:15:00
tags = ['hacking', 'freebsd', 'bsd']
+++


My last post was about CCC and it's almost the time for a new one. I was so
bussy hacking things that I forgot I have a blog. Huge amount of new things
happened to me, but I'll focus on the FreeBSD. I installed BETA1 of 11.0 as soon
as it came out as I really wanted to see how good is the Docker support. Now I
don't even use Docker, and FreeBSD is my main OS on laptop and desktop, although
I still have Debian on desktop for the sake of recording my band. So let me give
you some context and my history with this operating system.

I remember I was using 5.0 for a while and 4.9 before it for quite a while. The
first thing I noticed is the size of the system and the speed at which world is
compiled. It was so much faster to compile FreeBSD libc than glibc that I
suspected that there's something missing in the BSD libc. For me, that was all I
needed to switch from using SuSE 7.2 at the time (I think). It was 2003-2005
that I used FreeBSD with some pauses. As my university was under heavy influence
by M$, I had trouble adjusting Linux to do what was needed. Doing the same on
FreeBSD wasn't even poissible. Soon, I switch to Gentoo, as it was the next best
thing.

To be honest, I never looked back to FreeBSD until two months ago. What I read
was that version 11 is comming with the Docker support, which I used heavily on
my servers. From past experience I knew about the beauty of FreeBSD build system
and PF as firewall and ZFS and DTrace and ... I was lucky enough that about a
month after I installed FreeBSD on my laptop, there was a EuroBSD conference in
my country. Of course I rushed there! But something happened since then.

Talking to some of the clients and friends gave me impression that GPLv3 is
scaring people and companies. As a huge fan of GNU, I just thought they are not
using open source, so they don't know what they are talking about, but then I
read about GPLv3 more. As a tool for binding people to write more open source
code, it became monopolistic licence in a way that if anything is GPL,
everything is GPL. This resonated in my head for some time and that was what
made me realize why are BSD people so licence pure - you can't ignore business
just because you have this vision in your head that says "everyone should write
open source code". BSD community seamed (and it is) more permissive and open to
the real world.

But licences are not my strong point, so I'll stick to the tech part. Let me
just briefly describe some of the technologies in the BSD world. First in my
book is ZFS. It is so much more than a file system. It has RAID included, if
needed, it has copy-on-write, it's got 128bit system, it has volume manager and
on top of it all, RAID is not just RAID, it's RAIDZ, meaning ZFS keeps extra
checksum for every block, which make it super consistent.

Second on my list of favorite technologies is PF. It's so readable that
sometimes I wonder if they screwed up implementation just to make it more
readable (of course they didn't). Even so, it's strongest point is not syntax,
it's statefulness of the firewall. PF deserves a post on it's on but to put the
statefull firewall into context: it gives you more logical connections between
the packets.

Third one is DTrace which stands for "dynamic tracer". It's an interesting idea
that every OS is full of probes in different places, and when turned on, they
give you information about ... well, depends what probs you enable. When no
probe is enabled, it has no overhead at all, which makes it great for debugging
production servers. It can trace kernel and user space and has a AWKish syntax.

Fourth, and last for this post is Jail. Although it's technology introduced in
FreeBSD world in 2000, somehow it didn't get much publicity. Together with ZFS
it makes one hell of a system for hosting stuff. Also, that's the core of
FreeBSD implementation of Docker.

Almost none of that is what I'm working on, right now. Although I made a switch
because of the above mentioned technologies, the main reason for me to hack it
more is it's fully preemptive kernel, which is the core of any real time system.
Real time makes sound better and delay from plucking a guitar string to hearing
it on the speakers is lower. Most of the work on supporting audio interfaces
with more than 8 channes is done by Hans Petter Selasky, so I'd like to
publicly thank him for all the trouble he when through. Although my FreeBSD DAW
is not perfect due to smaller number of audio apps then the number found in
Linux world, it shows huge potential.

What happened in 2 months exactly? As I'm Python and JavaScript developer,
musician, video editor and in one word hacker, I didn't expect FreeBSD to
fullfill all my needs (no other OS did). Today only Drumgizmo is what's missing
on my FreeBSD box to make it a perfect DAW. To be honest, after two months of
using it I expect that I would be learning kernel development in order to make
any sound. Instead, it almost gives me all the power I would ever need (yeah,
I know there's new power to be found).

So to put it all together, what FreeBSD gives me is the power to have one
machine for everything: security, firewalling, FS consistency, real time audio
and development environment for any language I choose to work with. I really
enjoy my new OS, but I have one concern. As I'm talking to people how great
FreeBSD is, I'm affraid I'll become one of those preachers who can't stop
talking. It's not my vocal cords I'm concerned about, as after all I am a singer
in a metal band. It's the damage I might do to the FreeBSD as a project if I'm
preaching about it too much.

Thank you, FreeBSD project!
