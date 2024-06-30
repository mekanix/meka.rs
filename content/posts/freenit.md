+++
title = 'Freenit Framework'
date = 2020-10-04 00:36:00
tags = ['python', 'flask', 'react', 'material-ui', 'reggae']
+++


For few years I worked on a startkit to get me faster results, then I started
teaching using it, and now it's a framework. So let me tell you a story.

Backend is written in Python and uses Flask and SmoREST, while frontend is
composed of React, Material-UI and Axios. What I tried to achieve is
"deployment easy / development portable" rule. Yeah, it's quite some rule, and I
have to tell you, it was not always easy. The nice thing that came out of it is
that devops repo for Freenit has support for "plain old" POSIX compliant
scripts to initialize a project and start development. Those scripts are also
used in Docker, CBSD/Reggae jail and Vagrant, which are all preconfigured. As I
use FreeBSD, I made Freenit port/package available, and as I use it in
production I always keep the version updated. I also have a config of uWSGI
that is automatically disabled in development, enabled in production.

![Designer](/images/freenit-demo.gif)
This year we streamed course on development using Freenit, and to make
introduction to development easier, I created [designer](designer.meka.rs) and
I started working on [frontend documentation](frontend.meka.rs). Backend is
kinda self-documented through Swagger and nice patterns that
SmoREST/Marshmallow/Webargs enable. The "big thing" about designer is that it's
a drag n drop web design solution which uses JSON to save the work, but gives
developer an opportunity to export it to React code with theme, styles and
HTML/Material-UI components. The motive for this software is that I hate the
fact that WEB designer and developer have to create the look from scratch, just
using different tools/languages. This way, code is generated from design, and
while it is not perfect, it is intentionally done so. What I mean is that the
goal was to have saved and export file contain everything while being just
json or js file. Naturally, I expect frontend developer to tidy up the code,
split it into multiple files and so on. Other than that, generated code is
decent, looked from developer's perspective.

The course we streamed was about:

  * [Freenit backend](https://www.youtube.com/watch?v=S7ZaCP1j5Qk&list=PLpeJ1COhO5alSO2NsZtvJz0bXUwiziIe0)
  * [Freenit frontend](https://www.youtube.com/watch?v=uv11vOKHkMI&list=PLpeJ1COhO5alT0K6n0P95wZmHT9vYtvzc)
  * [FreeBSD DevOps](https://www.youtube.com/watch?v=ulJE9SWCGII&list=PLpeJ1COhO5ans6FiAN6WjJsMZFG8ChZj9)
  * [Kotlin](https://www.youtube.com/watch?v=4yGq1b6xoJE&list=PLpeJ1COhO5alXSy6Ecskh6d7ddvaBdg_g)
  * [C++](https://www.youtube.com/watch?v=gByyga_5mPw&list=PLpeJ1COhO5aneha988XS5ny6hMQ105g4a)

As this was the first year we streamed the course, we decided to do it in our
native, Serbian, but next batch of courses will be in English, as we already
have plans to record more.

One of my plans was to have everything upgradable with "pkg upgrade" if
possible. As I'm developer of Freenit and maintainer of it's port in FreeBSD, I
know those are in sync. As a matter of fact, I know quite a lot of Python
packages I use are in sync with FreeBSD ports. Most of that is due to
responsive maintainers of those ports. I did some of that porting and the
following picture is a tree of ports (represented by their bug ID) I had to
port to have Freenit in ports.

<a href="https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=242817" target="_blank">
  <img src="/images/freenit.png" />
</a>

For development of the Freenit backend I use pip, but for development of any
product/service based on it I use FreeBSD's pkg. The reason is that I want to
fail fast and discover changes in libraries ideally the day they are published
to pip, but use more stable packages for production. To get there, I had great
help from the FreeBSD community creating that port, especially from Koobs.
Although he does not agree on using FreeBSD's pkg for Python packages in
production, we both understand why the other guy does things the way he does. I
really like the freedom the combination of this OS and language provides as you
can really find what "best way to hosting" is for you and your needs.

Primarily, I'm system administrator. I do know C/C++/Python/JavaScript to a good
degree, but I most enjoy doing sys admin stuff. What I really like about it is
automation, and you might notice it in my coding as well. For example, I created
[UltiSnips snippets](https://github.com/mekanix/dotfiles/tree/master/UltiSnips)
for most commonly used Freenit (and other) constructs, so I can have a page done
with designer, exported to React, added backend integration through snippet,
write backend model/endpoint/migration with snippets or tools and developed
inside CBSD/Reggae, which is also used to publish the code. One feature I'm
currently working on is a uniform setup for Python jails so that deployment
based on Freenit can be unified, too. What you need is just `USE_FREENIT=YES` in
your project/backend and you magically get build and publish functionalities.

Security is a long topic to add to already lengthy post. Also, it deserves a
post on it's own as it's one of the really tricky topics in development of any
kind. Needles to say, I have an opinion how it should be done in Freenit, so
stay tuned for a new one!
