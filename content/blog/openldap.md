Title: OpenLDAP
Date: 2024-04-14 17:43
Slug: openldap
Tags: ldap, auth, security
Author: meka

I wanted to achieve 3 things:

* Ability to enable/disable account and domain
* Proper groups and membership
* Authorization for services

I personally don't like OLC or On-Line Config, as I like to do my things using
Ansible. So here is the slapd.conf:

```
include		/usr/local/etc/openldap/schema/core.schema
include		/usr/local/etc/openldap/schema/cosine.schema
include		/usr/local/etc/openldap/schema/inetorgperson.schema
include		/usr/local/etc/openldap/schema/nis.schema
include		/usr/local/etc/openldap/schema/opendkim.schema
include		/usr/local/etc/openldap/schema/pmi.schema

pidfile		/var/run/openldap/slapd.pid
argsfile	/var/run/openldap/slapd.args

modulepath	/usr/local/libexec/openldap
moduleload	back_mdb
moduleload	memberof

overlay	    		memberof
memberof-group-oc	groupOfUniqueNames
memberof-member-ad	uniqueMember
memberof-refint		TRUE

TLSCACertificateFile /usr/local/etc/openldap/certs/chain.pem
TLSCertificateFile /usr/local/etc/openldap/certs/fullchain.pem
TLSCertificateKeyFile /usr/local/etc/openldap/certs/privkey.pem

security ssf=128 tls=1

access to attrs=userPassword
  by self write
  by anonymous auth

access to *
  by self write
  by users read
  by anonymous auth

database	mdb
suffix		"dc=ldap"
rootdn		"cn=root,dc=ldap"
directory	/var/db/openldap-data
index		objectClass,mail	eq
include		/usr/local/etc/openldap/slapd-secret.conf
include		/usr/local/etc/openldap/slapd-multimaster.conf
```

And this is the interesting part of the directory:
```sh
dn: dc=ldap
objectClass: domain
dc: ldap

dn: dc=account,dc=ldap
objectClass: domain
dc: account

dn: ou=meka.rs,dc=account,dc=ldap
objectClass: organizationalUnit
ou: meka.rs

dn: uid=meka,ou=meka.rs,dc=account,dc=ldap
objectClass: pilotPerson
objectClass: posixAccount
cn: Goran
sn: Mekić
uidNumber: 65534
gidNumber: 65534
homeDirectory: /var/mail/domains/meka.rs/meka
mail: meka@meka.rs
userClass: enabled
uid: meka

dn: dc=group,dc=ldap
objectClass: domain
dc: group

dn: cn=mail,dc=group,dc=ldap
objectClass: groupOfUniqueNames
cn: mail
uniqueMember: uid=meka,ou=meka.rs,dc=account,dc=ldap

dn: dc=service,dc=ldap
objectClass: domain
dc: service

dn: cn=postfix,dc=service,dc=ldap
objectClass: person
cn: postfix
sn: service
description: SMTP service
```

Let me ignore enable/disable of domain for a bit. Let's just focus on accounts.
In `slapd.conf`, every line with `memberof` string in it is for groups. By
default, memberof module uses groupOfNames, but I think it is better to use
groupOfUniqueNames, so it needs some extra configuration. Let's see what it
provides.

```sh
ldapsearch -x -Z -W -D cn=root,dc=ldap memberOf=cn=mail,dc=group,dc=ldap '*' 'memberOf'

. . .

dn: uid=meka,ou=meka.rs,dc=account,dc=ldap
objectClass: pilotPerson
objectClass: posixAccount
cn: Goran
sn: Mekić
uidNumber: 65534
gidNumber: 65534
homeDirectory: /var/mail/domains/meka.rs/meka
mail: meka@meka.rs
userClass: enabled
uid: meka
memberOf: cn=mail,dc=group,dc=ldap

. . .
```

So with `memberOf` filter, you can easily get members of a group. Notice that
there's `'*' 'memberOf'` at the end. That says "give me all attributes of an
object, plus give me `memberOf`". If you omit `memberOf`, it will not be
displayed, although you requested all attributes. That is because it is dynamic
attribute and it is returned only if explicitly requested. But there are few
cases I found that gave me headache. For example, if you create the group, then
configure `slapd.conf` to use it, it won't work. I guess that something is
triggered on creation and/or modification of a group that is not triggered in
this scenario. Another anomaly I found is when I'm restoring from backup. For
some reason, groups are created before accounts, so `memberOf` doesn't work.
Having `dc=group,dc=ldap` separated from `dc=account,dc=ldap` allows you to
restore accounts before groups. Also, there is `msuser.schema`. I first thought
that I need to include it to be able to use `memberOf`, but that is wrong. When
I include this file, it defines memberOf and I guess that's why it doesn't work
the way I wanted.

Look closely at `ldapsearch` output and notice `userClass: enabled`. If extend
the previously used filter, you get something like this:
```sh
ldapsearch -x -Z -W -D cn=root,dc=ldap (&(userClass=enabled)(memberOf=cn=mail,dc=group,dc=ldap)) '*' 'memberOf'
```
Output will pretty much be the same, only difference is which accounts will be
listed.

Enabling or disabling domain is partially working. For example, postfix has a
filter for domains, but dovecot does not, while ejabberd can't use LDAP for list
of domains. Depending on the capabilities of a service, you might or might not
achieve this. For example, solution I use for ejabberd is to have group, just
like for the accounts, but for domains called `enabled` and use same `memberOf`
filter to get the list. Then I use that info in Ansible to provision
configuration file.

For authorization of services I chose not to use `dc=account,dc=ldap` for base,
but `cn=<service>,dc=service,dc=ldap`. That way services can not interfere with
user accounts, but beside different base, those are just like normal accounts.

For more context on how I use OpenLDAP, take a look at my [set of services for
communication](https://github.com/mekanix/comms) as it might give you a broader
picture what I'm trying to solve.
