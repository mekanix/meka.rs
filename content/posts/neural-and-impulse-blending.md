+++
title = 'Neural and Impulse Blending'
date = 2025-07-15T00:35:00
tags = ['nam', 'audio', 'guitar']
+++

The idea of blending is to make two amplifiers and mix them into a single sound. The reason people
do that is because different amplifiers have slightly different sound which combined together sounds
better than any single one of them. It's the same like having a single voice vs choir. With sounds
it is simple: you just mix them. With neural amp modeler, there are few more steps. First you have
to [capture the sweep](/blog/2025/04/15/neural-amp-modeling/). Then you have to mix the captures
into a single track. To do it properly, you need to normalize the captures and lower the track's
volume to -5dB, because when two tracks combine the resulting volume will be bigger. If you mix more
than two tracks, you have to lower their volumes even more. Once you mix the captures into a single
clip, normalize it. After that all you have to do is create NAM profile out of that clip.

Mixing impulse responses is even easier. You [create the impulses](/blog/2025/05/11/impulse-response/),
mix them into a single clip and that's it. You have to watch out for the volume, that it doesn't
clip and normalize it in the end. Enjoy your sound!
