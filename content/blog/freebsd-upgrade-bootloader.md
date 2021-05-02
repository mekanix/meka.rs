Title: FreeBSD Upgrade Bootloader
Date: 2021-04-16 14:23
Tags: freebsd
Author: meka


**WARNING: Not tested on dual boot machines and probably doesn't work**

The recommended partitioning layout is to support BIOS and UEFI. The following
is GPT partitioning (could be MBR in this simple example). Notice that the 
first two partitions are EFI and BIOS boot partitions. The EFI partition is 
nothing more than a FAT partition in most cases.

```sh
gpart show
=>       40  500118112  ada0  GPT  (238G)
         40     532480     1  efi  (260M)
     532520       1024     2  freebsd-boot  (512K)
     533544        984        - free -  (492K)
     534528    4194304     3  freebsd-swap  (2.0G)
    4728832  495388672     4  freebsd-zfs  (236G)
  500117504        648        - free -  (324K)
```
To see current UEFI settings like which disk/partition/file is configured for
booting, run the following:

```sh
efibootmgr -v
BootCurrent: 0019
Timeout    : 0 seconds
BootOrder  : 0019, 000A, 000C, 0006, 0007, 0008, 0009, 000B, 000D, 000E, 000F, 0010, 0011, 0012, 0013
+Boot0019* FreeBSD HD(1,GPT,0a7e1ccc-8826-11eb-b711-f0def164c22a,0x28,0x82000)/File(\efi\freebsd\loader.efi)
                      ada0p1:/efi/freebsd/loader.efi (null)
# A LOT OF LINES REMOVED
```

Write disk (pmbr) and second partition (gptzfsboot) boot codes. If you're using 
UFS instead of ZFS, change gptzfsboot to gptboot.

```sh
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 2 ada0
# if not mounted, mount efi partition under /boot/efi
# in my case, that's adaop1, as efibootmgr reported
cp /boot/loader.efi /boot/efi/efi/freebsd/loader.efi
```
