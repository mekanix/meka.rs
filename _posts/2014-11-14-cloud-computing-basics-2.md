---
layout: post
title: Cloud Computing Basics 2
tags:
  - cloud
  - docker
  - service-discovery
  - cloud-basics
---

So I've scratched the surface of a cloud in a
[previous post](/cloud-computing-basics). Let's dream on. Let's say you're
hosting a [Django](https://www.djangoproject.com/) site. For start, let's
assume that everything is inside one big container: Django, PostgreSQL, NginX,
...

After few months, your site grows and one machine is not enough. How do you
add another, when your docker image has all included, and you should share the
DB? So, you decide to have PostgreSQL in a separate docker, or someone is
hosting it for you. The only thing you need from Django perspective are DB
credentials. You end up with working Django cluster, but how do you register it
in DNS? DNS is slow. If you kill one machine and start another, with different
IP, DNS can take days to propagate.

So you decide to put a load balancer in
front of those Django machines, because load balancer reconfiguration and
restart can take 5 minutes or less if you know what to do. Much faster than DNS
propagation. But now, you have a problem. If that load balancer fails, you don't
have a site. So you start yet another load balancer and have it proxy the
requests for two Django machines, so if one load balancer fails, there's another.

Over the following months your company and app grow, and you find your self in a
position where you need 5 application servers, 3 DB servers and 2 load balancers.
Imagine you have to change the password. You would do it on all 5 servers by
hand, restating each when done. Or you've already discovered Ansible (or Puppet,
or Chef, or SaltStack, or ...) and do it automatically. But imagine you have
10,000 servers. It would take an hour, I suppose, to update all the machines.
That means, when you change DB password, it will take you an hour to get to the
last machine. That hour the last machine uses old DB password, which renders it
non useful. It would be nice if machines could agree on a set of parameters that
are needed and distributed. In our case, it would be nice if every machine could
remember DB user/pass combination, so wherever you start you Django docker, it
knows how to connect to DB. That's exactly what [Consul](https://consul.io/)
does.

Consul is an application with integrated WEB UI, REST API, DNS, RPC and
tons of other things, but interesting for us is it's ability to cluster and
remember settings. I start it as a docker container on every host of the fleet.
If you have 6 machines with clustered Consul, changing variable on one host makes
it mirror to all other machines. That's great, but it doesn't tackle with docker
containers, so Consul alone is not enough for your 10,000 machines data center.
[Consul-template](https://github.com/hashicorp/consul-template) is small utility
which sits in your Django container and connects to Consul. When Consul variable
changes, consul-template will generate the configuration from a template you
provide and Consul data, and restart your Django. To be technically correct, it
will execute command you configured it with, but you want that command to do the
restart of you application once the configuration is generated. Now DB user/pass
changes can be effective in seconds instead of hours.

Why stop there? You can have your DB docker react on changing the DB user/pass
combination in Consul. In other words, if you add DB user to Consul, DB
container will create it (if you "restart" consul-template script is smart
enough). You can go wild with Consul variables and cloud setup. It's up to you
and your team to find what should be shared through Consul, and what should be
part of on-disk configuration.

[previous](/blog/2014/11/13/cloud-computing-basics)
[next](/blog/2014/11/15/cloud-computing-basics-3)
