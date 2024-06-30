+++
title = 'DIY Sound'
date = 2023-08-12T10:46:25
tags = ['audio', 'sound', 'diy']
+++


Sometimes you just hate what industry has don with the sound and start building
your own stuff. For one, I didn't like open source DAW alternatives as all of
them are missing something: Arour's MIDI is terrible for electronic music, loop
recording is missing in Muse, ZRythm is stereo only and I couldn't find how to
work with QTractor and DrumGizmo. To learn about audio and DSP, I started work
on Maolan. Today Maolan is still extremely experimental, but I learned a lot
and I plan to work on it as free time permits. I could have started with JACK
as first supported backend, but I decided to go with FreeBSD's OSS and really
understand what's going on there. Today I'm on the verge of understanding it
all perfectly from user space perspective. I am not as good kernel developer,
but I do intend to optimize FreeBSD's OSS and other code that is part of audio
stack. For example, currently USB audio driver has minimal buffer size of 2
miliseconds. Not bad, but USB docs say it works in 1ms frames with 8 subframes
which are 125us or microseconds. Lowering that will be piece of cake, but I'm
waiting for 14-STABLE to branch off so I don't sneak in buffer limit which is
not tested enough. As OSS, at least in FreeBSD, uses double buffer: one user
facing, one hadware facing, it would be interesting to see what optimizations
are possible if we would expose controls for hardware facing buffer. You see
where I'm going with this. There's work to be done to make FreeBSD more
real-time.

But software and PC in general is just a half the story. Audio interface and
hardware audio devices are the other half. Today USB audio is hard to work with
on any operating system. That 1ms frame of USB makes sure that latency is at
least 1ms. Using PCIe lowers that, but developing such card is way too hard for
me. My plan/workaround is to build USB sound card with very high sampling rate.
I will start with 384kHz and some of-the-shelf solutions to support it. List of
items I'm waiting to arrive:

* [AK4458VN DAC](https://www.akm.com/us/en/products/audio/audio-dac/ak4458vn/)
* [AK5578EN ADC](https://www.akm.com/us/en/products/audio/audio-adc/ak5578en/)
* [Programming Adapter](https://www.ebay.com/p/1839170567?iid=251702918057)
* [MCHStreamer Kit](https://www.minidsp.com/products/usb-audio-interface/mchstreamer)

If you look at AD/DA converters, you'll notice that they can do 32bit @ 768kHz.
That will be my next step, after all these parts start working together. The
ultimate goal is to make DIY high end audio interface that has one less digit
in the price. For example, if I didn't need 2 programming adapters, that would
be more than 200e less on the price. The reason I'm getting it anyway is
because I can't solder that precisely, yet. I would love to program some MCU
and USB PHY using NuttX and using more general board instead of MCHStreamer,
but I'm not there yet. In order to get to 768kHz, I have to replace it anyway,
so I'm sure I will get there eventually. If all that work gives latency less
than 6ms, I finally have real-time using USB. Also, if I have all that, how
hard will it be to make PCIe alternative? I know it will be much faster, and
with it I might go to latencies like 2ms which give you freedom to patch things
any way you want, like microphone into the interface, have it recorded and
pushed to output which is connected to hardware vocal processor and then again
back to the interface, and then ... The point is that every time you go through
sound card you add those 2ms which means you can do it 3 times and still be
called real-time. And maybe I won't do that but build digital mixer which will
route sound internally and it won't even need a computer do work. Of course, I
will have USB interface on it, because I do want to record it in the end.

Reading about AD/DA, I stumbled upon DSD format which they say is superior to
PCM. Let me briefly explain. PCM is what we are usually thought is digital
sampling. It's how CD works, for example. Every 1/44100 of a second, level of
signal is measured and it is represented with a number. That's what the name
stands for: Pulse Code Modulation or PCM for short. DSD works differently. I
only uses one bit to represent the sample. Weird, right? The idea is that one
bit is enough to represent if the current sample is higher or lower than
previous one. Done at a high frequency, for example >10MHz, you can easily see
that it follows audio signal more accurately. At least that what I read on the
Internet. Now here's an idea. If I get my sound interface working in DSD mode,
and write a patch for FreeBSD OSS so it handles DSD natively, and use DSD WAV
files to record the input, I'm hoping to capture audio more accurately. I don't
know how much difference it will make but today that's the best what the
industry can offer, yet can't use it as no interface today is built like that.
I mean, I'm not the first to come up with this idea, for start Denoy used same
AD/DA until the shortage, so the components are field tested, I'm not
interested in revolutionizing anything. What I mean is that the components I
listed are on the market for years and are being used by audio companies for
years, so I know I can do it, it's just my first prototype so I can't really
say how or when.

My dear reader, I have a question. Would you support such a project by funding
it? If no, why? If yes, what amount? To be more precise, would you fund my work
on everything I just described if I promise that USB audio interface I just
described will cost around 200e (with current prices) if you exclude shipping,
you would have to solder it and get parts but you get the whole KiCAD project,
all code open source and based on NuttX? If you just had "yes to all" moment,
let me ask additional question. Once all this is done, would you fund work to
make it USB 3 compatible? As USB 3 has much higher bandwidth, the interface
could have much more channels, in or out. I'm talking about 32in, 32out, if
your PC can cope with it.

Please let me know what you think. I prefer email as it's easiest to sort and
archive of all communication channels, but you're free to pick whatever you
like to contact me.
