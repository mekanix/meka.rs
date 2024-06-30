+++
title = 'OpenLDAP Multimaster'
date = 2020-03-25T23:41:00
tags = ['openldap', 'multimaster', 'authentication']
+++


One thing I can tell you about email servers is that I'm really dumb to set it
up properly. I'm mail admin since 2006 and 14 years later I still don't know
how to do it. I mean, yeah, I do run a mail server and it does work, but it's
far from satisfying, but that's not what I want to talk about in this post. I
want to talk about one part of email server: OpenLDAP.

You can think of OpenLDAP, or just ldap for short, as a lightweight database
for users and groups. The reason I chose ldap over SQL is that it's less
resource hungry while being really flexible. One drawback is that it's
complicated as hell. Not the software or configuration itself, but errors are
usually misleading (at least to me). On top of that, although I knew OpenLDAP
supports N-way multimaster, I never found any decent documentation on how to
actually configure a cluster. So in short, this is the configuration that works
on my server:

```sh
ServerID        3 "ldap://ldap3.domain.tld"
moduleload      syncprov
overlay         syncprov
syncprov-checkpoint     10 1
syncprov-sessionlog     100
syncrepl        rid=31
                provider="ldap://ldap1.domain.tld"
                type=refreshAndPersist
                schemachecking=on
                retry="5 10 30 +"
                searchbase="dc=ldap"
                bindmethod=simple
                binddn="cn=root,dc=ldap"
                credentials="verysecret"
                starttls=yes
                tls_cacert=/etc/ssl/cert.pem
                tls_cert=/usr/local/etc/openldap/certs/fullchain.pem
                tls_key=/usr/local/etc/openldap/certs/privkey.pem
syncrepl        rid=32
                provider="ldap://ldap2.domain.tld"
                type=refreshAndPersist
                schemachecking=on
                retry="5 10 30 +"
                searchbase="dc=ldap"
                bindmethod=simple
                binddn="cn=root,dc=ldap"
                credentials="verysecret"
                starttls=yes
                tls_cacert=/etc/ssl/cert.pem
                tls_cert=/usr/local/etc/openldap/certs/fullchain.pem
                tls_key=/usr/local/etc/openldap/certs/privkey.pem
MirrorMode on
```

Of course, it is in FreeBSD jail and it uses letsencrypt certificates. There
are few things you should note about above config. First, there are 3 ldap
servers which are all masters. Second, ServerID, ldap URL and rid are somewhat
connected: they all contain number 3 in them. That's a convention I find
easiest to follow and understand, and makes some errors somewhat easy to catch.
For example, `rid` should never contain two same digits, like 33. Although ldap
server itself won't stop you, it's easier this way as `rid=33` means that server
3 should connect to itself, which is not good. You can have as much servers as
you want and number of `syncrepl` sections in your configuration should be one
less than the number of servers. FreeBSD slapd servie should be configured like
this:

```sh
slapd_enable="YES"
slapd_flags="-u ldap -g ldap -h ldap://ldap3.domain.tld"
```

One thing you should be careful about is that `ldap3.domain.tld` must be
resolvable. On top of that, it should resolve to the IP of the jail it's
running in. This is usually not the case as you probably point domain names to
server IP, not jail IP. The way I solved it is with the little help of Unbound.
As CBSD/Reggae already uses unbound, I created a fake auth zone for
ldap3.domain.tld:

```sh
ldap3.domain.tld. SOA ldap3.domain.tld. hostmaster.ldap3.domain.tld. (
                  1998092901  ; Serial number
                  60          ; Refresh
                  1800        ; Retry
                  3600        ; Expire
                  1728 )      ; Minimum TTL
ldap3.domain.tld.            NS      ldap3.domain.tld.

$ORIGIN ldap3.domain.tld
@    A   1.1.1.1
```

Of course, you should replace `1.1.1.1` with the actual IP address of jail
where ldap is running. This is not ideal, but if I ever find better solution
I will certainly write about it. There is just one more thing you should worry
about and that's renewing certificates. As uid/gid of cert files is probably
not the same as those running slapd service, there's a little script I wrote
that is executed every time I run letsencrypt client (dehydrated, in my case,
ran once a week):

```sh
#!/bin/sh

DOMAIN="$1"
if [ -z "${DOMAIN}" ]; then
  echo "Usage $0 <domain>" >&2
  exit 1
fi

PRIVKEY=/usr/local/etc/openldap/certs/privkey.pem
CERT_DIFF="dummy"

if [ -e ${PRIVKEY} ]; then
  CERT_DIFF=`diff /etc/certs/${DOMAIN}/privkey.pem ${PRIVKEY}`
fi


if [ ! -z "${CERT_DIFF}" ]; then
  cat /etc/certs/${DOMAIN}/privkey.pem >/usr/local/etc/openldap/certs/privkey.pem
  cat /etc/certs/${DOMAIN}/fullchain.pem >/usr/local/etc/openldap/certs/fullchain.pem
  chown ldap:ldap /usr/local/etc/openldap/certs/*.pem
  chmod 600 /usr/local/etc/openldap/certs/*.pem
  service slapd restart
fi
exit 0
```

It should be ran as `update_certs.sh domain.tld`. You might not have
letsencrypt certs in /etc/certs, so edit that script to conform to your paths
and configuration.

NOTE: There are some blog posts that state you should use `chain.pem` for
`tls_cacert`. That does not work. If you have trouble with your service, try
running it as this:

```sh
/usr/local/libexec/slapd -u ldap -g ldap -h ldap://ldap3.domain.tld -d 1
```

It will run slapd in the foreground and spew a lot of messages to your terminal.
Some of them might be helpful. Also, you might want to use other number than 1
for -d argument, but I found it's the best verbosity level for me.

OpenLDAP has alternate configuration syntax usually called `cn=config` for
short. It allows you to keep configuration in ldap itself and changing those
values makes them active right away. To be honest, I perfectly understand why
some data centers would want not to restart the service when they change
configuration, but for my little server, that's an overkill. Also, cn=config
variables for multimaster are somewhat similar to those I showed here, so it
should be almost easy to convert them. Also, official documentation for
multimaster uses cn=config, so
[give it a try](https://openldap.org/doc/admin24/replication.html) if you're
using cn=config.
