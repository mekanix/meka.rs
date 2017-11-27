Title: Cloud Computing Basics 7
Date: 2014-11-21 22:00
Slug: cloud-computing-basics-7
Author: Meka
Tags: cloud, docker, service discovery, cloud basics


There's been so much talk about Consul-template and I've never shown you any
examples. Consul-template is what gives Docker container the knowledge when
something is changed in Consul. It does it by having a template for
configuration file filled with Consul data and command to run when template is
generated. Let's take a look at my Dockerfile for NginX:

    FROM nginx:latest
    MAINTAINER Goran Mekić <meka@lugons.org>

    ENV DEBIAN_FRONTEND noninteractive
    ADD consul /app/consul
    ADD consul-template /usr/bin/consul-template
    ADD run.sh /run.sh

    CMD /run.sh

It's a bit dirty as I get consul-template out of the sky, but kids, don't be
like me. :o) Yeah, always works!

I have my run.sh:

    #!/bin/bash

    set -e

    rm /etc/nginx/conf.d/*
    consul-template -config /app/consul/nginx.conf
    sleep 1
    tail -f /var/log/nginx.log

Great. So Consul-template does all the work. Let's see the config.

    consul = "172.17.42.1:8500"

    template {
        source = "/app/consul/nginx.tmpl"
        destination = "/etc/nginx/conf.d/onelove.conf"
        command = "service nginx restart"
    }

Remember I've told you that Consul is available on 172.17.42.1 on all hosts?
This is where it comes handy. It is achieved through docker0 interface. Ensure
you have the same IP on all hosts and that Consul is bind to it, and that's it.

Second part is the template. What, where and how are the questions it answers.
What source template I should use? Where to put the output? How to notify the
service. Yeah, I'm aggressive, I restart instead of reload because of simplicity.
The problem I had was with the run.sh. If you look closely, only thing I really
call is `consul-template`. I never start nginx by hand or automatically inside
the container, so if I have used `reload`, there would be nothing to reload
initially (read: container doesn't boot).

There are two thing you can do to ensure that your load balancers don't reboot
all at the same time. First one is to explore
(wait parameter)[https://github.com/hashicorp/consul-template#usage] and restart
with random delay. Second one is to initialize the config, start services, and
watch for changes. When there is a change, reinitialize config and reload
service. Example of it is
[One Love API](https://github.com/one-love/api/blob/master/bin/run.sh).

    #!/bin/bash

    set -e

    export COMMAND="consul-template -config /app/consul/api.conf"

    echo -n "Waiting for initial config "
    until $COMMAND -once; do
        echo -n "."
        sleep 3
    done
    echo " done"

    uwsgi --ini /app/uwsgi.ini
    python /app/manage.py migrate --noinput
    python /app/manage.py collectstatic --noinput

    $COMMAND &
    sleep 1
    tail -f /var/log/uwsgi.log

Now you know everything I know about the cloud computing. This is my way of
doing things, and my view. You don't have to agree on everything. I'm not going
to agree with these posts in a year! What I didn't describe is Docker HUB, but
go to site, register, and add your repository. Play with it, it's dead simple. I
gave my best to give you posts that have no bull shit talk, because I was mad on
todays media representing the cloud. I hope I did it. Happy dockering!

[previous](/blog/2014/11/20/cloud-computing-basics-6/)
