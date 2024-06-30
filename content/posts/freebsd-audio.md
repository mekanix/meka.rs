+++
title = 'FreeBSD Audio'
date = 2021-10-12T10:00:00
tags = ['audio', 'freebsd']
+++


I started using FreeBSD in 2016 as a dual-boot with Linux. The reason was that
at the time Linux provided no support for real-time threads and preemptive
scheduling but did provide a wider choice of audio applications. Today, as the
FreeBSD audio ecosystem improved a lot, I am a happy single-OS user.

You may ask yourself "why is being fast so important to audio" and the answer
is "it isn't most of the time". To be more precise, from a listener's
perspective, it is the same if sound is late 5 seconds or 1 second, as long as
the period of "being late" is the same for every sample up to a few
microseconds. If samples have variable latencies, the original sound will be
distorted by samples swinging around their precise time. So for playback, it's
not important to be fast, it's important to be right on time for every sample
to avoid distortions caused by samples being too early or too late, which is
commonly called "jitter".

On the other hand, a musician playing through a FreeBSD machine is interested
in both: speed of processing and precision. We need to have in mind that all
samples first have to be processed by hardware, then comes the driver and in
the end user space programs. When every device's output is late compared to
input, that is called latency. If latency is 5ms and lower, it is impossible
for most people to tell there's any latency at all. Latency is important to
musicians because of the feedback: hearing a sound that has 50ms latency can
confuse the musician to a point where they can not play any more.

FreeBSD at the time had really nice real-time support but not so nice audio
ecosystem and almost non-existing MIDI one. You must be wondering why I
switched to something half-baked when Linux at the same time had awesome
audio/MIDI support. It's those jitters.

Although I had every program I could wish for on Linux, FreeBSD simply didn't
have jitters, and it matters a lot! Sometimes jitters would cause sudden and
loud pops and that made studio recording more challenging. So having FreeBSD
working perfectly, but unfortunately with not so much app support, was better
for me than having all the apps I want and no way of being sure the sound will
be recorded properly.

Today we have a different situation thanks to Hans Peter Selasky who wrote
cuse, virtual_oss, USB stack and snd_uaudio and Yuri who ported around 1500
applications to FreeBSD, among which is a huge number of audio/MIDI apps. To be
honest, virtual_oss existed in 2016, but it wasn't as versatile and stable as
today. The reason why anyone would want virtual_oss is to make audio routing
easy by having a virtual sound card which knows how to route the signal while
user space applications are unaware of it and they just use FreeBSD sound(4)
API. There are numerous other features of virtual_oss that can come handy like
mixing, compressing and EQ in user space, but audio routing and
splitting/merging one card to many virtual ones or combining input and output
from different devices is the most common use case, like having bluetooth
headphones and USB microphone, so virtual_oss is required more and more outside
of recording studio and high-end sound setups.

One sound system must contain an API to work with audio, MIDI and mixer. Open
Sound System (or OSS for short) on FreeBSD is no exception to this rule, so
there are 3 most common devices for every API: /dev/dsp, /dev/midi and
/dev/mixer. The most basic usage for /dev/dsp is to open(2) it, use ioctl(2) to
configure sample rate and format and then use read(2) and write(2) for
recording and playback. It is somewhat similar for /dev/midi, but /dev/mixer is
all about control and no samples, so it mostly uses ioctl(2) to operate. As
every system needs metadata, /dev/sndstat is used for OSS. If you `cat
/dev/sndstat`, you can find some information about your DSP and PCM devices.
You can use `sysctl hw.snd.verbose=2` to get even more information out of
/dev/sndstat. Parsing this file as text is the only way to get the list of your
sound devices that works across multiple FreeBSD versions. Ka Ho Ng used this
technique in patch for cubeb, which is a sound library used by Mozilla, hence
adding OSS and virtual_oss support to Firefox and other products by Mozilla.
Today Ka Ho Ng is FreeBSD developer who implemented nvlist(9) based API to
enumerate devices, or in simple terms: list hardware and virtual sound devices
using nice API.

User space applications and libraries are growing and apps that I would like to
mention that have been ported to FreeBSD are Ardour, Muse Sequencer, Zrythm,
Drumgizmo, EQ10Q, Calf and Invada plugins. I use most of those in my studio on
a regular basis and I have to admit I'm impressed how stable they work given
that most developers did not develop with FreeBSD in mind.

Today in a studio, snd_uaudio and ports/packages will cover 99% of everyone's
needs. Few years back I talked to Benedict Reuschiling and he said "we never
advocated FreeBSD for audio before", so I'm sure everyone in the community is
happy with advancements made in just a few years. I keep mentioning studio
setups as they are more complex and demanding, but what about laptops and
desktops whose sole purpose is not audio? That's the beauty of FreeBSD audio
and virtual_oss: if it works for complex setup, it works even better for simple
one. All sample rate and format is taken care of per application while
virtual_oss itself knows how to use real-time threads. Ideally, all that is
needed is OSS support in applications.

