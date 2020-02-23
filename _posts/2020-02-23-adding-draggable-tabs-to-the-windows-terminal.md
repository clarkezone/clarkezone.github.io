---
layout: post
title:  "Adding draggable tabs to the Windows Terminal"
date: 2019-11-23 07:12:59 -0800
categories: [windowsterminal]
tags: [c++]
---
I'm a massive fan of the work the team's been doing on [https://devblogs.microsoft.com/commandline/](WSL and the new Windows Terminal) and I am a complete convert.. decades of muscle memory has been retrained to type `term` instead of `cmd` or `PowerShell` into my run prompt on Windows.  One of the features I really like is support for tabbing multiple terminals in the same window, something I do all the time on the Mac.

At Ignite, Paul and I were [doing a talk about the future of WIndows App development](https://myignite.techcommunity.microsoft.com/sessions/81330?source=sessions) and one of our speaking points related to XAML Islands and how the Windows terminal was using them to enabled tabbed content.  We wanted to do a demo of this in our session and show how one of the features available in the box (drag and drop reordering) was available "for free".  Turns out that draggable tabs in the terminal was not a thing.  Queue sad trombone.  I didn't get a chance to look into why this was prior to giving the talk but afterward I had a bit of downtime between slots manning the WinUI booth and decided to take a crack at solving this.  Turns out it was suprisingly easy, largely thanks to said built in support in the XAML control!

Got a demo up and running which I tweeted

[demo](https://twitter.com/Clarkezone/status/1192524919835283456)

and [which i duly did](https://github.com/microsoft/terminal/pull/3478)

And voila.

![tabreordering](/static/img/2019-11-23-dragabletabs/terminal-tab-reordering.gif)

Was great to get this into the [https://devblogs.microsoft.com/commandline/windows-terminal-preview-v0-7-release/](Windows Terminal 0.7 release).  I already know the next feature I'm adding :-)