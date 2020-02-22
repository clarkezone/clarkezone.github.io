---
layout: post
title:  "Tracking coding time and language usage with Wakatime"
date: 2020-02-20 09:30:30 -0800
categories: [timetracking]
tags: [wakatime]
---

One of the themes that has resonated increasingly with me over the past few years is innovation in and proliferation of programing languages.  With a background of tinkering in BASIC, Visual Basic and C/C++, my journey into professional software kicked off when I built and shipped my [first commercial product for root6 in 2001](https://www.4rfv.co.uk/industrynews/2872/beam_tv_launch_new_system) using a beta version of .NET 1.0 before the go-live license kicked in.. I fell in love with C# and a 20 year career in software engineering ensued.

Three years ago I started dabbling with GoLang for server-side development and experienced a similar, if not as intese, sense of new possibility.  Then something weird happend.. I had the same experience with Kotlin at [Google IO 2017 when Kotlin became the default language](https://www.youtube.com/watch?v=Hx_rwS1NTiI&list=PLx-LPiGjoc1I8bdan6sYrCAOMquPuJIzD&index=2&t=1091s) for new projects in Android Studio.  Same thing with Swift motivated by SwiftUI and iOS development on the iPad using Playgrounds, then Modern C++, then Rust.  Most recently Dart and Flutter.  On and on it goes! My experience at the awesome rustconf last October also reinforced and reminded me about how the communities around languages are arguably as important / energizing as the tech itself.

With my ballooning polyglotness on the rise I've found myself working on a much more diverse range of projects both open and closed source and, being a nerd, I began wondering where my time was going.

### Twitter poll

Doing some quick internet search for lanuage-oriented time tracking tools lead me to [Wakatime](https://wakatime.com/). Played around a bit and seemed to do the trick and had plugins for each editor I cared about.  There didn't appear to be a more popular option based on a quick twitter poll

[![time tracking tweet](/static/img/waka-2-20-2020/timetrackingtweet.png)](https://twitter.com/Clarkezone/status/1214965724436762624)

hence I went with it.  After a couple of weeks I was hooked and ended up getting a pro subscription.  Haven't looked back.

### Set up in VS Code

You can grab the extension from the VS Code extension store and get up and running pretty quickly.  If you are running WSL2 (which I highly recommend) make sure you install wakatime on Linux as well as on the host.. luckily VS Code prompts you to install in your linux distro so it's pretty quick and seemless.

![intsalled local not on WSL2](/static/img/waka-2-20-2020/wakatime-not.png)

Enter your key from the website when prompted

![Enter key](/static/img/waka-2-20-2020/Wakatimekey.png)

and you are off to the races.  Easy to get previews of your coding time in the IDE

![Coding time in VS code](/static/img/waka-2-20-2020/codingtime.png)

### Set up in VS

Visual Studio also has a plugin.. you can grab that by going to the extensions store.  There are also plugins for most other popular IDE's on Windows, Linux, Mac.

### Set up in VIM in WSL

Installing in VIM is [pretty easy using either vundle or pathogen](https://wakatime.com/vim):
![Install for VIM](/static/img/waka-2-20-2020/installforvim.png)
One gotcha to be aware of.. if you already installed the VSCode plugin in your WSL2 instance, the VIM plugin will pick up the existing key so you won't be prompted for it like it says in the instructions.  If in any doubt that the extension is installed, use:

```vim
:WakaTimeToday
```

and, if everything is good, you should see:

![Install for VIM](/static/img/waka-2-20-2020/timetodayvim.png)

### Dashbaord

Having installed Wakatime in each editor you use, you then start harvesting stats:

![Dashboard](/static/img/waka-2-20-2020/dashboard.png)

It's easy to keep track of which languages and projects are taking up your time.  There are more advanced use cases which I haven't looked into (yet) such as being able to overlay your WakaTime stats on your repo's commit history to see how long you coded a particular commit which I definitely plan on checking out at some point.

Only remaining quesiton I have now is how long it will take Github to buy the company and fold into the pro subscription.
