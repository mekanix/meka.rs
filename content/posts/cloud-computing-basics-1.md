+++
title = 'Cloud Computing Basics 1'
date = 2014-11-13T22:00:00
tags = ['cloud', 'cloud basics', 'docker', 'registrator', 'consul']
+++


The first critic I've got for a blog was "Yeah, it's all nice and shinny, but
WTF? Where are examples, documentation, ... ? How do I do it?" Let's go back a
little. Cloud is extremely complicated network of hardware and virtual machines
where one second your server is in New York, next second is in Amsterdam, if
you happen to believe the media and PR "experts". In reality, yes, sometimes
it might happen that your machine gets migrated to another data center, but
why would anyone do it if there's no need? What cloud provides is easy migration
of machines, it doesn't enforce them! In other words, just because you can
scratch your nose, doesn't mean you have to scratch it all the time, but when
you do, it's better if you're able to do it in seconds. That's all there is
about the cloud. The logic is simple. If you can have a number of machines that
are basically junk, you can create highly redundant WEB site if all machines are
on the fast network. You don't mirror all the data between them, but download
virtual machines or docker images fast when you need it and hope nobody noticed.

That's where [Docker](https://docker.com/) comes in. Docker images are made to
be as small as possible. For example,
[Consul](https://registry.hub.docker.com/u/progrium/consul/) image is ~50MB,
[Registrator](https://registry.hub.docker.com/u/progrium/registrator/) image is
~20MB. Of course, not all images can be that small, and I did mention two of the
smallest images I know of, but maybe your application can sit on top of it
(base image is called
[busybox](https://registry.hub.docker.com/u/progrium/busybox/)). Or you might
need big image only to build your application, but not to run it? Docker
optimization and security are separate and hot topics these days, and I'm
trying to give you the basics here :o)

What marketing around cloud technologies will tell you is that "On hardware
level we have multiple machines working as a unit to run your code on, so if
one fails, some other takes over". Right. Let's say you have two machines with
docker. One is your main site, and the other one is just a spare. Main one dies.
And what then? How does the spare becomes the main? Let's say it's a simple
modification of DNS record. OK, we got our new IP registered. But we had docker
container running on the old main computer only. Docker Hub is a service which
offers hosting docker images, so your spare machine can, in case of this blog,
run this:

    docker pull mekanix/blog

Docker will do the magic of downloading and updating the image, if you had an
old one, for you. As a matter of fact, why don't you try it? Clone the
[repository of this blog](https://github.com/mekanix/meka.rs), install
[Vagrant](https://www.vagrantup.com/) and
[VirtualBox](https://www.virtualbox.org/), and run:

    git checkout no-ansible
    vagrant up
    vagrant ssh

First line is there just to make sure you don't need Ansible, yet. I'll cover
Ansible, provisioning and deployment in some of the later posts. To setup a
docker:

    sudo yum install docker
    sudo gpasswd -a vagrant docker
    sudo systemctl enable docker
    sudo systemctl start docker

Your docker is now running, and you can control it. You control the cloud! To
pick up the changes on vagrant account you have to logout and run the container:

    vagrant ssh
    docker pull mekanix/blog
    docker run -p 80:80 --rm mekanix/blog

And that's it. Go to [Vagrant IP](http://192.168.33.33/) and you should see this
blog. If you want to update the image, stop the container (CTRL+C) and

docker pull
docker run

Happy docking :o)

[next](/blog/2014/11/14/cloud-computing-basics-2/)
