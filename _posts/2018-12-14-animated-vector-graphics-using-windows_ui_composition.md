---
layout: post
title:  "Animated vector graphics using Windows::UI::Composition part 1"
date: 2019-02-24 01:00:45 -0800
categories: [blogging, WUC]
tags: [animation]
---
# Native bector graphics in Windows
This post describes new vector graphics APIs recently added to the Windows platform notably ShapeVisual todo, and how to use them from C++ in win32 desktop applications.  The sample I walk through along with versions written in C# are available in this repo: http://github.com:clarkezone/UWPCompositionDemos.

# Some History: Composition in the Windows DWM
## Give me your bitmaps
TODO: Picture of DWM in Vista composed desktop
Since Windows Vista, all roads from your applications UI tree to the monitor have gone via the Desktop Window Manager in the form of bitmaps.  In practice, if you need to display content like a button containing some text your application will ultimately need to produce a flattened bitmap representation of the button using either GDI bitmaps or DirectX textures in order for Windows it to draw.  Furthermore, if your application has a desire to use more exotic shapes, these also need to be rasterized as bitmaps as well.  Oh and animations? you will need a bitmap for every frame at display refresh rate (60Hz).  This probably sounds horrendously complex and indeed it is unless you happen to be a low level framework dev.  Luckily since the majority of us use frameworks like WPF or Windows::UI::Xaml we rarely have to worry about such details.

## Enter Primitives

Since Windows 8, DWM has got a lot smarter adding support for a number of content primitives such as SpriteVisual, SolidColorVisual etc to both make framework developrs lives simpler and also to provide direct access to the power of the composition engine from application code.  In otherwords, your code can "call down" bellow the UI framework and directly program the visual tree.

# Native Animated Vector Graphics
## Animated vector all the things
It's hard to find a popular mobile app these days that doesn't have some kind of cute loading screen, welcome animation, app tutorial that doesn't contain a whealth of beautifuly designed characters, dd motion to bring a more playful, human feel. TODO: example GIF.

To be bring this capability to Windows in an efficient way, the composition team set out on a jouney to add a rich set of vector animation primitives to the engine, staring in RS5 and delivering in a complete end to end implementation in 19H1.  We are releasing both a series of API's that bring low level capabilities to the platform, a toolchain to enable a designer developer workflow from After Effects and a new XAML control that makes it easy for UI developers to incorporate vector animation in apps.  

Becuase the low-level support is implemented in a framework agnostic way in the Compositor itself, it's possible to get animated vector support in UWP XAML Apps, WPF, Winforms and even desktop win32 apps.

## Hello Shape 
For the remainder of this post I will show how to use the low level primitives directly in a desktop win32 project in c++/winrt.  In the next post I'll show how to use some of the higher level tooling to 


 Let's start by creating a basic shape using a ShapeVisual


```c++
void Scenario1SimpleShape(const Compositor & compositor, const ContainerVisual & root) {

	// Create a new ShapeVisual that will contain our drawings
	ShapeVisual shape = compositor.CreateShapeVisual();
	shape.Size({ 100.0f,100.0f });
```

Next we need a gemotry

```c++
	// Create a circle geometry and set it's radius
	auto circleGeometry = compositor.CreateEllipseGeometry();
	circleGeometry.Radius(float2(30, 30));
```

to get the geometry to show up we need to 

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

So, let's use those two helpers to create a simple path using Direct2D.  The ShapeVisual configuration is the same as in the first example.

```c++
void Scenario2SimplePath(const Compositor & compositor, const ContainerVisual & root) {
	// Same steps as for SimpleShapeImperative_Click to create, size and host a ShapeVisual
	ShapeVisual shape = compositor.CreateShapeVisual();
	shape.Size({ 500.0f, 500.0f });
	shape.Offset({ 300.0f, 0.0f, 1.0f });
```

For this example, we are going to use a ```ID2D1GeometrySink``` to build up the actual path.  So we need to create a couple of objects that allow us to get back

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