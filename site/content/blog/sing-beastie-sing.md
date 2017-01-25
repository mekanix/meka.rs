Title: Sing, beastie, sing!
Date: 2017-01-25 19:00
Tags: freebsd, music, audio, real-time
Author: meka


FreeBSD digital audio workstation, or DAW for short, is now possible. At this
very moment it's not user friendly that much, but you'll manage. What I want to
say is that I worked on porting some of the audio apps to FreeBSD, met some
other people interested in porting audio stuff and became heavily involved with
DrumGizmo - drum sampling engine. Let me start with the basic setup.

FreeBSD doesn't have hard real-time support, but it's pretty close. For the
needs of audio, FreeBSD's implementation of real-time is sufficient and, in my
opinion, superior to the one you can get on Linux with RT path (which is ugly,
not supported by distributions and breaks apps like VirtualBox). As default
install of FreeBSD is concerned with real-time too much, we have to tweak sysctl
a bit, so append this to your /etc/sysctl.conf:

```
kern.timecounter.alloweddeviation=0
hw.usb.uaudio.buffer_ms=2 # only on -STABLE for now
kern.coredump=0
```

So let me go through the list. First item tells FreeBSD how many events it can
aggregate (or wait for) before emitting them. The reason this is the default is
because aggregating events saves power a bit, and currently more laptops are
running FreeBSD than DAWs. Second one is the lowest possible buffer for USB
audio driver. If you're not using USB audio, this won't change a thing. Third
one has nothing to do with real-time, but dealing with programs that consume
~3GB of RAM, dumping cores around made a problem on my machine. Besides, core
dumps are only useful if you know how to debug the problem, or someone is
willing to do that for you. I like to not generate those files by default, but
if some app is constantly crashing, I enable dumps, run the app, crash it, and
disable dumps again. I lost 30GB in under a minute by examining 10 different
drumkits of DrumGizmo and all of them gave me 3GB of core file, each.

If you have audio interface with more than 8 channels, you'll need virtual_oss
and virtual_oss_ctl. The decision was made that more than 8 channels of audio
are more suitable to be mixed, resampled and generally processed in user space.
[My rc script](https://github.com/mekanix/virtual_oss_rc) for virtual_oss is
still pending, as I just can't find the time to work on it. Copy virtual_oss
from that repo to /usr/local/etc/rc.d and it will start virtual_oss assuming
your audio interface has 18 channels. You have to add `virtual_oss_enable="YES"`
to your /etc/rc.conf and you can alter the arguments by adding your own
`virtual_oss_flags="..."`. For example, take a look at the rc script, as it has
default value of virtual_oss_flags.

Next is my jack setup, which is oneliner:

```
# jackd -r -d oss -r 96000 -C /dev/vdsp.jack -P /dev/vdsp.jack -i 18 -o 18
```

I'm not using real-time for jack, as it's not supported for a non-root process
to raise it's priority to real-time. You can do that by
`sudo rtprio 10 -(pgrep jackd)`.

Currently, Ardour 5.5 and DrumGizmo are in conflict.
[Our hackerspace forked FreeBSD ports](https://github.com/tilda-center/freebsd-ports)
and added a quick patch for Ardour which removes the conflict. I talked to the
maintainer of the port about it and he's working on a proper patch and will try
to push it upstream, to Ardour developers.
.

As there are some resampling problems with virtual_oss, you're advised to use
PulseAudio (not my favorite solution) by telling it to use virtual_oss. You'll
have to add the following to the /usr/local/etc/pulse/default.pa:

```
load-module module-oss device="/dev/vdsp.jack" sink_name=output source_name=input
```

And just for the reference, this is my virtual_oss config:

```
virtual_oss_enable="YES"
virtual_oss_flags="-S -i 8 -C 18 -c 18 -r 96000 -b 32 -s 384 -f /dev/dsp0 -c 2 -d dsp -c 18 -d vdsp.jack -t vdsp.ctl -M i,0,8,0,0,0 -M i,0,9,0,0,0"
```

* -S: enable resampling
* -i: enable real time
* -c/-C: 18ch in/out
* -r: sampling rate
* -b: bits
* -s: size of buffer
* -d: virtual oss device to create
* -t: virtual oss control device to create
* -M: mirror first input to outputs 8/9

The reason I mirror first input (input zero) to 8/9 is because I use my first
input for guitar, and outputs 8/9 are towards guitar processor. With this setup
I can play OSS, JACK and PulseAudio sound all at the same time, which I was not
able to do on Linux.

Now sing, beastie!
