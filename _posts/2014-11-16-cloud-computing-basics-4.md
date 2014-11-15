---
layout: post
title: Cloud Computing Basics 4
published: false
tags:
  - cloud
  - docker
  - service-discovery
  - cloud-basics
---

So, you've seen how [Consul](https://consul.io/) and
[Registrator](https://github.com/progrium/registrator) can be combined in
[previous post](/blog/2014/11/15/cloud-computing-basics-3). How about we get
down and dirty, finally? One way to start a docker container is to run it with
[systemd](http://www.freedesktop.org/wiki/Software/systemd/). It's my favorite
way, so let's take a look how does Consul service looks like:

{% highlight bash %}
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
{% endhighlight %}

There are small, almost hidden but important pieces of this code. First, you
see there are multiple ports published, and that is:

- 8500: HTTP
- 53: DNS

There are at least 4 more ports exposed on consul Docker image, but this is
more than enough. In previous posts you could read that Consul's HTTP interface
has REST API and UI. If you visit [Vagrant IP](http://192.168.33.33:8500),
you'll see all the services that are registered. That's the port that
Registrator uses to do it's magic. But more interesting port is 53. First,
notice it's UDP, not TCP.
