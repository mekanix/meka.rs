+++
title = 'Real Time Feedback'
date = 2014-11-21T22:00:00
tags = ['vim', 'hacking']
+++


As I'm learning about WEB development, I'm learning how not to do it. Anyone can
do it, but only few can find so many solutions that are bad and know why they
are bad. That means that those few will nag big time about most of the solutions,
but once they shut up, you know you're doing it right. I'm lazy. I know it's my
strength and my weakness. That's the reason I tend to automate everything. The
trouble is that I also tend to optimize a lot. I hate inefficient procedures.
That's my reason for two monitors. Think about it. I'm writing every post in
[vim](http://www.vim.org/). That means I have no idea how my post will look like.
But if you take a look at
[the code](https://github.com/mekanix/meka.rs/tree/master/_posts), you'll notice
it is folded on 80th character. We're all crazy in our own way, I just accepted
my weirdness. :o)

OK, now the important stuff. When you write in vim, you realize you can execute
a script on every save. What if you're editing a post, the script you're
running remembers the window which has the focus, focuses chromium window, sends
it "CTRL+r", and returns back? Basically, you'll have your post rendered every
time you change the post. And what if you have two monitors? You could see the
change almost while you're typing. That's pretty close to real time feedback.
And if you have real time feedback, you can see what you're doing, which is
great. Now tell me, isn't this the best reason you've ever heard for a monitor
purchase? :o)

All you need is vim config like

    au BufWritePost * silent !/home/meka/bin/vim-reload-chromium.sh

and the script

    #!/bin/bash

    exec 1>/dev/null
    exec 2>/dev/null

    ACTIVE_WINDOW=$(xdotool getactivewindow)
    CHROMIUM_WINDOW=$(xdotool search --name '^.* - Chromium$')

    sleep 2
    xdotool windowactivate ${CHROMIUM_WINDOW}
    xdotool key "CTRL+r"
    xdotool windowactivate ${ACTIVE_WINDOW}

Now go, prepare for Christmas! :o)
