---
layout: post
title:  "UWP Audiovisualizer 1.0 Release"
date: 2018-11-19 15:43:03 -0800
categories: [uwp]
tags:
draft: true
---
It's been a long time coming but the UWP Audivisualizer project recently hit the 1.0 milestone thanks to a sustained effort from Tonu.  The source is [](available on GitHub here) and the Nuget package can be installed with:

`
PM> Install-Package UWPAudioVisualizer -Version 1.0.7
`

### What’s new in V1.0?
From an implementation perspective one of the big aspects of this release was the move to [https://docs.microsoft.com/en-us/windows/uwp/cpp-and-winrt-apis/intro-to-using-cpp-with-winrt](C++/WinRT) from WRL / manual COM.  This hugely simplified the implementation.

### How to get started