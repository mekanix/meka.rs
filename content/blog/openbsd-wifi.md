Title: OpenBSD WiFi
Date: 2015-08-18 22:00
Tags: hacking, bsd, apu

I'm a proud owner of [APU](http://pcengines.ch/apu.htm). I'm currently running
OpenBSD on it. It's pretty [simple config](https://github.com/mekanix/openbsd-config).
Everything was "working" until I decided to tighten the screws on the device, as
I purchased a new screwdriver. Since then, WiFi is terribly slow. I had ~2s
delay between pressing a key and seeing character when logged in over ssh from
laptop to desktop. So, I've disassembled the device and assembled it all over
again, but no luck. Then I realized that I'm using 11b mode. Switching to
[11g and priority 0](https://github.com/mekanix/openbsd-config/commit/08cb7e40cb1f67e446d6255327661af9aeb87f4b)
made it all working well. SSH is more responsive and
[speed test](http://speedtest.net) shows 10Mbit/s instead of ~5Mbit/s it showed
previously. I've learned my lesson.
