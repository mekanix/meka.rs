---
layout: post
title: PCEngines APU
tags:
  - networking
  - pfsense
---

I had TP-Link provided by ISP for years, and I never bothered to replace it. It 
does work, but sometimes it's just a pain in the ass. For example, the closer 
my laptop is to the router, more packet drops I have. I finally decided to grab 
a new router, and, of course, I got an "underground one". I mean, who ever 
heard of PCEngines? Their model APU has variant with 4GB of RAM. Impressive, 
right? :o) There is no particular reason I decided for 4GB. It was there and I 
didn't want to think what I can and can't do. It's loaded with 16GB SSD hard 
drive and Atheros WiFi card with 2 antennas. It has 3 gigabit ports and serial 
console. ALIX, former model had VGA, also, which made things much easier, 
because finding null terminated USB to RS232 cable is near to impossible (thank 
you [KT](http://www.ktehnika.co.rs/)). So, I grabbed pfSense USB image with 
serial console, dd'ed it to USB stick and install is pretty straight forward.

Let's take a step back. You get all the pieces and it's not tricky to assemble 
it if you follow [instructions](http://www.pcengines.ch/apucool.htm). Trust me, 
it's not hard even the first time (I've never had anything similar before). For 
pfSense installation, follow [Gooze 
instructions](http://www.gooze.eu/howto/pfsense-installation-on-alix-apu-board-h
owto) and you're set. Next few tips are just to get you there easier.

First, APU's serial port is on baud of 115200, and pfSense installation is on 
baud of 9600, so you boot on one baud, configure device, switch to lower baud, 
do the installation of pfSense and switch back to higher baud. Once you install 
the device, you don't have to change baud ever again. Second "trick" is that in 
order to use WiFi card as AP, you have to assign ath0 interface as optional 
interface, then rename OPT1 to WIFI in order to find it easier in the future, 
and configure the same filter rules like those for LAN. That should be enough 
for you to start using WIFI. On software side, you only need minicom configured 
with /dev/ttyUSB0 on your laptop, and pfSense installation. Hardware: USB 
stick, APU, USB to RS232 converter and F2F (meaning "female to female") serial 
cable. Have fun! :o)
