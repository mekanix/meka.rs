Title: Dockerize Everything
Date: 2015-06-18 22:00
Slug: blog/dockerize-everything


Often I hear the "Dockerize Everything" phrase. To be honest, when ever there's
a new technology, people praise it as "it fixes everything". I don't believe
that's the truth about any technology, not even docker. It's not that I think
docker is a bad thing. Hell, I wrote
[series of blog posts about docker](/tag/cloud-basics/). I just think docker is
used where it's not suited too often. One such example is data container. As it
might be great for huge number of servers, it's not that great for small fleets
of servers. For example, if you have nginx and data container such that data
container is used as a volume for nginx, every time you change data container
because you have new files, nginx has to be restarted. That means you have
downtime even if you want to upload just a new css file. That's not so great.
But why would you ignore "normal" directories just because docker exists? Docker
can use directory as a volume, so if you upload the same css file to a server's
directory, no downtime is needed. That's what I did for my blog: have the static
files in directory and use nginx docker container.

Just to conclude, it's important to research new technologies, but it's equally
important to draw the line what should new technology do, and what should old
one be used.
