Title: FreeBSD Network Optimization and CCC Tickets
Date: 2016-11-07 23:45
Slug: freebsd-network-optimization-and-ccc-tickets
Tags: ccc, hacking, freebsd
Author: meka


Today was the first day of presale tickets for people without voucher. Let me be
precise, today at 20:00 started the DDoS on
[ticket servers](http://tickets.events.ccc.de). So, let me put things into
perspective. Because CCC is more and more popular, they had to do something to
limit the number of tickets. They decided to give vouchers to hackerspaces and
alikes. As we heard of that too late (or were too lazy, pick your favorite),
the reply we got was "we ended requests for vouchers earlier today". Bummer!

Next you can do is buy a normal ticket, but that's limited, too. You have 3
chances to do so: 07, 19 and 25 November. So, let's see. Last year there were
about 13k people. Let's say only 5k are buying tickets. Guess what, they all
tried to do it today at exactly 20:00. If you dig/nslookup tickets.events.ccc.de,
you'll see that it's the only one IP. There might be multiple app servers behind
nginx (yeah, we saw nginx 500 error messages), but still, that's HUGE amount of
traffic for one IP. And then games began.

My wife and I loaded the page 30 minutes before, so the CSS, JS and whatnot is
cached. We knew there's going to be problems, so we were prepared. We both have
Linux with dual boot: Windows in her case, FreeBSD in mine. I saw it in her eyes
"I already booted Windows ..." and got reply to silent question "Yeah, and
you're going to race with all the people on better OSes?". So there we are,
Linux on her machine, and FreeBSD on mine. I was thinking two things: she's
already on Linux, if the site doesn't work on FreeBSD for some reason, there's
her machine to refresh the page while I reboot, and let's add diversity, who
knows maybe Linux has some problems that FreeBSD doesn't. I was going to go with
BSD because they practically implemented TCP/IP sockets (hence the name "BSD
sockets"). I know that network stack implementation is better on FreeBSD than
Linux, and I don't even want to discuss Windows. Did it work? Oh yeah! My wife's
Linux didn't load the first page while I bought us tickets. So let's see how I
did it.

Does network stack and BSD vs. Linux really work? Absolutely NO! The difference
is that my wife's on laptop over WiFi, and I'm on desktop over ethernet. WPA2,
I'm sure, is much more overhead than Linux implementation of TCP/IP stack. I'm
sorry if you feel fooled by the title, but I really thought about optimal
implementation of TCP/IP when I considered which OS to boot, and it's more fun
to have a title like this then "How I bought CCC tickets".

So, here we are, the page is loaded, I choose to buy 2 tickets (yeah, my wife is
a huge fan of hacking) and ... error 500. I feel I used all the force in the
Universe pressing F5 frantically. Then I got to the page to choose payment method
and then one page to enter email, than the final one, which didn't work. I
decided I'm gonna get the tickets no matter what! On the third page, you're
informed the ticket is reserved for you for 30 minutes. If for any reason you
don't want it, you just close the browser and the ticket is returned to the pool
of tickets. That's nasty, as I have to do something with the server which is
under heavy DDoS . Of course it was about to timeout when I tried a little hack
(it's not even a hack, to be honest): return to the previous page, click the
same button, and after using the F5 force again, you get another 30 minutes. So,
I figured how to not be time limited. That's cool! Then comes the hard part. On
the last page where you confirm everything, submit button didn't work and gave
some errors about django in the browser console. WHAT THE FUCKING FUCK!!! Pissed
off I looked at #33c3 hashtag on twitter and saw that most people who bought
tickets are speaking German. Right! Switch to German on the last page, and F5
force again. IT WORKED!!! Do I speak German? Nein! The button looks the same and
I really didn't care about the letters.

The moral of the story: you better be system and network administrator and
backend and frontend developer if you want to buy CCC ticket without the voucher.

Update 1
-----------
No matter how you intend to pay for the ticket, select Bank transfer
as selecting credit card will give you one more form to fill in. You'll get the
email which, among other details, contains link to tiketing server's page with
details about your ticket. Tomorrow, when all the DDoS is over, go to that link
and choose "switch payment method" if you want to pay with credit card. This way
you have one page less to display, which is infinity for a server under DDoS.
