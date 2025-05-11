+++
title = 'Impulse Response'
date = 2025-05-11T10:56:00
tags = ['IR', 'audio', 'guitar']
+++

**DANGER!!! THE FOLLOWING PROCEDURE MIGHT CAUSE DAMAGE TO YOUR EQUIPMENT!!!**

I have power amp that has limiter, short circuit protection and overheating
protection, so I know my gear can handle the procedure, but please don't assume
that every combination of amp/cab is safe to be used! For example, I have no
idea how tube amps react to this procedure and you might burn the tubes. Please
be safe, first!

There is also a procedure using sweep frequencies, but I'll describe that in
another post. That procedure should be safe for any equipment.

## Dirac Pulse

Impulse response is used to emulate acoustic characteristic of the system. In
other words, it can emulate the sound of a guitar cabinet. It can also capture
reverb of a place, like hallway or church, but I'll just stick to guitar
cabinet emulation in this post. The core of this technology is in the title as
we will record how system, in our case power amp, cabinet and microphone,
responds when we feed it just a single impulse. That pulse is also called
"Dirac pulse". In the wav file, it would be single sample with full amplitude
and all samples before and after it are zero. It is said that such pulse
contains all frequencies with equal amplitude, but the math behind it deserves
a post on its own. Let's first generate such .wav file in audacity. First we
need a track to work on.

```
Tracks -> Add New -> Mono Track
```

Then we need some samples to work on. It's easiest if we generate 1 second of
silence and work with that.

```
Generate -> Silence
```

You'll need to zoom in as much as possible on X and Y axis. Now raise first
sample to the top and leave the rest on laying on zero. The result should look
like this.

<img src="/images/dirac.webp" alt="Dirac pulse"></img>

This clip actually has second sample raised and the reason I did that is because
it is hard to see first sample because of the clip edge. Save the project and
export as .wav.

## Capturing Impulse Response

In Ardour we will need two mono tracks. One will have the Dirac pulse we just
generated, second one will capture the output of the microphone directed at the
guitar cabinet. With PC I will mark computer + audio interface, just to make it
shorter.

```
PC (dirac) -> Power amp -> Cabinet -> Microphone -> PC (impulse response)
```

This means that dirac track should have its inputs disconnected and output
connected so it is fed to power amp. The impulse response track should have
all outputs disconnected and input connected only to the microphone.

There is a catch. To suppress pops and clicks that appear between two clips,
Ardour will add a small fade in to the start of the clip and fade out to the
end of it. This will "eat up" our Dirac pulse, so we have to disable that. Zoom
as much as possible until the curve for fade in/out is visible. Right-click on
the little square at the end of the curve and click on `Deactivate`. You have
to do that on captures, too.

<img src="/images/clip.webp" alt="Ardour clip"></img>

Do few test captures to check the levels and then start capturing impulse
responses. You can export the capture and open it in Audacity for trimming
start and end if needed. I also like to add very small fade out at the end.
For aligning the start of the clip I use `z` shortcut to find the zero crossing
in the clip and I delete the samples before that one. That way no delay is
introduced by impulse response. Save that project and export the .wav file.
That file is your IR! Congratulations, you just made your first IR!
