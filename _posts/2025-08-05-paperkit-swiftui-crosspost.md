---
layout: post
title: "Using PaperKit from SwiftUI"
date: 2025-08-04
categories: [ios, swiftui, paperkit]
image: /static/img/8-5-2025-Paperkit/IMG_0189.PNG

---

*This is a cross-post from [ObjectivePixel's blog](https://blog.objectivepixel.com/posts/using-paperkit-papermarkerview-in-swiftui/)*

I've had an iPad app idea rattling around in my head for a while which would leverage PencilKit and a drawing canvas. When I saw that iOS 18 introduced a new framework called PaperKit, I was immediately intrigued. PaperKit appears to be the framework that powers the markup functionality in various Apple apps.

The main challenge with PaperKit is that it's designed for UIKit, so integrating it with SwiftUI requires creating a wrapper.  This post presents a solution to that problem:

*Original article by ObjectivePixel - [Read the full post here](https://blog.objectivepixel.com/posts/using-paperkit-papermarkerview-in-swiftui/)*
