+++
title = 'Cloud Computing Basics 3'
date = 2014-11-15T22:00:00
tags = ['cloud', 'docker', 'service discovery', 'cloud basics']
+++


So I've scratched the surface of a service discovery in a
[previous post](/blog/2014/11/14/cloud-computing-basics-2/). Let's dream on. Up
to now, I've only written about running a single container on a single host.
But I'm poor, I want multiple things on the same hardware. Let's go back a
little. Docker containers are like tiny virtual machines. They have IP address,
disk space, running processes, ... Strictly speaking, docker isn't a virtual
machine, but it almost is. There's one quirk about containers: they can open
PostgreSQL port on a random port. Here's the reasoning. If you want to host
multiple PostgreSQL instances, they can't all be on the same port. "Not a
problem", one would say, "I'll configure different PostgreSQL instances on
different ports". There's only one problem: you're running all PostgreSQL
containers from the same image. Yes, you can put configuration at runtime, but
remember, we have 10,000 hosts. You just can't do it efficiently. OK, this is
how Docker does it. PostgreSQL is, by default, listening on port 5432. If you
just do `docker run postgres`, you won't even open a port. That's Docker's
weirdness about ports. Docker images are built with predefined ports to be
opened in a container. But that same port doesn't get mapped unless you
explicitly say so with -p or -P. Here's an example

    docker run -p 5432:5432 --rm postgres

What it does is tell Docker to bind container's port 5432 to all interfaces on
the host on the port 5432. In one word, you have your 5432 port open on the
host. You can do something like `-p 127.0.0.1:5432:5432` to listen on localhost
only. You can, also, do things like `-p 127.0.0.1::5432` and Docker will bind
container's 5432 port to a random port on localhost. But how do you know where
to find it? You can use `docker port <container> 5432` and it will tell you. I
agree it's not the most elegant way of figuring out a port, but it works. You're
able to put multiple docker images with the same open port, and they will be
happy to run together. Also, you will probably want to use private network IP
instead of 127.0.0.1 and have all your hosts on that network.

If your containers are secure enough, and they never are, you can expose all
ports on all interfaces. This means that every port is accessible on any network
interface of the host. To do that

    docker run -P --rm postgres

The `docker port` command will still work and everything else remains the same.

By now you probably wonder how Docker knows which ports are open on the
container. No, it doesn't seek all open ports. You must specify which ports will
be opened (or exposed, in Docker terminology). That's part of the build process
which I will cover in some later post. For now, just remember that one line of
Dockerfile for PostgreSQL is

    EXPOSE 5432

Two old problems remain:

- how to run it in 10,000 servers environment
- how to tell application container the DB info

No wonder, it has something to do with Consul. One really neat container is
[Registrator](https://github.com/progrium/registrator). It listens for Docker
events and every time new container runs, it registers container's exposed ports
to Consul. After that, let Consul-template do the rest.

I'm starting to go in "WTF" direction, again. I have a proof this is not an
empty story. If you clone
[One Love](https://github.com/one-love/vagrant-one-love) and follow the
instructions on that page, you'll get my project (in early alpha at the time of
writing this post) which utilizes all I was talking about. It takes a fair
amount of time for it to download everything, but once it does, you have my
application in virtual machine, but that's not the reason I told you to do this.
The reason is that you have Consul's WEB interface available at
[Vagrant VM](http://192.168.33.33:8500). Now go and play with it :o)

[previous](/blog/2014/11/14/cloud-computing-basics-2/)
[next](/blog/2014/11/16/cloud-computing-basics-4/)
