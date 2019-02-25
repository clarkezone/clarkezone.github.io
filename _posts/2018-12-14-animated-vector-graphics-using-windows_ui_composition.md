---
layout: post
title:  "Animated vector graphics using Windows::UI::Composition part 1"
date: 2019-02-24 01:00:45 -0800
categories: [blogging, WUC]
tags: [animation]
---
# Some History: Composition in the Windows DWM
Since the mists of time [Windows Vista to be precise], the Desktop Window Manager has been focussed on composing bitmaps.  What does that mean in practice? Well, if you are creating an application that needs display content like a button your application will ultimately need to produce a bitmap representation in order to give to DWM aka the Windows compositor to display on screen.  In reality, UI frameworks take care of this for you so you are probably none the wiser that your lovingly created 
```xaml
<Button/>
```
tag becomes an A8 texture with pre-rendered antialised text and another RGB texture representing the colored rectangle and border.  Furthermore, if your application has a desire to use more exotic XAML shapes, these also need to be rasterized as bitmaps and handed to the Compositor as well.  While there is nothing wrong with this approach, it means that applications and/or UI frameworks have to work harder to animate things.

# Enter Primitives

That was the world of the compositor circa Windows 8.  By Windows 10 RS1, on the compositor team, we had built out the modern Windows.UI.Composition API surface complete with a new set of content and animation primitives and the XAML framework team was able to consume this, bringing simpli

# Native Animated Vector Graphics
Fast Forward to today: animated vector graphics have become common place in mobile apps.  It's hard to find a popular mobile app that doesn't have some kind of cute loading screen, welcome animation, app tutorial that doesn't contain a whealth of beautifuly designed characters, dd motion to bring a more playful, human feel. TODO: example GIF.

To be able to support this kind of experience on Windows, We set out on a jouney to add a rich set of vector animation primitives to the engine, staring in RS5 and delivering in a complete end to end implementation in 19H1.  We are releasing both a series of API's that bring low level capabilities to the platform, a toolchain to enable a designer developer workflow from After Effects and a new XAML control that makes it easy for UI developers to incorporate vector animation in apps.  

Becuase the low-level support is implemented in a framework agnostic way in the Compositor itself, it's possible to get animated vector support in UWP XAML Apps, WPF, Winforms and even desktop win32 apps.

## Hello Shape 
For the remainder of this post I will show how to use the low level primitives directly in a desktop win32 project in c++/winrt.  In the next post I'll show how to use some of the higher level tooling to 


 Let's start by creating a basic shape using a ShapeVisual


```cppwinrt
void Scenario1SimpleShape(const Compositor & compositor, const ContainerVisual & root) {

	// Create a new ShapeVisual that will contain our drawings
	ShapeVisual shape = compositor.CreateShapeVisual();
	shape.Size({ 100.0f,100.0f });
```

Next we need a gemotry

```cppwinrt
	// Create a circle geometry and set it's radius
	auto circleGeometry = compositor.CreateEllipseGeometry();
	circleGeometry.Radius(float2(30, 30));
```

to get the geometry to show up we need to 

```cppwinrt
	// Create a shape object from the geometry and give it a color and offset
	auto circleShape = compositor.CreateSpriteShape(circleGeometry);
	circleShape.FillBrush(compositor.CreateColorBrush(Windows::UI::Colors::Orange()));
	circleShape.Offset(float2(50, 50));
```

and finaly get it in the visual tree:

```cppwinrt
	// Add the circle to our shape visual
	shape.Shapes().Append(circleShape);

	// Add to the visual tree
	root.Children().InsertAtTop(shape);
```


- Creating Window
- Adding visuals
- Hello ShapeVisual
- PathGeometry, CompositionPath’s and CompositionSpriteShapes
- Animating PathGeometry
- Lottie: pre-canned animations
- Lottie: full authoring pipeline

More stuff at the end.  And more.  And this is autoupdated.  And again. dd. aa.ss


WinRT is much better than cx becuase it's faster.  Finally we have the daemon running.
Fun can be had.