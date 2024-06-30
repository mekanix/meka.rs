+++
title = 'FreeBSD and YubiKey'
date = 2022-07-20T10:27:00
tags = ['freebsd', 'yubikey', 'auth', 'security']
+++


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
