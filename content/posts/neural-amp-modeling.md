+++
title = 'Neural Amp Modeling'
date = 2025-04-15T13:30:00
tags = ['nam', 'audio', 'guitar']
+++

One of the great things that came out of AI hype is [Neural Amp Modeler](https://www.neuralampmodeler.com/),
or NAM for short. In essence the process is simple: take sweep sound that the AI is trained with
and reamp your gear with it. Connect your preamp to your audio interface (you might need reamp box,
depending on your interface's in/out impedance and levels), record output of your preamp while it's
input is the sweep sound. To be perfectly correct it is not sweeping, but it's term that is used in
creation of Impulse Response or IR for short. I found that the easiest way to create NAM is to go to
[tone3000](https://tone3000.com/capture) and download "sweep signal". Make sure your ardour session
is set to 48kHz. Import the downloaded audio file (T3K-sweep-v3.wav at time of this writing) into a
track that has all inputs disconnected and only one output connected: the one you use to connect
your audio interface to preamp. Create one more track, disconnect all its outputs and only connect
the input to the one where your preamp's out is connected. Record the output of your preamp and
align start and end of sweep and recorded clip in their tracks. Normalize the recorded clip and go
to Session -> Export -> Stem Export and choose sweep and recorded tracks. Choose to export the files
in 48kHz 24bit format. The reason is that no matter what I did, I couldn't produce output wav file
to be the same size or "shape" (signals were out of sync) if I export just recorded track. With stem
export, both of the resulting wav files are going to be exactly the same length. Go to
[tone3000's capture](https://www.tone3000.com/capture?type=dry-wet) and upload dry (sweep) and wet
(recorded) files. For better performance I suggest compiling jack from ports with SOSSO library
enabled. It can dramatically reduce DSP usage in jack/ardour. Once you have your .nam file, you can
use `neuralrack-lv2` to load it together with some IR. I will write about IRs some other time, until
then, have fun!
