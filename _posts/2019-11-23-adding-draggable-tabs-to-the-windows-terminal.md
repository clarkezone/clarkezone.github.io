---
layout: post
commentshortlink: "http://ps-s.clarkezone.dev/p7"
title:  "Adding draggable tabs to the Windows Terminal"
date: 2019-11-23 07:12:59 -0800
categories: [UI,Windows]
tags: [Terminal,C++,Windows Terminal]
---
I'm a massive fan of the work the team's been doing on [WSL and the new Windows Terminal](https://devblogs.microsoft.com/commandline/) and I am a complete convert.. decades of muscle memory has been retrained to type `term` instead of `cmd` or `PowerShell` into my run prompt on Windows and I'm way happier.

_(Ed 2/23/2020: thanks to [Mark Osborn](https://twitter.com/ozziepeeps) who pointed out that you can now use `wt` and even type in the address bar of explorer to get a terminal for a particular folder)_

One of the features I really like is support for tabs enabling multiple terminals in the same window, something I do all the time on the Mac.

At Ignite 2019, [Paul](https://twitter.com/pag3rd) and I were [doing a talk about the future of WIndows App development](https://myignite.techcommunity.microsoft.com/sessions/81330?source=sessions) and one of our speaking points related to WinUI 2 and XAML Islands in Win32; specifically  how the Windows Terminal team is using [WinUI](https://docs.microsoft.com/en-us/uwp/toolkits/winui/) and the [TabView control](https://docs.microsoft.com/en-us/uwp/api/microsoft.ui.xaml.controls.tabview?view=winui-2.2) to enabled tabbed content.  We wanted to do a demo of this in our session and show how one of the features available in the box (drag and drop reordering) was available "for free".  Turns out that draggable tabs in the terminal was not a thing.  Queue sad trombone.  

I didn't get a chance to look into why this was prior to giving the talk but afterward I had a bit of downtime between slots manning the WinUI booth and decided to take a crack at solving this.  Turns out it was suprisingly easy, largely thanks to said built in support in the XAML control which [you can see from the diff](https://github.com/microsoft/terminal/pull/3478/files).

Got a demo up and running and sent a video of this to [Kayla](https://twitter.com/cinnamon_msft?lang=en) and crew

[![tweet](/static/img/2019-11-23-dragabletabs/tweet.jpeg)](https://www.pscp.tv/Clarkezone/1ypJdBXBEWYKW)

who encouraged me to get a PR in [which i duly did](https://github.com/microsoft/terminal/pull/3478)

And voila.

![tabreordering](/static/img/2019-11-23-dragabletabs/terminal-tab-reordering.gif)

The power of opensource!

Was great to get this into the [https://devblogs.microsoft.com/commandline/windows-terminal-preview-v0-7-release](Windows Terminal 0.7 release).  I already know the feature I'm adding next :-)
