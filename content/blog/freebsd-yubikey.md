Title: FreeBSD and YubiKey
Date: 2022-07-20 10:27
Tags: freebsd, yubikey, auth, security
Author: meka


Install and initialize the services as root:

```sh
pkg install ccid opensc pcsc-lite
sysrc pcscd
service pcscd restart
```

Start ssh agent and add provider to it as user:

```sh
eval $(ssh-agent)
ssh-add -s /usr/local/lib/opensc-pkcs11.so
```

That's it, SSH should work with YubiKey now.