For FreeBSD audio and DSP developers the situation is becoming increasingly
better through newer APIs and more convenient development environments. For
example, it is already possible to do all your development in jail if that jail
has access to proper /dev/dspN. To achieve that following /etc/devfs.rules can
be used:

```sh
[audio=6]
add include $devfsrules_hide_all
add include $devfsrules_unhide_basic
add include $devfsrules_unhide_login
add path 'dsp*' unhide mode 0666
add path 'vdsp*' unhide mode 0666
add path '*midi*' unhide mode 0666
add path 'mixer*' unhide mode 0666
add path 'sndstat' unhide mode 0666
```

That is not new for FreeBSD, but it does bring one interesting use case:
running tests inside jail. To do just that maybe it means you would hear weird
sounds on your speakers when all you wanted is an end-to-end test of your audio
application. Virtual_oss has different backends where hardware DSP is just one
of them. Another example of backend is dummy, which allows virtual_oss to run
without connection to any real hardware. To do that you can configure
/etc/rc.conf in the following way:

```sh
virtual_oss_enable="YES"
virtual_oss_configs="dsp dummy"
virtual_oss_dsp="-T /dev/sndstat -S -i 8 -C 18 -c 18 -r 48000 -b 32 -s 768 -f /dev/dsp0 -c 2 -w dsp.wav -d dsp -t dsp.ctl"
virtual_oss_dummy="-T /dev/sndstat -S -i 8 -C 2 -c 2 -r 48000 -b 32 -s 768 -f /dev/null -c 2 -w vdsp.wav -d vdsp -t vdsp.ctl"
```

There are two configs that are fairly similar. For dsp, one device with 18
in/out channels is configured as /dev/dsp which have 2 channels. Also, the 2
channel device is set as /dev/dsp which is the default OSS device, so
applications which do not handle non-stereo cards will have no problems.

For those apps that know how to list sound devices and use channels properly
/dev/vdsp is at their disposal. One unusual device is /dev/dsp.wav which you
can use for recording just by using `cat /dev/dsp.wav >recording.wav`. To
control virtual_oss at runtime you can use `virtual_oss_ctl -f /dev/vdsp.ctl`.
The previous example creates one .ctl device file per virtual_oss
configuration. Second configuration is a dummy and it uses /dev/null as a
hardware device to achieve most of what dsp config is doing, only simpler. It
creates only one device and that is /dev/vdsp.dummy which is stereo only. It
uses the same resampling (-S), real-time priority (-i 8), sample rate (-r
48000), bit rate (-b 32) and buffer size (-s 768) as dsp config while creating
similar .wav and .ctl devices.

Now you can use /dev/dsp and /dev/vdsp inside or outside of jail to have either
a real hardware device or purely virtual one. All of those flags can be changed
at runtime with `virtual_oss_cmd`. You can switch to "studio mode" as I call it
(smaller buffer size), do your recording/production and then switch to "desktop
mode" with larger buffer. Do note that virtual_oss can change buffer size on
start as most applications using OSS API will read desired buffer size once, on
initialization. Almost all flags supported by virtual_oss are also changeable
during runtime via virtual_oss_cmd. Developer or not, all people sometimes need
to switch their default input/output device so it is really handy in everyday
use, too. Now if you need ALSA or SNDIO development inside that same jail, it's
just a matter of installing ports/packages and altering configuration to your
liking (default sound device, for example).

Let's see what studio means in technical terms. Core of every studio is a mixer
and today's mixers are usually also USB audio interfaces. For live performance
and monitoring, mixer is where it all happens. For recording and
(post)processing, the computer is doing it all. The description of the mixer
and operating one is dependent on the model so I won't cover it here, but the
recording part is where FreeBSD shines.

Besides having architecture that allows for real time threads and less jitters
(to be honest, using it for years I never saw any jitters at all!), it is
really nice having storage feature like ZFS to make sure your recordings are
safe. As with a big number of channels user space mixing and resampling is more
efficient then the one in the kernel so virtual_oss and OSS provide an ideal
combination. The core of every recording system is Digital Audio Workstation,
or DAW for short. In my studio, the DAW of choice is Ardour. It is mature and
stable and has great integration with JACK. For the set of effects I use Calf,
Invada and EQ10Q plugins as they provide good implementations of reverbs,
choruses, equalizers and flangers. My choice of drum sampler is Drumgizmo, but
it's no wonder being a contributor to the project and port maintainer. Drumgizmo
is unique in a way that it records and plays samples (drum hits). The idea is to
replicate a studio recording as close as possible, so its principle is to have,
for example, a snare drum recorded with all 16 microphones. Although the
microphone in the kick drum will record the snare hit very faintly, having all
16 microphones record every hit makes the recording sound like a live studio.
Recording with a non-main microphone is called bleeding and is controllable in
Drumgizmo. Bleed and humanizer (randomizing hit strength, timing and position
on the pad/cymbal) make recording sound very natural. I personally use hardware
guitar/bass/vocal processor and synth, so I'm not experienced with software
alternatives, but I do know some of my friends really like Geon Kick and
Yoshimi for electronic music and Guitarix for guitar based music.

