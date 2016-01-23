Title: Presonus Troubles
Date: 2015-05-23 22:00
Slug: blog/presonus-troubles


For some time now, I have problems with Presonus AudioBox 1818VSL. The problem
is the SPDIF input is muted. I tried this and that, I submitted an issue on
Presonus ticketing system and nothing helped. First, Presonus, you're morons.
Every new driver needs to update firmware on the device, too, and there is no
way you can update/downgrade driver without firmware or vice versa. Second,
Presonus, you're idiots. You've made USB compliant audio interface, only to
change the mode to non-complaint in the newest firmware, rendering the device
useless on GNU/Linux. Third, Presonus, you're imbeciles. The controls you get
with `alsamixer` is a joke. You can not mute/unmute digital inputs, for example.
This is not true, and this was my problem for months now. Once Debian is going
for reboot/shutdown, it saves the current state of audio interface to
`/var/lib/alsa/asound.state` file. Every time Debian loads this file, digital
inputs just stop working. And they so stop working, they don't even work on
Windows. What I had to do is uninstall driver on Windows, install new driver,
reboot, launch Presonus' mixer which says it has to update the firmware, fail,
update firmware again, uninstall driver, install old driver (version 1.1, which
has a firmware which is USB compliant) reboot, launch mixer, fail firmware
upgrade (which is actually downgrade), update firmware and than it works.

At first, I said "OK, I'll turn off Presonus before shutting down the PC", but
that's not good. I have to think too much for one simple shutdown. Later on, I
made `/var/lib/alsa/asound.state` link to `/dev/null`. That loaded garbage into
the audio interface (so, go through Windows procedure from hell once again).
Then I made `/var/lib/alsa` link to `/dev/null`. That solved the problem, but
I didn't like the solution. After countless days of poking, I realized that
amixer returns interesting result for one of the controls:

    amixer -c 1 get 'AudioBox 1818 VSL Clock Selector Capture Sw'
      Simple mixer control 'AudioBox 1818 VSL Clock Selector Capture Sw',0
      Capabilities: pswitch
      Playback channels: Front Left - Front Right - Rear Left - Rear Right - Front Center - Woofer - Side Left - Side Right - Rear Center - ? - ? - ? - ? - ? - ? - ?
      Mono:
      Front Left: Playback [on]
      Front Right: Playback [on]
      Rear Left: Playback [on]
      Rear Right: Playback [on]
      Front Center: Playback [on]
      Woofer: Playback [on]
      Side Left: Playback [on]
      Side Right: Playback [on]
      Rear Center: Playback [off]
      ?: Playback [off]
      ?: Playback [off]
      ?: Playback [off]
      ?: Playback [off]
      ?: Playback [off]
      ?: Playback [off]
      ?: Playback [off]

Wait a fucking minute!!! Something is off? Let's make it on:

    amixer -c 1 set 'AudioBox 1818 VSL Clock Selector Capture Sw' 'on,on,on,on,on,on,on,on,on,on,on,on,on,on,on,on'

Guess what? Every reboot works like a charm now. I have no idea why Presonus
reports these to be off on the first run, but that's the fix. If you have
similar problems, I hope this is the solution. Next, record album, finally!
