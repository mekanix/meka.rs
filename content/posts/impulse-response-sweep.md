+++
title = 'Impulse Response Sweep'
date = 2025-05-12T08:55:00
tags = ['IR', 'audio', 'guitar']
+++

There is another way to capture IR, and it is using sweep frequency sound. That
means that the file containing the sweep will have 20Hz to 20kHz frequencies,
starting with low and increasing the frequency. The idea is to capture how the
system, in this case power amp, guitar cabinet and microphone, respond to
different frequencies and create IR based on that. For that purpose you can use
Carla and LSP Profiler. I like to use mono version, but the stereo version is
available if you need it. You need to start Carla and add LSP Profiler as a
plugin. In patch bay of Carla connect it like the following picture.

<img src="/images/carla.webp" alt="Carla"></img>

In program like QJackCTL connect Carla's IO to the hardware IO. As for the
hardware setup and connections, consult the
[previous post about impulse resposes](/blog/2025/05/11/impulse-response/).
First we need to calibrate the LSP Profiler. That means setting the right sound
levels and latency.

<img src="/images/profiler.webp" alt="LSP Profiler"></img>

Turn the volume down on your power amp before you enable `Calibrator`, as it
sends loud signal, then enable it and turn the volume gradually up until you
get around -3dB. When satisfied with the levels, disable it. Click `Measure`
in the `Latency Detector`. It will send pulses of sound to figure out what is
the round trip time for the sound. In the `Test Signal`, increase `Coarse
Tuning` to be as long as possible. When all is set, press `Profile` button.
It will start with a pulse, then few seconds of silence, then sweep sound
through 20-20000Hz range. Once the LSP Profiler captures the sound from the
microphone, it will need up to few seconds to make an actual IR profile. When
that's done, press `Save` and create your .wav file.

I have to note that quality of such IRs is lower than those I did with Dirac
pulse. As I am still new to this I assume I'm not tuning something right as
these two techniques should produce the same result.

### Related posts

* [Impulse Response](/blog/2025/05/11/impulse-response/)
* [Neural Amp Modeling](/blog/2025/04/15/neural-amp-modeling/)
