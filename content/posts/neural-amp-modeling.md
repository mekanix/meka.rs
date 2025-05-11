+++
title = 'Neural Amp Modeling'
date = 2025-04-15T13:30:00
tags = ['nam', 'audio', 'guitar']
+++

## Re-amping

Let's say you're a guitar player and want to record your track of a song.
Typically you would enter the studio with your guitar, amp and cabinet and
record what's needed. But let's say you decide to record your guitar without
any processing by pedals or amps, glue the good takes together and then
process that track with pedals and amps. That process is called re-amping.

Now let's say you want that guitar track processed by a plugin, not hardware.
The process of recording would be almost the same, but the process of getting
the plugin to sound like an amp is quite a challenge. Today if we want to
emulate the whole rig, it is best if it's done in two parts: NAM and IR. IR is
much older, and it stands for Impulse Response. NAM stands for Neural Amp
Modeler and it's just a few years old. IR is used to capture the sonic
characteristic of reverb and guitar cabinets, the most. It can do other things,
but for now let's just say that IR in our case is used to emulate guitar
cabinets. NAM in our case is used to capture and emulate preamp. It can also
capture full rig but you can't use any effects that are time based, like
reverb or delay. The reason why I like NAM for preamp and IR for cabinet is
because that way I can use IR cabinets captured over past two decades. As NAM
is relatively new, it still doesn't have such a huge ecosystem.

## Preamp and NAM

One of the great things that came out of AI hype is [Neural Amp Modeler](https://www.neuralampmodeler.com/),
or NAM for short. To capture NAM, you have to separate preamp from the rest of
the gear. As stated before, you can capture NAM of your whole rig, but today I
want to capture just the preamp. In my case it is Engl E570. It's pretty rare
so I'd like to be able to replace it with a NAM loader pedal (hardware pedal
that loads NAM and emulates my preamp). If you'd like to profile preamp that is
part of amp head or combo, you'll need to use FX loop. To be precise, you'll
use Send on the FX loop as that is the preamp's output. What is needed for that
beside preamp is audio interface, computer and re-amp box. My choice of
operating system is FreeBSD, but once you have JACK configured, the rest is the
same as Linux. On the mentioned computer I will use JACK and Ardour to capture
the sound of preamp. Computer is connected to audio interface via USB, and in
my case it is Presonus AudioBox 1818VSL. It has line level outputs, which is
almost exclusively the case on audio interfaces, so I can't just plug it's
output to the preamp's input. The impedance and signal level of line output do
not match those of the guitar input on the preamp. To convert line to guitar
level, I am using Radial Engineering EXTC-Stereo. It has inputs and outputs on
one side, which are connected to the audio interface, and send and receive on
the other side, which are connected to the preamp. To be precise, audio
interface output is connected to EXTC, send of EXTC is connected to preamp
input and preamp output is connected to audio interface (line in). If I call
computer + audio interface just PC to make it short, this would be the
"diagram" of connections

```
PC -> EXTC -> preamp -> PC
```

What we want is to send a signal from the PC, process it with the preamp and
send it back to PC for analysis. To do that, create Ardour session at 48kHz and
create two tracks with names "sweep" and "capture". Both tracks need to be mono.
Connect sweep's JACK output to the output on the interface which is connected to
reamp box. Connect capture's JACK input to the input on the interface which is
connected to the preamp. That way you can record the output of preamp in capture
track and play some signal on the sweep track. Sweep is the term left from IR,
and I will explain why it's called that in the follow up post. For now all you
need to know is that it's not "normal" sound, it is a signal created so that AI
can learn from it. To be precise, AI will learn from sweep and captured signal
and it will produce information how to digitally transform the sound so it is
the same as if we just did the reamp. Input on sweep track needs to be
disconnected and output on capture track, too. That way we are minimizing causes
of eventual problems. To get the sweep signal, go to [tone3000](https://tone3000.com/capture)
and download "sweep signal" from the page (downloaded file will be called
T3K-sweep-v3.wav). Now all you need to do is arm your capture track and record
the output of the preamp while the sweep signal is fed to the preamp's input.
Once that's done, align start and end of sweep and captured clip. Also, set
session start and end to the clip's start and end. Normalize the captured clip.
Now we need to export sweep and capture to separate, mono files at 48kHz and
24bits. To do that, go to

```
Session -> Export -> Stem Export
```

If you don't already have a format for 48kHz (or session rate) at 24bits,
create one. We need wav files that are in no way further processed. That means
disable trimming and normalization. In the `Time Span` tab select `session`
range and only that one. In the `Channels` tab, select sweep and capture track
and disable `Apply track/bus processing`. Now export the track to wav files.

Go to [tone3000's capture](https://www.tone3000.com/capture?type=dry-wet) and
upload dry (sweep) and wet (capture) wav files. Follow the form and wait for AI
to process all epochs (100 by default). Once that's done, you'll have NAM file
published on Tone3000 platform. Congrats!


## Tips

For better performance I suggest compiling jack from ports with SOSSO library
enabled. It can dramatically reduce DSP usage in JACK/Ardour.

To test your NAM you can use `neuralrack-lv2` to load it together with some IR.
Nice thing is that [tone3000 already has some IRs](https://www.tone3000.com/search?gear=ir),
so download some and test it in `neuralrack-lv2`.

While there is also a way to only [upload the capture](https://www.tone3000.com/capture),
it never worked for me. The reason is that I couldn't make Ardour produce the
exact same number of samples in the capture file, that the sweep file has. With
stem export, tracks are exported to files with the exact same length. Briefly
talking to Tone3000 support, they told me that input signal should be uploaded
only if custom signal is used to train the AI. I would love to not waste
resources by uploading both files, but I always get an error while producing
the NAM if I upload only the capture.

### Related posts

* [Impulse Response](/blog/2025/05/11/impulse-response/)
* [Impulse Response Sweep](/blog/2025/05/12/impulse-response-sweep/)
