Title: Cloud Computing Basics 4
Date: 2014-11-16 22:00
Slug: blog/cloud-computing-basics-4


So, you've seen how [Consul](https://consul.io/) and
[Registrator](https://github.com/progrium/registrator) can be combined in
[previous post](/blog/2014/11/15/cloud-computing-basics-3). How about we get
down and dirty, finally? One way to start a docker container is to run it with
[systemd](http://www.freedesktop.org/wiki/Software/systemd/). It's my favorite
way, so let's take a look how does Consul service looks like:

    [Unit]
    Description=Consul
    After=docker.service network.target
    Requires=docker.service
    Wants=network.target

    [Service]
    TimeoutStartSec=0
    ExecStartPre=/usr/bin/docker pull progrium/consul
    ExecStart=/usr/bin/docker run -h site -p 8500:8500 -p 53:53/udp --rm --name consul progrium/consul -server -bootstrap -advertise 192.168.33.33
    ExecStop=/usr/bin/docker stop consul

    [Install]
    WantedBy=multi-user.target

There are small, almost hidden but important pieces of this code. First, you
see there are multiple ports published, and that is:

- 8500: HTTP
- 53: DNS

There are at least 4 more ports exposed on consul Docker image, but this is
more than enough. In previous posts you could read that Consul's HTTP interface
has REST API and UI. If you visit [Vagrant IP](http://192.168.33.33:8500),
you'll see all the services that are registered. That's the port that
Registrator uses to do it's magic. But more interesting port is 53. First,
notice it's UDP, not TCP. Second, that port is DNS. In other words, if you run
container which publishes port 80, Registrator will pick it up and  register it
in Consul. That means that you can ask Consul's DNS where is your new created
container like this

    dig @172.17.42.1 web.service.consul

IP of 172.17.42.1 is interesting because it's IP of docker0 interface which is
available on every host. As Consul is distributed among all hosts, and that IP
is available on every host, you can tell all containers to use 172.17.42.1 as
DNS:

    [Unit]
    Description=PostgreSQL
    After=registrator.service network.target
    Requires=registrator.service
    Wants=network.target

    [Service]
    TimeoutStartSec=0
    ExecStartPre=-/bin/mkdir -p /var/lib/docker/volumes/postgresql
    ExecStartPre=/usr/bin/docker pull paintedfox/postgresql:latest
    ExecStart=/usr/bin/docker run --dns 172.17.42.1 -P -e SERVICE_TAGS=master -e DB=onelove -e PASS=password -v /var/lib/docker/volumes/postgresql:/data --rm --name postgresql paintedfox/postgresql
    ExecStop=/usr/bin/docker stop postgresql

    [Install]
    WantedBy=multi-user.target

Notice `--dns` option. Now, this is the flow of DNS data/queries. Every
container will ask Consul for .consul domains. If FQDN container is asking for
is not subdomain of .consul, Consul will ask external DNS, which is usually
`8.8.8.8`. In the previous example, I've set a service tag to master. Because it
is a service for PostgreSQL, which might be part of DB cluster, you must have a
master server. Although there's only one DB server here, I still like to set
master just in case I decide to scale later. On DNS side it means you'll get
`master.postgresql.service.consul` records. As a matter of fact, you'll get two
records: A and SRV. First one will only return IP address, while second has
richer structure which includes IP and port. So, if your application depends on
DNS only, you can still dockerize it. Nice thing is that queries are super fast
and are not cached.

For the last, one trick I use lately. My DB host is always `master.postgresql.service.consul` and I don't even generate it on change with Consul-template. Fact is
that when DNS records change, as DNS is not cached, application server will hit
new DB server the second it's in DNS. For some other neat tricks, check out
[Consul documentation](http://www.consul.io/docs/index.html).

[previous](/blog/2014/11/15/cloud-computing-basics-3)
[next](/blog/2014/11/17/cloud-computing-basics-5)
