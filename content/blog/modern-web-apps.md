Title: Modern WEB applications
Date: 2015-02-22 22:00
Tags: web development

Who am I to tell you about WEB applications? Even worse, modern ones? I am
system administrator, right? Well, not exactly. The reason I never liked WEB
programming is that I could never see the point of trying to shoot HTML through
the WEB server, load balancer and browser to tons of different devices with who
knows what resolution and ratio. How can you even dream of supporting the jungle
of devices capable of running a browser? Deep down I always felt that's wrong.
I never had an alternative, so I kept my mouth shut, but admit it, it's a design
level flaw.

That's a few years old story of mine. Now I think different. With frameworks
like [AngularJS](https://angularjs.org/) and [CanJS](http://canjs.com/), to name
the few, it all changed. First, frontend is finally in the front. I mean, what
frontend is capable of doing now is calculate the height and width of the
elements based on resolution, because the code is running where it's most
suitable for this kind of calculations: the browser. Yes, I know you could alter
the page with javascript before single page application frameworks saw the light
of the day, but it was hackish and ugly.

One more thing changed. Backend became "only" the REST API, or the fancy word
"DB with some minimal code". If your application is only changing the models in
the backend, you might look at the whole backend as the DB with the REST
interface. That means no more DB procedures, you've got a proper scripting
language at your disposal with multiple supported DB types, portable code and
properly decoupled code and the DB. Single page application frameworks didn't
bring this to the table, but modern WEB app design and REST did.

While we're at it, REST brought some optimization, too. Well, JSON did it, but
it's almost the same thing, as almost all REST implementations use JSON as a
format. As only data that is really necessary to fill the template is
transmitted.

One thing I always hated about WEB applications is authentication. Session?
Cookie? That's just plain and simple wrong. In the age when every application is
behind a load balancer, how do you balance authentication? One solution is
saving the session in the DB. Just think about it for a second. You'll be saving
a temporary information in a DB, which saves the data forever. The modern way of
dealing with this is forgetting the session and the cookies, and using
[JSON WEB Tokens](http://openid.net/specs/draft-jones-json-web-token-07.html),
or JWT for short. Simplified, you obtain the token by POSTing to a
authentication endpoint, that token is transfered in a HTTP header on every
request, thus allowing the backend to know who you are. The token itself is just
a very long string. It does have the structure and rules how to generate one,
but I'm not going into that now, as it's too much detail for this post. If all
your backend servers generate and use the token in the same way, there's no
difference which server actually generated the token, which enables you to have
proper load balancing.

This is just my point of view. It will evolve over time, I'm sure. You may find
I made mistakes in my judgment. I'll admit it right away, I'm not experienced
in this field as much as I'd like, but I still do know the principles.
