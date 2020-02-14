Title: FreeBSD and USB MIDI
Date: 2017-06-17 23:37
Slug: freebsd-usb-midi
Tags: freebsd, audio, midi
Author: meka


The problem I was having was that I could record MIDI, but not send it to
hardware output. For impatient, just run `chmod o+rw /dev/umidi*`. Yes, it was
that stupid and it took me few days to realize what's the problem, so let's go
through my setup and debug process. It will be fun, I promice.

I never used hardware MIDI before, although I used software MIDI for various
things for years, so I have a rough feeling how things should work. Anyway, I
have a footswitch (Behringer FCB1010) MIDI out into USB audio interface
(Presonus AudioBox 1818VLS) in. Then `jack_umidi -d /dev/umidi0.0` exposes
hardware MIDI ports as jack MIDI ports. You can use `jack_lsp` to display all
jack ports and `jack_connect <out> <in>` to connect whatever is coming from
input to output and make your audio interface act as MIDI thru. That way I use
Presonus as a "proxy" between FCB1010 and my guitar processor (Line 6 POD X3 Pro)
in order to be able to record controls at the same time as I record dry guitar.
I noticed that if I remove Presonus as proxy, controls work, but with it I
couldn't get it to work. I tested to make sure jack is emitting MIDI messages
all, and it did. I tested hardware using my wife's laptop and Linux, and that
worked. At that point I realized it can be too many things, as I have too much
apps in my setup, so I decided to make it as simple as possible: write a MIDI
program in C based on [synth example](http://manuals.opensound.com/developer/softsynth.c.html).
To be precise, I wanted to use the `open_midi_device` and then whatever I read
from it, I write to it back. The dumbest MIDI thru ever! Given example uses MIDI
device in read only mode, but I needed read/write. Once I tried to alter it, I
got `Permission denied`. Looking at /dev/umidi0.0 permissions, no wonder, because
it's owner is root, group is operator and it's mod is 644. To make this right,
add this rules to `/etc/devfs.rules` (create if it doesn't exist):
```sh
[localrules=5]
add path 'umidi*' mode 0666
```
To make those rules active, add `devfs_system_ruleset="localrules"` to
`/etc/rc.conf`. On next reboot everything will be just fine.

Have fun with the MIDI!
