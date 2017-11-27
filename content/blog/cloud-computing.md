Title: Cloud Computing - intro
Date: 2014-11-02 22:00
Author: Meka
Tags: cloud, docker, service discovery, cloud basics


As [nobody understands the cloud](http://www.youtube.com/watch?v=ecZL4Q2EVuY),
it became obvious to me I will hack something out of it. And I did. A job. My
latest toy is [CoreOS](https://coreos.com/). It features two nice things a man
doesn't need until he faces big amount of servers. First being collective
consciousness, aka etcd, allowing storing information about the services,
like which upstream servers for your load balancers are on which IP addresses.
Second is fleetd, which uses etcd to store and read data. It starts docker
containers on your CoreOS instances. Actually, it starts systemd services,
which is even better! :o) Oh, did I mention cloud computing these days is all
about running containers? [Docker](https://www.docker.com/) containers in my
case. Lastly, in dynamic environment of the cloud, you need dynamic
configuration. But what application in the world has dynamic configuration?
None that I know. Despite that fact, cloud computing and docker containers
are thriving. There's a secret ingredient:
[confd](https://github.com/kelseyhightower/confd). What it does is poll etcd
every 10 seconds or so, checking if there are changes on some of the keys in it
and if there is, generates the configuration of your application and restarts
it. Confd uses templates and etcd data to generate the configuration, so once
you have your fleet running, changing master DB host is as easy as

    etcdctl set /my/app/db/server 192.168.0.4

and all containers having confd will pick up the changes. Just imagine, one
command and thousand services change their configuration accordingly. This is
small step for cloud, but huge step for a man, because it's hard to start
thinking about "configuration is in the cloud". Once you grasp that idea,
you're on a great way to cloud computing.
