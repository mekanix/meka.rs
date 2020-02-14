Title: CBSD Base Upgrade
Date: 2019-11-18 19:36
Slug: cbsd-base-upgrade
Tags: freebsd cbsd
Author: meka


Upgrade in CBSD means the same as in FreeBSD: increse only in patch version.

```sh
cbsd baseupdate
service cbsd restart
```

For upgrade you need to stop the jail, set it to new base and start the jail.
```sh
cbsd jstop nginx
cbsd jset jname=nginx ver=12.1
cbsd jstart nginx
```

CBSD will ask you how do you want new base files to be fetched, and default is
to download them. Other options include compiling from code and using host
system files as new base. If you upgrade more then one jail, the first
`jstart` will create base jail for the rest to use.

Once you've upgraded all your jails, it's time to cleanup
```sh
cbsd removebase ver=12.0
```
