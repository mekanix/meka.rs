Title: FreeBSD Linuxulator
Date: 2022-07-01 00:21
Tags: freebsd, linux
Author: meka


As some applications are Linux-only, it is very handy to have linuxulator
available. In short, I just followed 
[linux browser install](https://github.com/mrclksr/linux-browser-installer) and
added slack and viber with
[pulseaudio setup](https://forums.freebsd.org/threads/linuxulator-how-to-install-brave-linux-app-on-freebsd-13-0.78879/).
Although pulseaudio setup contains linux browser install, it is the most
important part. Once the browser was installed I copied the scripts to make
slack and viber working. After download of .deb file, chroot to linux directory
and install it.

```sh
cp <slack>.deb /compat/ubuntu
chroot /compat/ubuntu /bin/bash
dpkg -i <slack>.deb
apt-get install -f
```

On host, script is needed in PATH so it can be executed just like a normal
application, so `/usr/bin/slack` looks like this:

```sh
#!/bin/sh

get_pa_sock_path()
{
  PA_SOCK_PATH=$(sockstat | awk -v me=$(whoami) -F'[ \t]+' '
    $1 == me && $2 == "pulseaudio" && $6 ~ /native/ {
      print $6;
      exit 0
    }'
  )
}

get_pa_sock_path
[ -S "$PA_SOCK_PATH" ] && export PULSE_SERVER=unix:$PA_SOCK_PATH

/compat/ubuntu/bin/slack $@
```

Next, we need to create `/bin/slack` inside ubuntu chroot:

```sh
#!/compat/ubuntu/bin/bash
#
# chrome wrapper script from patovm04:
# https://forums.freebsd.org/threads/linuxulator-how-to-run-google-chrome-linux-binary-on-freebsd.77559/
#
export SLACK_PATH="/usr/bin/slack"
export SLACK_WRAPPER="$(readlink -f "$0")"
export LD_LIBRARY_PATH=/usr/local/steam-utils/lib64/fakeudev
export LD_PRELOAD=/usr/local/steam-utils/lib64/webfix/webfix.so
export LIBGL_DRI3_DISABLE=1
exec -a "$0" "$SLACK_PATH" --no-sandbox --no-zygote --test-type --v=0 "$@"
```

Final change is to `/usr/share/applications/slack.desktop` inside ubuntu chroot:

```sh
[Desktop Entry]
Name=Slack
StartupWMClass=Slack
Comment=Slack Desktop
GenericName=Slack Client for Linux
Exec=/bin/slack %U
Icon=/usr/share/pixmaps/slack.png
Type=Application
StartupNotify=true
Categories=GNOME;GTK;Network;InstantMessaging;
MimeType=x-scheme-handler/slack;
```

**Note: Exec line is wrong by default for linuxulator environment. The
executable needs to be our script `/bin/slack`, not the slack binary itself
`/usr/bin/slack`.**

The trick is to execute `pulseaudio --daemonize` on FreeBSD host before
starting slack. I got audio and webcam working. Of course, viber setup is the
same.
