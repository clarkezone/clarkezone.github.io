---
layout: post
title:  "Animated vector graphics using Windows::UI::Composition"
date: 2018-12-14 16:00:45 -0800
categories: [blogging, WUC]
tags: [animation]
---
One of the features that the Composition team have recently added is support for animated vector graphics.  What I'm pretty happy about with our support is that we've added, not only the primitives in the compositor, but also complete tooolchain and playback support truly lighting up end-to-end.  Another exciting aspect is that this works in all Microsoft frameworks and UI targets including UWP XAML, WPF, Winforms and even in raw win32 c++ apps.  This post will walk through a sample I’ve written in my UWPCompositionSamples repo that will shortly becoming an official API sample, but wanted to share here first to get it out there and get feedback.

- Creating Window
- Adding visuals
- Hello ShapeVisual
- PathGeometry, CompositionPath’s and CompositionSpriteShapes
- Animating PathGeometry
- Lottie: pre-canned animations
- Lottie: full authoring pipeline

Final edit.