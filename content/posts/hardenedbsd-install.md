+++
title = 'HardenedBSD Install Over Serial'
date = 2018-08-13T00:45:00
tags = ['hardenedbsd', 'router']
+++


If you have APU or similar router, it's a big chance you'll need serial console
install procedure. You'll have to mount install image before booting and change
/boot/loader.conf so it includes the lines to use serial console:
```sh
boot_multicons="YES"
boot_serial="YES"
comconsole_speed="115200"
console="comconsole,vidconsole"
```
When the machine boots, it will ask you for prefered console type. Default
(vt100) is just fine. The rest of the installation is just like on the normal
machine, but you'll have to modify /boot/loader.conf on the newely installed.
Reboot, and boot off of USB key once again with the same procedure, but go into
shell, instead of install.
```sh
mkdir /tmp/install
zpool import -R /tmp/install -f zroot
zfs mount zroot/ROOT/default
```
Now write the same lines for serial console to /tmp/install/boot/loader.conf and
you should be set.
