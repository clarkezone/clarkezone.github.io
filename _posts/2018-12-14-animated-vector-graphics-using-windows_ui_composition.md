---
layout: post
title:  "Animated vector graphics using Windows::UI::Composition part 1"
date: 2019-04-01 01:00:45 -0800
categories: [blogging, WUC]
tags: [animation]
---

## Native vector graphics in Windows
This post describes some new vector graphics APIs recently added to the Windows platform (```ShapeVisual```, ```SpriteShape``` and friends), some scenarios they can unlock for you and how to use them from C++ in win32 desktop applications.  The sample I walk through along with versions written in C# are available in this repo: http://github.com:clarkezone/UWPCompositionDemos.

![example](/static/img/test/Vectors_in_Win32.gif)

## Some History: Composition in the Windows DWM
Since Windows Vista, all roads from a Windows application's UI tree to the monitor have gone via the Desktop Window Manager (DWM for short).  Thankfully we never got the kind of craziness shown in early Longhorn builds like this:

<iframe width="560" height="315" src="https://www.youtube.com/embed/p2rQrd_uocI" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

but having a composing window manager or system compositor has [brought many advantages to your desktop](https://en.wikipedia.org/wiki/Compositing_window_manager).  Remember when you could "paint" the screen with your hung app?  Those were not fun times.
 
# Give me your bitmaps
What you may not realize is that, up until recently, DWM has only supported bitmaps as it's primary input type.  For example if you are writing an application and need to display content like a button your application will ultimately need to produce a bitmap representation of the button using either GDI or DirectX in order for DWM to be able to draw it.  Furthermore, if your application has a desire to use more exotic content such as text or non-rectangular shapes, these also need to be rasterized as bitmaps as well.  Oh and animations? you will need to produce a bitmap for every frame at display refresh rate (~60Hz).  

In reality, as app developers, we are not aware of any of this byzantine complexity because our friendly UI frameworks are doing all this heavy lifting for us.  Thankfully.

# Enter Primitives
Since Windows 8, DWM has got a lot smarter adding support for a number of content primitives such as ```SpriteVisual```, ```SolidColorVisual``` etc to both make framework developrs lives simpler and also to provide direct access to the power of the Windows composition engine from application code.  In otherwords, your code can "call down" bellow the UI framework and directly program the visual tree.


# Animated vector all the things

![alt text](https://airbnb.io/lottie/images/ShowcaseWalgreens.gif)

It's hard to find a popular consumer app these days that doesn't have some kind of cute loading screen, welcome animation or app tutorial that doesn't contain a whealth of beautifuly crafted animated characters bringing a more playful, human feel to the scenario. This trend was accelerated with the advent of the [Lottie tool](https://airbnb.io/lottie/#/) from Air BnB which made it much easier for designs to create said animations and dev's to get the resulting assets into their codebase.  

# Native Animated Vector Graphics in Windows

To be bring this capability to Windows in an efficient way, the composition team set out on a jouney to add a rich set of vector animation primitives to the engine, staring in the 1809 update and delivering in a complete end to end implementation in the Spring 2019 release.  We are releasing both a series of API's that bring low level capabilities to the platform, a toolchain to enable a Lottie-based designer developer workflow from After Effects and a new XAML control that makes it easy for UI developers to incorporate vector animation in apps.  

Becuase the low-level support is implemented in a framework agnostic way in the DWM itself, it's possible to get animated vector support in UWP XAML Apps, WPF, Winforms and even desktop win32 apps.

# Hello Shape 
For the remainder of this post I will show how to actually use the low level primitives the team has added.  I figured we'd start off at the lowest level and build up from there.

Since we are starting low level, I decided to lead with a C++ win32 sample using [c++/winrt](https://docs.microsoft.com/en-us/windows/uwp/cpp-and-winrt-apis/intro-to-using-cpp-with-winrt).  C++ desktop developers have been less well served with good samples and, since the API's here work everywhere, it's as good a place as any to start.  Pluss c++/WINRT makes it super easy to call WinRT API's from win32.  In the next post I'll show how to use some of the higher level tooling to automate the workflow.

Let's start by creating a basic shape using a ShapeVisual:

```c++
void Scenario1SimpleShape(const Compositor & compositor, const ContainerVisual & root) {

	// Create a new ShapeVisual that will contain our drawings
	ShapeVisual shape = compositor.CreateShapeVisual();
	shape.Size({ 100.0f,100.0f });
```

This should feel pretty familiar if you have previously experimented with the Windows Visual Layer at all.  Next we need a gemotry:

```c++
	// Create a circle geometry and set it's radius
	auto circleGeometry = compositor.CreateEllipseGeometry();
	circleGeometry.Radius(float2(30, 30));
```

to get the geometry to show up we need to create a SpriteShape from the geometry and set up a brush to fill it with:

```c++
	// Create a shape object from the geometry and give it a color and offset
	auto circleShape = compositor.CreateSpriteShape(circleGeometry);
	circleShape.FillBrush(compositor.CreateColorBrush(Windows::UI::Colors::Orange()));
	circleShape.Offset(float2(50, 50));
```

and finaly get it in the visual tree:

```c++
	// Add the circle to our shape visual
	shape.Shapes().Append(circleShape);

	// Add to the visual tree
	root.Children().InsertAtTop(shape);
```

OK, simple stuff.  Now, how about we create a more interesting composition path using Direct2D.  We need a couple of helpers to achieve this, firstly we are going to use a nice linear gradient as our fill, hence the first helper creates one of those using our compositor.  We're going to use three color stops.

```c++
// Helper funciton to create a GradientBrush
Windows::UI::Composition::CompositionLinearGradientBrush CreateGradientBrush(const Compositor & compositor)
{
	auto gradBrush = compositor.CreateLinearGradientBrush();
	gradBrush.ColorStops().InsertAt(0, compositor.CreateColorGradientStop(0.0f, Windows::UI::Colors::Orange()));
	gradBrush.ColorStops().InsertAt(1, compositor.CreateColorGradientStop(0.5f, Windows::UI::Colors::Yellow()));
	gradBrush.ColorStops().InsertAt(2, compositor.CreateColorGradientStop(1.0f, Windows::UI::Colors::Red()));
	return gradBrush;
}
```

The next helper object contains some boilerplate code needed to convert from an ID2D1Geometry interface to an interop interface called ```IGeometrySource2DInterop``` that is used by CompositionPath in the constructor. 

```c++
// Helper class for converting geometry to a composition compatible geometry source
struct GeoSource final : implements<GeoSource,
	Windows::Graphics::IGeometrySource2D,
	ABI::Windows::Graphics::IGeometrySource2DInterop>
{
public:
	GeoSource(com_ptr<ID2D1Geometry> const & pGeometry) :
		_cpGeometry(pGeometry)
	{ }

	IFACEMETHODIMP GetGeometry(ID2D1Geometry** value) override
	{
		_cpGeometry.copy_to(value);
		return S_OK;
	}

	IFACEMETHODIMP TryGetGeometryUsingFactory(ID2D1Factory*, ID2D1Geometry** result) override
	{
		*result = nullptr;
		return E_NOTIMPL;
	}

private:
	com_ptr<ID2D1Geometry> _cpGeometry;
};

```

Next, let's use those two helpers to create a simple path using Direct2D.  The ShapeVisual configuration is the same as in the first example.

```c++
void Scenario2SimplePath(const Compositor & compositor, const ContainerVisual & root) {
	// Same steps as for SimpleShapeImperative_Click to create, size and host a ShapeVisual
	ShapeVisual shape = compositor.CreateShapeVisual();
	shape.Size({ 500.0f, 500.0f });
	shape.Offset({ 300.0f, 0.0f, 1.0f });
```

For this example, we are going to use Direct2D to create a custom path using a ```ID2D1GeometrySink``` to help construct the path using line segments of different types:

```c++
	// Create a D2D Factory
	com_ptr<ID2D1Factory> d2dFactory;
	check_hresult(D2D1CreateFactory(D2D1_FACTORY_TYPE_SINGLE_THREADED, d2dFactory.put()));

	com_ptr<GeoSource> result;
	com_ptr<ID2D1PathGeometry> path;

	// use D2D factory to create a path geometry
	check_hresult(d2dFactory->CreatePathGeometry(path.put()));

	// for the path created above, create a Geometry Sink used to add points to the path
	com_ptr<ID2D1GeometrySink> sink;
	check_hresult(path->Open(sink.put()));

	// Add points to the path
	sink->SetFillMode(D2D1_FILL_MODE_WINDING);
	sink->BeginFigure({ 1, 1 }, D2D1_FIGURE_BEGIN_FILLED);
	sink->AddLine({ 300, 300 });
	sink->AddLine({ 1, 300 });
	sink->EndFigure(D2D1_FIGURE_END_CLOSED);
	
	// Close geometry sink
	check_hresult(sink->Close());
```

we can then take the path geometry and construct a ```CompositionPath``` from that, get a ```CompositionPathGeometry``` back and finally another ```SpriteShape``` object to give to shapevisual and get into the visual tree.  Phew.

```c++
	// Create a GeoSource helper object wrapping the path
	result.attach(new GeoSource(path));
	CompositionPath trianglePath = CompositionPath(result.as<Windows::Graphics::IGeometrySource2D>());

	// create a CompositionPathGeometry from the composition path
	CompositionPathGeometry compositionPathGeometry = compositor.CreatePathGeometry(trianglePath);

	// create a SpriteShape from the CompositionPathGeometry, give it a gradient fill and add to our ShapeVisual
	CompositionSpriteShape spriteShape = compositor.CreateSpriteShape(compositionPathGeometry);
	spriteShape.FillBrush(CreateGradientBrush(compositor));

	// Add the SpriteShape to our shape visual
	shape.Shapes().Append(spriteShape);

	// Add to the visual tree
	root.Children().InsertAtTop(shape);
}
```

At this point you may be wondering, where the animated part comes in.  Fear not, we're getting to that now.  Let's see what it takes to build a morph animation between two shapes.  Here I've encapsulated the path building into a helper function for brevity.

```c++
void Scenario3PathMorphImperative(const Compositor & compositor, const ContainerVisual & root) {
	// Same steps as for SimpleShapeImperative_Click to create, size and host a ShapeVisual
	ShapeVisual shape = compositor.CreateShapeVisual();
	shape.Size({ 500.0f, 500.0f });
	shape.Offset({ 600.0f, 0.0f, 1.0f });

	com_ptr<ID2D1Factory> d2dFactory;
	check_hresult(D2D1CreateFactory(D2D1_FACTORY_TYPE_SINGLE_THREADED, d2dFactory.put()));

	// Call helper functions that use Win2D to build square and circle path geometries and create CompositionPath's for them
	auto squarePath = BuildSquarePath(d2dFactory);

	auto circlePath = BuildCirclePath(d2dFactory);

	// Create a CompositionPathGeometry, CompositionSpriteShape and set offset and fill
	CompositionPathGeometry compositionPathGeometry = compositor.CreatePathGeometry(squarePath);
	CompositionSpriteShape spriteShape = compositor.CreateSpriteShape(compositionPathGeometry);
	spriteShape.Offset({ 150.0f, 200.0f });
	spriteShape.FillBrush(CreateGradientBrush(compositor));
```

and the interesting / magic part comes in where we can use a new overload of ```InsertKeyFrame``` that accepts a CompositionPath as the value parameter which can be different for different keyframes.  The engine will do the right thing and perform path interpolation between keyframes as the animation plays forwards or backwards:

```c++
	// Create a PathKeyFrameAnimation to set up the path morph passing in the circle and square paths
	auto playAnimation = compositor.CreatePathKeyFrameAnimation();
	playAnimation.Duration(std::chrono::seconds(4));
	playAnimation.InsertKeyFrame(0, squarePath);
	playAnimation.InsertKeyFrame(0.3F, circlePath);
	playAnimation.InsertKeyFrame(0.6F, circlePath);
	playAnimation.InsertKeyFrame(1.0F, squarePath);

	// Make animation repeat forever and start it
	playAnimation.IterationBehavior(AnimationIterationBehavior::Forever);
	playAnimation.Direction(AnimationDirection::Alternate);
	compositionPathGeometry.StartAnimation(L"Path", playAnimation);

	// Add the SpriteShape to our shape visual
	shape.Shapes().Append(spriteShape);

	// Add to the visual tree
	root.Children().InsertAtTop(shape);
}
```

So there we have a nice morph animation running in the system compositor with relatively little code.  But for the majority of us, we typically don't want to programatically define animations.  Simply put, it is very hard to visualize, tweek and get them just right with this approach.  We really want to use a tool that ideally a designer can use to do this for us.  The final example illustrates that approach.  Here, we are taking code generated as output from Lottie Tool, an opensource tool we're shipping

If you are a c# developer, the version of the tool that is [shipping in the store is all you need](https://www.microsoft.com/store/productId/9P7X9K692TMW).  If you are a c++ developer, you'll need to grab the PR I have open on the Lottie Windows repo [here](https://github.com/windows-toolkit/Lottie-Windows/pull/64) as a temporary measure until it is completed.

I plan on doing a followup post on the workflow here so for now we'll just use the pre-canned version I already made. 

First off, here is a simple helper function to play back the animation.  We're using a "master" animation named Progress to drive progress on the imported animation as a whole.  This enables us to control the playback speed, go forwards / backwards, pause etc.  If you are a XAML developer and looking to integrated animated vector graphics, there is a handy control that can take care of all of this, but since we are looking at the low level example first this is how you need to role. 

```c++
ScalarKeyFrameAnimation Play(const Compositor & compositor, Visual const & visual) {
	auto progressAnimation = compositor.CreateScalarKeyFrameAnimation();
	progressAnimation.Duration(std::chrono::seconds(5));
	progressAnimation.IterationBehavior(AnimationIterationBehavior::Forever);
	progressAnimation.Direction(AnimationDirection::Alternate);
	auto linearEasing = compositor.CreateLinearEasingFunction();
	progressAnimation.InsertKeyFrame(0, 0, linearEasing);
	progressAnimation.InsertKeyFrame(1, 1, linearEasing);
	
	visual.Properties().StartAnimation(L"Progress", progressAnimation);
	return progressAnimation;
}
```

This is clearly considerably less / simpler code to get a much more impressive results with all of the heavy lifting taken care of us inside the generated code.  Make machines do the hard work!

```c++
    // configure a container visual
	float width = 400.0f, height = 400.0f;
	SpriteVisual container = compositor.CreateSpriteVisual();
	container.Size({ width, height });
	container.Offset({ 0.0f, 350.0f, 1.0f });
	root.Children().InsertAtTop(container);

	AnimatedVisuals::LottieLogo1 bmv;

	winrt::Windows::Foundation::IInspectable diags;
	auto avptr = bmv.TryCreateAnimatedVisual(compositor, diags);

	auto visual = avptr.RootVisual();
	container.Children().InsertAtTop(visual);

	//// Calculate a scale to make the animation fit into the specified visual size
	container.Scale({ width / avptr.Size().x, height / avptr.Size().y, 1.0f });

	auto playanimation = Play(compositor, visual);
```

Thanks for reading to the end, if you are interested in reading more details check out the documentation as well as the [source code](https://github.com/windows-toolkit/Lottie-Windows) for the Lottie Windows tool mentioned above as well as the official documentation for the API's [here](https://docs.microsoft.com/en-us/windows/communitytoolkit/animations/lottie) and we'd love feedback on twitter [@windowsui](https://twitter.com/windowsui) or to me personally [@clarkezone](https://twitter.com/clarkezone).