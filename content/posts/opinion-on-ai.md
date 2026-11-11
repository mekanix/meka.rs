+++
title = 'Opinion on AI and the future of IT'
date = 2026-11-11T02:36:00
tags = ['ai', 'coding', 'rust', 'quantum']
+++

### Current State

When a statement starts with "people often ask me ...", you know it never happened, but during the
past 9 months of job interviews, I was asked "What are your thoughts on AI and agentic
development?" on a regular basis. Once I found a job, I forgot about the question until I met a
friend at a store who asked me pretty much the same thing. My answer has always been "It's like
having a really fast bike, car, or Formula One". What it means is that it depends on the driver:
if it's a lousy driver, the crash is going to happen pretty fast, but if the driver is good,
everything will work perfectly.

That being said, I consider myself a pretty good AI driver. For the past year or so, I have worked
on a Digital Audio Workstation, or DAW for short, in Rust. At first, it was a way to practice what
I learned from the Rust book, but then it became a serious project. After reading that book, I
needed a problem to solve in order to really understand the language and libraries, so I started
rewriting [Maolan](https://maolan.rs). I started writing Maolan in January of 2018 in C++, and as I
really liked the Rust language, I decided to give the rewrite a try. It went really well, and after
two months of writing code, I had an audio backend, an engine, and the foundation in place. I have
to admit, I was inspired by my ex-colleague, Alan Somers, who really likes Rust and whose opinion
and knowledge I highly respect.

After writing the most important parts by hand, I decided to give AI a try. So far, I have tried
OpenAI, Claude, Gemini, and Kimi. Gemini is not something I consider a good AI agent, but the other
three are great. To be honest, Kimi costs the least, so I have used it the most. AI writes code
insanely fast, and most of the time I have some nitpicks about the code it wrote; sometimes I just
say "forget it, I'll do this manually". The reason is that AI doesn't really know what you want,
and if you're not precise, code gets bad pretty fast. As you can see, I keep saying "fast", and
that's why I think the fast vehicle analogy is good. In any case, Maolan is at the point where I
started recording the first song using it, which revealed a bunch of bugs that I fixed.

My background is that I started playing guitar when I was 6, producing trance music when I was 16,
working with electronics and schematics since I was 16, and programming since I was 19. Now, in my
mid-forties, I have a lot of experience that makes me an expert in the field of audio/MIDI DSP and
music production. I know exactly what I want and how to get it, and I know exactly what the
hardware and kernel are capable of and how to use them. With such experience, AI is a huge boost,
and when it goes sideways, I can tell right away.

As an experiment, I worked on a project in a domain I knew nothing about. I wanted to see how badly
it would turn out, even with me as a senior developer and a pretty good IT architect. Within two
months, I stopped, learned about the technologies I knew nothing about, read the AI-generated code,
and threw it all away. That was me being a bad driver to prove my point to myself, as I hate having
an opinion about something I've never tested.

I think I found my way of working with and learning from AI. Find your speed and don't drive above
that limit. Don't use AI only to develop something; ask it a bunch of questions. I think a quarter
of the tokens I spent in the first 6 months were for coding, and the other three-quarters went to
AI explaining things to me and telling me what to read. Use AI as your teacher, as it can improve
your coding skills a lot. And I mean A LOT!!!

As for programming languages, I think stricter ones are going to be more popular. My experience
with AI and Rust is that Rust's strictness makes AI do a better job. For Rust itself, when you add
tools like rustfmt and clippy, along with tests, the results are even better. Tools like Miri can
additionally guide AI models on how to write better code. Today, most of the new AI-written
applications I see are written in Rust, and I think the strictness has a lot to do with it. If some
future programming language becomes even stricter, I think it will be even better for AI-assisted
development. Maybe some future tool for an existing language will catch bugs by analyzing the code
even better; maybe it doesn't have to be a new language. In any case, the more help AI gets, the
better the code it will write. And not just AI, humans, too. When I started with Rust, I hated it
because it prevented me from writing code the way I was used to, only to later realize why it does
that and what the benefits of writing code the Rust way are.


### The Future

The logical question is "what's next?", so this is my prediction. Looking at the history of IT,
everything starts centralized, then big companies have it in-house, then smaller companies have it
in-house, then everyone has it. From ENIAC to home PCs, mobile phones, and tablets, it's always
pretty much the same. That being said, I think something similar will happen with AI; the only
question is how exactly. I think the first step will be the widespread adoption of systems with
large pools of unified memory, allowing today's huge models to run on tomorrow's personal machines.
Of course, at first those systems will be more expensive than a gaming PC, so only companies will
be able to afford them, but over time they will reach the masses, and it will be normal for your AI
model to use most of your RAM during development.

At some point, I think we are bound to switch to optical computers, for two main reasons: power and
speed. When I say power, I mean consumption of electricity. Moving electrons through resistive
materials consumes energy and generates heat; photons can avoid those thermal losses. As CPU clock
speeds have hovered around 5 GHz for quite a few years, much of the performance scaling has come
from adding more cores. For processes that can be parallelized, that's great, but sometimes you
can't do that. For example, in a single chain of audio effects, each effect must be processed in
order, so multiple cores do not speed up that chain. Optical computers could potentially reach much
higher frequencies. The problem today is that we still lack practical, scalable optical switching
components (or optical transistors, if you will) that can replace their electronic counterparts in
general-purpose computers. Transistors are fundamental building blocks of digital electronics, so
we need an equivalent building block for digital optics. If you ever see news that such optical
switching circuits have become practical and manufacturable at scale, that's when we will gradually
switch to optical computers. I can imagine a 1 kW optical computer as powerful as today's small
data center and requiring almost no cooling. I say "almost" because UPSes will still generate heat.

For the more distant future, I think a combination of optical and quantum is the way to go. In
essence, the optical portion will do what electronic hardware does today with almost no need for
programming to change, while quantum processors will solve specific classes of problems where they
offer an advantage. I say "almost no need for change" because firmware will change drastically, but
the kernel and userspace will not change as much. To use a quantum processor, or maybe a
co-processor, programming will have to change drastically, but for an optical processor, it may not
change as much.
