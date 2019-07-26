Title: FreeBSD Update
Date: 2019-06-25 13:03
Slug: freebsd-update
Tags: freebsd
Author: meka


As you might be comming from Linux background, like I am, you might not be
familiar with the FreeBSD update procedure. The main difference is that FreeBSD
has base system as one big component which is updated as a whole, plus it has
packages like any other Unix.

TL;DR
```
env PAGER=/bin/cat freebsd-update fetch
freebsd-version -ku
bectl create 12.0.3
freebsd-update install
reboot
```
Check if [there's a known migration problem](https://svnweb.freebsd.org/ports/head/UPDATING?view=markup).
```
pkg upgrade
reboot
```
**If you have jails, update them before last reboot**.

`freebsd-update` utility will tell you if there is anything to be fetched. If
there isn't, just ignore the rest of the commands, but if there is, you
probably want to know what is the current version using `freebsd-version`. The
-k and -u options stand for kernel and userland, respectively. Those version
can be different (only the patch level), so pick the higher one. In the example
above, that's 12.0-p3. If you're running on ZFS, you can use `bectl` to create
new boot environment out of the current one, so if update goes wrong, you can
still boot system with the previous version. The boot environment is ZFS-only
feature which allows for multiple root datasets which loader(8) knows how to
boot into. In a sense, it's like installing update and all the packages to new
root partition, every time. If you're not running your FreeBSD on ZFS, just skip
this step. Finally, we install the actual update and reboot, so the new kernel
and base system are loaded. As the final part, packages are updated.

If you have a machine you can not reboot for any reason and have access through
VNC, serial console or other non-network channels, you can run this:

```
env PAGER=/bin/cat freebsd-update fetch
freebsd-version -ku
bectl create 12.0.3
shutdown now
freebsd-update install
exit
pkg upgrade
```

The `shutdown` command will not power your machine off. It will bring it into
single user mode. In this mode, most processes are not running, only those to
enable basic terminal functionallity (and a bit more, but let's say nothing is
running). It will ask for root password and once the actuall update is finished,
`exit` will start the services like on fresh boot. The drawback is that kernel
updates are not activated, but you still profit from the updates to the
userland. As FreeBSD tries relly hard to maintain ABI compatibility on the patch
level, this is safe enough to do, but it is advisable to reboot once after the
update to load the new kernel.
