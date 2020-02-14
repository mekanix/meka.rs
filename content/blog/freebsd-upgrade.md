Title: FreeBSD Upgrade
Date: 2019-11-18 19:12
Slug: freebsd-upgrade
Tags: freebsd
Author: meka


Upgrade in FreeBSD world means having a host on version 12.0 and doing similar
procedure like in [FreeBSD update](/blog/freebsd-update), but ending up with a
major or minor version number incresed, not patch version number.

TL;DR
```sh
env PAGER=/bin/cat freebsd-update upgrade -r 12.1-RELEASE
freebsd-version -ku
bectl create 12.0.11
freebsd-update install
reboot
freebsd-update install
reboot
pkg upgrade
freebsd-update install
reboot
```

`freebsd-update` utility will tell you if there is anything to be fetched. If
there isn't, just ignore the rest of the commands.

First, using `freebsd-version` and `bectl` you create a boot environment for
the current version of FreeBSD. Then, first install will update only kernel.
As FreeBSD kernels are backward compatible, your system can boot with newer
kernel then the rest of the operating system. Second install will take care of
FreeBSD base. If everything is OK, after another `reboot`, you should upgrade
packages for the new OS version and run finall install which will take care of
known package problems. The last `reboot` is there to ensure everything is
working OK, as you might have some kernel modules, like drm-kmod, which are
changed during the upgrade.
