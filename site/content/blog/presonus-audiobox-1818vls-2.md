Title: Presonus Audiobox 1818VLS 2
Date: 2014-12-15 22:00
Slug: blog/presonus-audiobox-1818vls-2


And it finally arrived. First, right channel on the headphones didn't work. I 
made a peace with myself that I have to spend some more money for sending it to 
Thomman to replace it with a working one. I tried everything that came to my 
head and couldn't figure out what's wrong. As my friend brought it for me, we 
were not at my home, so on the way home I figured out that I didn't check the 
pan. While unpacking it, there was a trillion of "please be the pan" prayers. 
I've connected it, fired it up, and everything was just working. I still have 
no idea how or why. And now for the technical details.

The reason I wanted this card is because it's the only USB 2.0 audio interface 
that is seamlessly supported under GNU/Linux that I know of. You just plug it 
in, start JACK, and you have 18 inputs and 18 outputs. Just so you know, 1+2 
outputs are the main, 7+8 are headphones and 9+10 are S/PDIF. As for inputs, 
9+10 are S/PDIF and the rest is as it's numerated. My setup is that in first 
input I have my guitar (1st and 2nd are mic/instrument combo, others are 
mic/line). The guitar is always routed to S/PDIF output, and that output goes 
to my guitar processor's (Line 6 POD X3 Pro) input. S/PDIF output of POD is 
returned into S/PDIF input on the card. This setup enables me to record dry and 
wet guitar at the same time, as POD always gets it's input from Presonus, I 
never have to change inputs or outputs with it, and I can reamp dry tracks. One 
of the problems I had with a previous setup was that audio card didn't have 
guitar input, so I had to use POD for everything. This means, that while 
recording dry guitar, I would listen to analog output of POD with full 
simulation of amp for monitoring, and send dry signal through S/PDIF. Once I 
record it, I had to switch input to S/PDIF, which is the last item on the menu 
where you choose your input. Guess what's the first option: guitar input, of 
course. So I spent a lot of time going back and forth through the menu which 
doesn't go to first item once you've passed the last one. What a hassle! And 
that's not enough. Because previous card, M-Audio Delta 1010LT can not be 
worldclock master, I had to switch the master every time I wanted to switch to 
"studio mode" or back to normal mode. Switching to studio means POD is the 
master, I switch to S/PDIF sync on Delta and everything works. The trouble is 
going back, because you can't just switch the sync source. You have to stop 
JACK, switch the sync source, start JACK and start all programs that don't 
handle JACK stopping well. If I just power off POD while it's sync master, 
Delta just dies. One reboot later you're good to go. That was a pain! Now I can 
even bring my studio anywhere and record. That means that I can finally have 
the same setup and latency no matter where I record (we used my guitar player's 
laptop and audio interface for vocals).

Now for some fine tuning. First, every USB interface should have 3 as number of 
periods, compared to all other interfaces which have 2. You really want 
linux-image-lowlatency. My stable setup with a xrun now and then dropped from 
10.5ms to 2.7ms. On 10.5ms you can notice the latency if you play something 
fast, and we do. Of course, I use maximum sampling frequency of 96k. I 
recommend using KXStudio repository, Cadence for JACK management, Ardour3 for 
recording and SoundCloud for sharing tunes. Hear ya soon!
