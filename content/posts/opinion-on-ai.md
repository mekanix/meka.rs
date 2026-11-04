+++
title = 'Opinion on AI and the future of IT'
date = 2026-10-15T02:36:00
tags = ['ai', 'coding', 'rust', 'quantum']
+++

### Current State

When the statement starts with "people often ask me ...", you know it never happened, but being
interviewed for a job in the past 9 months I did get a question "What are you thought on AI and
agentic development?" on a regular basis. As I do have a job right now, I forgot about it until I
met a friend at a store who asked me pretty much the same thing. My answer has always been "It's
like having a really fast bike/car/formula 1". What it means is that it depends on the driver: if
it's a lousy driver, the crash is going to happen pretty fast, but if he's good, everything will
work just perfect.

That being said, I consider myself a pretty good AI driver. For the past year or so I worked on a
Digital Audio Workstation, or DAW for short, in Rust. At first it was an extension of reading the
Rust book, but then it became a serious project. After reading that book I needed some problem to
solve in order to really understand the language and libraries, so I started rewriting
[Maolan](https://maolan.rs). I started writing it in January of 2018 in C++, and as I really liked
the Rust language, I decided to give rewrite a try. It went really great, and after two months of
writing the code I had audio backend, engine and the foundation in place. I have to admit, I was
inspired by my ex-colleague, Alan Somers, who really likes Rust and whose opinion and knowledge I
highly respect.

After writing the most important parts by hand, I decided to give AI a try. Until now I tried
OpenAI, Claude, Gemini and Kimi. Gemini is not something I consider good AI agent, but the other
three are great. To be honest, Kimi costs the least so I used it mostly. AI writes code insanely
fast and most of the times I have some nitpicks about the code it wrote and sometimes I just say
"forget it, I'll do this manually". The reason is that AI doesn't really know what you want, and if
you're not precise, code gets bad pretty fast. As you can see, I keep saying "fast" and that's why
I think the fast vehicle analogy is good. In any case, Maolan is at the point where I started
recording the first song using it, which revealed bunch of bugs that I fixed.

My background is: I started playing guitar when I was 6, producing trance music when I was 16,
working with electronic and schemes also since I was 16 and programming since I was 19. Now at my
mid-forties I have a lot of experience which make me an expert in the field of audio/MIDI DSP and
music production. I know exactly what I want and how to get it, I know exactly what is hardware and
kernel capable of and how to use it. With such experience, AI is a huge boost, and when it goes
sideways, I can tell right away.

Just as an experiment I did a project I knew nothing about. I wanted to see how bad it will turn
out, even with me as a senior developer and a pretty good IT architect. I don't think it was 2
months since start of that project that I stopped, learned about the technologies I knew nothing
about, read the AI generated code and threw it all away. That was me being a bad driver to prove my
point to myself, as I hate having an opinion about something I've never tested.

Find your speed and don't drive above that limit. Use AI not only to develop something, ask it a
bunch of questions. I think 1/4 of tokens I spent in first 6 months were coding, the other 3/4 were
AI explaining things to me and telling me what to read. Use AI as your teacher as it can improve
your coding skills by a lot. And I mean A LOT!!!

As for programming languages, I think more strict ones are going to be more popular. My experience
with AI and Rust is that strictness of Rust makes AI do better job. For Rust itself, when you
include tools like fmt, clippy and tests, it's even better. Tools like Miri can additionally guide
AI models on how to write better code. Today I see most of new AI coded applications being written
in Rust, and I think the strictness has a lot to do with it. If some future programming language
becomes even more strict, I think it will be even better for AI assisted development. Maybe some
future tool for existing language will catch bugs by analyzing the code even better, maybe it
doesn't have to be a new language. In any case, the more help AI gets, better the code it will
write. And not just AI, humans, too. I remember starting with Rust, I hated it because it forbids
me to write the code the way I used to, only to realize why it is doing that and what's the benefit
of writing the code the Rust way.


### The future

Logical question is "what's next?" so this is my prediction. Looking at the history of IT,
everything starts centralized, then big companies have it in-house, then smaller companies have it
in-house, then everybody have that. From Eniac to home PC, mobile phones and tables, it's always
pretty much the same. That being said, I think similar will happen with AI, the only question is
how exactly. I think the first thing will be that unified memory will become widely adopted so that
today's huge models will fit tomorrow's memory. Of course, at first those systems will be more
expensive than gaming PC, so only companies will afford it, but over time it will come down to the
masses and it will be just a normal development day for your AI model to take most of your RAM.

At some point we are bound to switch to optical computers, for two main reasons: power and speed.
When I say power, I mean consumption of electricity. As electrons are moving through resistive
materials, they need much more energy to move around than photons. As we already have the problem
with CPU speed being topped at 5GHz for quite a few years, the only thing we did in those years is
add more cores. For processes that can be parallelized, that's great, but sometimes you can't do
that. For example, if you have multiple audio effects in series, you have to process them in series
so multiple cores don't really do much for that kind of problems. With optical computers we will be
able to go to much higher frequencies. The problem today is that we miss the optical switching
component, or optical transistor if you will. It is the smallest building block of digital
electronics. So in other words, we need a building block for digital optics. If you ever see the
news "optical switching circuit was made", that's when we will gradually switch to optical
computers. I can imagine 1kW optical computer as powerful as today's small data center and
requiring almost no cooling. As UPSes will still heat up as they do today, I say "almost".

For a quite far future, I think combination of optical and quantum is the way to go. In essence,
optical portion will do what electrical does today with almost no need for programming to change,
while quantum will solve the problems that can be represented as sets. I say "almost no need for
change" because firmware will change drastically, but kernel and userspace not so much.
