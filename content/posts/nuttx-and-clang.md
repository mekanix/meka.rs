+++
title = 'NuttX and Clang'
date = 2017-07-03T15:23:00
tags = ['freebsd', 'clang', 'llvm', 'arm']
+++


I am proud owner of a home audio studio, but it has a big flaw: hardware is not
open source. You may think it's not a big deal, but once you want to alter
something, you realize you're stuck. Let me explain. My mixer is digital and
you control it over some other device (computer, or android based device). It's
a nice feature, and it has USB connection, so it can act as an audio interface.
The problem with that is 48kHz sampling, which is OK for live gigs, but not so
much for studio recordings. On the other hand, I have audio interface with 96kHz
sampling, but it can not work as stand alone mixer. To  be honest, I don't know
anything about DSP and embeded programming, but I said to myself "I know I can
do better than this". That's how "the ride" began.

Since then I really wanted to make Arduino Due working, but for some reason GCC
on FreeBSD gave a faulty binary. Back then I was desperate and I knew there is
absolutely no way I can fix the issue with the compiler. Hell, I couldn't even
use it as developer, let alone debug it. So there came Clang/LLVM.

In [one of the previous posts](/blog/2017/06/02/arduino-due-and-clang/) I wrote
about compiling blink LED test with Clang. That gave me hope that FreeBSD might
be the perfect platform for me for embeded programming. As my end goal is to
create a digital mixer with proper sampling rate, I knew from the begining I can
not just write any code. It must be real time and optimized really good. I've
got to be honest with you: there are two obstacles for me to write such a code.
First one is that Arduino libraries are not optimal. I didn't check, but I do
have friends who are professional embeded programmers who told me that. Second
one is that I'm system administrator. You can not imagine the desparation of a
sys admin staring at the board which doesn't blink.

Now for the good part. I discovered [NuttX](http://www.nuttx.org/). A friend in
Tilda hackerspace asked me how do I search for such cool things, and the only
answer I had was "gut feeling". Later I discovered that even
[Sony is using it](https://www.youtube.com/watch?v=T8fLjWyI5nI) for audio in
some of their products. Even better, they use C++11, which is like a scripting
language compared to "plain" C++ I used back in 2008. When I say "used" it's an
overstatement. I think more apropriate phrase would be "I played with it". So, I
made my goal to make NuttX compile with Clang, and I made it. You can check out
[my fork](https://github.com/mekanix/nuttx/tree/feature/clang) for now, until
the patch makes it into the official repository. Although I used FreeBSD for
development, I hope it's generic enough to be used on other OSes which Clang/LLVM
supports. It still lacks LLVM libc++ support, and that's what we'll be working on
in the hackerspace today (Tuesday it's embeded programming day) and in the
future.

So, the final product will be digital mixer which can be controlled over network
based on NuttX, Clang,
[Nucleo F401RE](http://www.st.com/content/st_com/en/products/evaluation-tools/product-evaluation-tools/mcu-eval-tools/stm32-mcu-eval-tools/stm32-mcu-nucleo/nucleo-f401re.html),
and Cirus Logic [DAC](http://www.mouser.com/ds/2/76/CS4384_F1-39004.pdf) /
[ADC](http://www.mouser.com/ds/2/76/CirrusLogic_CS5368_F5-356402.pdf). The DAC/ADC choice was made by a new found friend from France I will
talk about in some of the next posts (tramendesly interesting guy) who also
wrote audio and midi server for NuttX.