For me the hardware mixer is doing most of the audio routing and monitoring,
but for USB audio interfaces that are not stand-alone, software has to do it.
Usually, one would do routing based on JACK and it is a valid option, but with
virtual_oss there's another one. Let me give you an example. In the past I used
USB audio interfaces that are not stand-alone and what I constantly have as a
requirement that the first input (my guitar) is routed to outputs 9 and 10 (my
guitar processor). To achieve this, you can add "-M i,0,8,0,0,0 -M i,0,9,0,0,0"
to virtual_oss options. Note that channel numbers start with zero. There are
also interfaces that have separate main output for speakers and headphones. For
monitoring it is not so great so if you'd like to mirror everything that goes
to speakers (output 1 and 2) to headphones (outputs 7 and 8), you can use "-M
o,0,6,0,0,0 -M o,1,7,0,0,0". The options virtual_oss alone supports give you
the ability to have EQ, compressor, loop back, HTTP streaming and more, but it
would be too much for this article to describe it all. Man page contains all
options and examples of how you can achieve different setups.

If you think there's not much that FreeBSD brings to the table in the audio
world, you're right and wrong at the same time. What the operating system can
do in terms of audio is provide real time support, efficient resampling and
good choice of open source DAWs and plugins. But that is true only if you use
that computer exclusively for music.

I believe that general purpose operating systems must be general enough to be
the choice for any task and that is where FreeBSD shines: with jails,
firewalls, virtual switches, ZFS, packages that are up to date, security
updates and all the person would expect from an operating system. FreeBSD
provides it all while being great for music, so with it power is literally
under your fingertips.

If you think about it, MacOS and Windows are mostly desktop operating systems,
Linux lacking proper ZFS support/integration hardly makes it good for storage,
Solaris is too huge for a router and other BSDs probably don't have the number
of audio ports that FreeBSD has. So to put it short, FreeBSD shines at not
needing anything particular: no special care needed wherever you run it and
whatever combination of apps you choose.

Call me stubborn, but having one operating system on a router, server, desktop,
laptop and RPi is a big deal for me, especially if it solves all my problems on
any hardware I put it on. For reference, my desktop machine in the studio is a
12 year old i5 PC with 8GB of RAM which I also use for Python/React/C/C++
development and most of that development is in jails.

What I'm trying to say is that FreeBSD gives you means to run literally
everything on one machine while not sacrificing any efficiency.

So to put it really short, FreeBSD is great for audio studio not because it
brings some unseen features, but because it does not collide with anything on
the system while providing real time support, so the feeling is "this is just a
normal desktop with audio apps". Maybe it doesn't sound too good, but just
having "normal desktop" and "real time support" in one operating system is far
from usual, and FreeBSD might be the only operating system not explicitly built
for real time but able to provide that.

I have to say, the best quality of FreeBSD is our community. It is so easy to
get to the right answer with the mailing list like multimedia@ and #freebsd
channel on libera.chat. My personal experience is that the FreeBSD community is
open and approachable. There are no distro-specific questions, the handbook is
for FreeBSD and not just one of the FreeBSD forks/distributions. Developers are
approachable by people who often are not sure what they need to ask in the
first place. In one word, getting the proper information feels really easy and
proper audio setup in a studio is a breeze using this operating system.

**Note: when using jack configure it to use the real hardware. That means /dev/dsp1
that is OSS device (in my case with 18 channels) instead of /dev/dsp which is
virtual_oss device (in my case with 2 channels).**

The work from Ka Ho Ng is in base and jack2 port is available 
([bugzilla 251125](https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=251125))
mostly thanks to Florian Walpen. My review ([D30149](https://reviews.freebsd.org/D30149))
added a simple example of OSS development and is just the first of OSS examples 
to follow. One oftenly requested improvement to the handbook is the section 
of sound and audio.  Alfonso Siciliano has great experience with mixer API 
and has contributed mixertui port and has offered help in understanding that 
code for future documentation purposes. Maolan is DAW (digital audio workstation) 
which is FreeBSD specific for now that I'm writing as an attempt to learn DSP 
and MIDI development and is the code where most of my experience/documentation 
comes from. While I do appreciate software like jack, I strongly believe that 
FreeBSD should have a DAW with native API supported out of the box, so I'm hoping 
that Maolan will improve FreeBSD based studios once it's at least beta. Also, 
making APIs nicer to work with and documentation/examples better is what we as 
FreeBSD community must do if we want developers on other operating systems to be 
more portable and FreeBSD friendly. Over the past few years the community showed 
more interest in that area than I could ever imagine, so I am really grateful 
for being able to use a 12 year old desktop for everything including studio
recording, web conferencing and development with nothing but FreeBSD and
ports/packages it provides and no extra repositories.
