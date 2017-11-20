Title: FreeBSD Audio Workstation 0
Date: 2017-11-20 03:00
Tags: freebsd, audio
Author: meka


It's bad to start your post with an apology, but I must: this one won't deal
with FreeBSD as much as set some foundation for the posts to come.

The base for a good digital audio workstation, or DAW for short, is audio
interface. That is the piece of equipment that will do the most demanding task
of converting from analog to digital and vice versa. Since the audio that we 
are able to hear is, after all, analog one must pick it's audio interface a bit 
more carefully than the rest of the gear, so here are my tips on choosing a 
decent one:

- find as much as you can about it's ADC (analog to digital converter) and DAC
  (digital to analog converter)
- match impedance (more on that later)
- as high sample/bit rate as possible with internal mixer using more bits than
  ADC/DAC so it has room to handle clipping (common these days is 24/32 bits)
- ability to be world clock master and slave (more on that later)

Impedance is a fancy word for electrical resistance. It has to do with the fact
that resistance of a device is not the same in all circumstances. One of those
situations where this really matters is the equalizer: one band actually has 
lower resistance for a certain frequencies and higher for others. All I'm trying
to emphasize here is that when you here "impedance" you should think "resistance"
and keep in mind that it's dynamic.

One thing all electrical circuits like is when impedance of it's output matches
the one on the input of the next step. When I say "like", I mean least amount
of energy is wasted in transit from one circuit to another (read: you get more
signal/noise ratio) and the least amount of distortion is introduced
(unfortunately, every device adds some distortion). So, to have a perfect audio
interface, choose the one that has mic, line and hi-z inputs. Mic input should
have 48V option which is needed for condenser microphones (studio microphones).
Line is what most devices use, like mp3 players, other sound cards and synths.
Hi-z is just a fancy name for "guitar input". What you should look for with hi-z
is a active/passive switch. Active pickups have small amp inside them and need
battery, so they are easy to recognize. Passive pickups are the ones without
battery, and they have 3 to 9 times lower output than active ones (depending on
the chosen pair of active/passive pickups).

As digital audio IO must operate at the precise same frequency across all
devices, once you get guitar or vocal processor, you'll need to sync your audio
interface and processor. There are multiple ways for achieving that and it
mostly depends on the way you're going to connect the devices. Let me explain
why it's important. 

All digital devices use "the clock". It's what tells them "hey, it's time for the 
next sample" among other things. That clock is usually a quartz crystal which has 
a property of oscillating when electric current is introduced. When you have two 
devices with their own clocks, they have slight differences in frequencies which 
come from slight differences in crystals inside them. You might think "I don't 
care about few milliseconds" of delay, but that's not what's in stake here. If 
the digital device misses the clock beat, all of your audio can become gibberish 
and noise. This is solved by having devices that can use external clock as it's own. 

Obviously, one of the devices must "export" it's internal clock (acts as master) 
to other devices (slaves). S/PDIF and AES/EBU digital connections can also transmit 
the clock but you have to check your devices for such capabilities as not all can 
work this way. The safest option is to have World Clock on all of your devices, 
where your audio interface is the master. 

World Clock connector is BNC. It is especially important when you want to connect 
multiple devices to your computer (for example, via USB) as otherwise you'll get 
a lot of small errors known as jitters.

For someone who is just starting with audio, this may sound terribly boring, and 
too technical. If so please leave a comment and I will cover a part of this in my
next post. Stay tuned there is more to come!
