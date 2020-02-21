---
layout: post
title:  "Tracking coding time and language usage with Wakatime"
date: 2020-02-20 09:30:30 -0800
categories: [timetracking]
tags: [wakatime]
---

One of the themes that has resonated with me aver the past three years is innovation and proliferation in programing language.  I shipped my [first commercial product for root6 in 2001](https://www.4rfv.co.uk/industrynews/2872/beam_tv_launch_new_system) using a beta version of .NET 1.0 before the go-live license kicked in.. I fell in love with C# and a 20 year career in software ensued.

Three years ago I started dabbling with GoLang for server-side code and experienced a similar, if not as intese, sense of possibilites.  Then something weird happend.. had the same experience with Kotlin at Google IO 200?, then Swift, then Modern C++, then Rust and most recently Dart.  My experience at the awesome rustconf last October also reinforced and reminded me about how the communities around languages are arguably as importanf / energizing as thr tech itself.

With my ballooning polyglotness on the rise ive been working on a much more diverse range of projects both open and closed source. and being a nerd, I began wondering where my time was going.  Looking around, seemed that Wakatime could provide an answer

## Twitter poll

## Set up in VS Code

You can grab the extension

![intsalled local not on WSL2](/static/img/waka-2-20-2020/wakatime-not.png)

![Installed in WSL1](/static/img/waka-2-20-2020/wakatimeboth.png)

Enter your key

![Enter key](/static/img/waka-2-20-2020/Wakatimekey.png)

Get previews of your coding time

![Coding time in VS code](/static/img/waka-2-20-2020/codingtime.png)

## Set up in VS

Visual Studio also has a plugin.. you can grab that by going to extensions and

## Set up in VIM in WSL

Installing in VIM is [pretty easy using either vundle or pathogen](https://wakatime.com/vim):
![Install for VIM](/static/img/waka-2-20-2020/installforvim.png)
One gotcha to be aware of.. if you already installed the VSCode plugin in your WSL2 instance, the VIM plugin will pick up the existing key so you won't be prompted for it like it says in the instruction.  If in any doubt that the extension is installed, use:

```vim
:WakaTimeToday
```

and, if everything is good, you should see:

![Install for VIM](/static/img/waka-2-20-2020/timetodayvim.png)

## Dashbaord

Having installed Wakatime in each editor you use, you then start harvesting stats

![Dashboard](/static/img/waka-2-20-2020/dashboard.png)
