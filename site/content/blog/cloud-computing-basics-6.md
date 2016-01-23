Title: Cloud Computing Basics 6
Date: 2014-11-20 22:00
Slug: blog/cloud-computing-basics-6


Docker here, Docker there, and no Docker build anywhere. That's not fair. How
about we create the first docker? Docker image is built from `Dockerfile`.
The syntax of `Dockerfile` is almost the same as `Bash`. This is an example of
Dockerfile:

    FROM debian:jessie
    MAINTAINER Goran Mekić <meka@lugons.org>
    RUN touch /some-file.txt

To build it run `docker build -t username/repo .` in a directory containing
Dockerfile. It's advisable to have a [HUB](https://registry.hub.docker.com/)
username, as registration is free and has autobuild capabilities. We'll deal
with simple builds for now, and leave autobuild for some future post.

To upload your image issue this command:

    docker push username/repo

Docker will ask you for username/password/email combination. Fill it up, wait
for upload to finish and that's it. You have your first Docker image. Let's give
it a spin.

    docker run --rm -i -t username/repo /bin/bash

What it does is (simplified):

- `--rm`: remove container when it stops
- `-i`: this will be interactive container (read: someone will type commands in it)
- `-t`: give me a terminal emulation

Note that every command in Dockerfile will create additional layer. It means
that Docker images are organized as multiple file system layers which have
dependencies. Much like a git repo branch is pointer to commit which has its
own dependencies, Docker image remembers which file system layer is on top. As
every layer remembers which layer it depends on, you can have dependency line.
In the example above, there will be at least 3 layers: FROM, MAINTAINER and RUN
lines make them. This has consequences you have to be aware of. First, if the
line in Dockerfile and dependent layers didn't change from last build, Docker
will use last build's layer, not build it (read: cache). Second, EVERY line in
Dockerfile creates layer. So, if you create 1GB file on one line, delete it on
the other, you'll have a small layer (from deleting 1GB) dependent on a big
layer (where you created 1GB), although lower layer is unusable, because upper
layer effectively masked it.

The "trick" I use is to have a build script which will cause 2 lines in
Dockerfile: one for ADD and one for RUN. I start with debian:jessie, add all
build tools, build my app, remove build tools and do the cleanup. The build
does last much longer, but you end up with MUCH smaller images. I managed to
shrink [One Love API](https://github.com/one-love/api) image from 1GB to 298MB just using this. What I think would be
the optimal solution are two images, one for building, one for using application.
And guess what. There are. For example, you have
[python:latest and python:onbuild](https://registry.hub.docker.com/_/python/)
images.

I leave it up to you how to build your applications, these are just some ideas.
Idealy, you can base your application on busybox environment, and use images as
small as 5MB. If not, lurk around for your perfect solution.

[previous](/blog/2014/11/17/cloud-computing-basics-5)
[next](/blog/2014/11/21/cloud-computing-basics-7)
