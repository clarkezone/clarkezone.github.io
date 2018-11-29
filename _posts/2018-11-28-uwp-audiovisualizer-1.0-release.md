---
layout: post
title:  "UWP Audiovisualizer 1.0 Release"
date: 2018-11-28 15:43:03 -0800
categories: [uwp]
tags:
---
It's been a long time coming but the UWP Audivisualizer project recently hit the 1.0 milestone including some new default controls and a rewrite using c++/WinRT.

<iframe width="560" height="315" src="https://www.youtube.com/embed/nS0scXYIGhU" frameborder="0" allowfullscreen></iframe>

This was entirely due to a sustained and heroic effort from Tonu, my long time collaborator and lead developer on this project these days.  The source is [available on GitHub here](https://github.com/clarkezone/audiovisualizer) and the Nuget package can be installed from Nuget.org with:

`
PM> Install-Package UWPAudioVisualizer -Version 1.0.7
`

There is also a demo app that you can grab from the Windows Store [here](https://www.microsoft.com/en-us/p/audio-spectrum-visualizer/9nfrlr613699?activetab=pivot:overviewtab) to play around with the built-in controls.

### What’s new in V1.0?
From a feature perspective, we’ve
- added support for `AudioGraph` in adition to `MediaPlayer`
- Exposed out the internals of `AudioAnalyzer` so you can perform analysis on raw audio frames
- added a helper called `SourceConverter` that helps with reshaping and manipulating the visualalization data for easier consumption
- augmented the built-in controls to now include `AnalogVUMeter`, `DiscreteVUBar`, `SpectrumVisualizer`, `CustomVisualizer`.

From an implementation perspective one of the big aspects of this release was the move to [https://docs.microsoft.com/en-us/windows/uwp/cpp-and-winrt-apis/intro-to-using-cpp-with-winrt](C++/WinRT) from WRL / manual COM which hugely simplified the implementation and made the code more readable.

Aditionally, we have fixed a bunch of bugs, got a more robust test framework hooked up and also migrated from Appvevor onto Azure Pipelines for all CI duties.

### How to get started
We have instructions on how to get started over on the [readme]( https://github.com/clarkezone/audiovisualizer)

### Feedback
If you have any feedback, please file an issue on the project.  Also, if you are interested in building and contributing more visualizations, we would welcome contributions!