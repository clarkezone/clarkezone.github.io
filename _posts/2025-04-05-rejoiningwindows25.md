---
layout: post
title: "Rejoining the Windows team in 2025"
date: 2025-04-05
categories: [microsoft, windows]
---

As [Microsoft turns 50](https://news.microsoft.com/microsoft-50/) and I find myself starting a new position on the Windows team after 5 years in Azure land it seems fitting, if not a little self indulgent, to reminisce about previous experiences working here.

![IMG_1646.jpeg](/static/img/2025-04-05-rejoiningwindows/IMG_1646.jpeg)

**Windows 8 era**

My first experience in Windows came in 2011 when I moved to the [DWM/Compositor](https://learn.microsoft.com/en-us/windows/win32/dwm/dwm-overview) team (known as Presentation and Composition),  from the [Microsoft Expression](https://en.wikipedia.org/wiki/Microsoft_Expression_Studio) team; this was around the start of planning for Windows 8.  I had been working on [Silverlight developer](https://en.wikipedia.org/wiki/Microsoft_Silverlight) tooling and in the transition, aspired to contributing to building out native XAML as the developer surface for Windows.  Ironically, I would end up working on a new UI platform based on HTML. Consequently I devoted the next 3 years to leading feature crews building and shipping CSS extensions ([animations](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_animations/Using_CSS_animations), transforms et al) in the [Internet Explorer Trident](https://en.wikipedia.org/wiki/Trident_(software)) codebase and separately bringing up a new low level graphics API for UI composition ([DirectComposition](https://learn.microsoft.com/en-us/windows/win32/directcomp/directcomposition-portal)) that we then used to hardware accelerate the CSS.  It was kind of like building the house and the foundations at the same time.  The result was the “fast and fluid” touch experiences in that shipped in Windows 8 powering the new full screen Start menu, web-based apps and the web platform panning and zooming experience.  Although there are aspects of WIndows 8 that clearly were untenable (like removing the Start button!), I remain extremely proud with the work the team did to start laying modern UX foundations.

![HomeSelect.png](/static/img/2025-04-05-rejoiningwindows/HomeSelect.png)



![IMG_1582.jpeg](/static/img/2025-04-05-rejoiningwindows/IMG_1582.jpeg)
*Bumping into Steve Ballmer at the Windows 8 ship party.*



In [Windows 8.1 aka Windows Blue](https://en.wikipedia.org/wiki/Windows_8.1), I moved on from graphics to work on the [user32](https://en.wikipedia.org/wiki/Windows_USER) / ntuser subsystem, [High DPI](https://learn.microsoft.com/en-us/windows/win32/hidpi/high-dpi-desktop-application-development-on-windows) and a bunch of other low level Win32 APIs.  I also led the effort to enable picker hosting (eg from the photos app) in the open file dialog.  Sounds riveting I know!

**Windows 10 era**

After the [merger of the Windows Phone and Windows teams](https://www.theverge.com/2013/7/12/4515830/terry-myerson-microsoft-windows-reorganization), I became a founding member of a new team called Windows Composition whose mission was to build a modern high level set of APIs and platform capabilities to bring Windows up to par with Apple’s CoreAnimation, thus unlocking richer effects and animation capabilities; that could be leveraged in C# XAML apps as well as in C++ desktop apps.  We took an already strong team of engineers and PMs from Windows and added the phone crew who had been behind the excellent [Windows Phone 7](https://en.wikipedia.org/wiki/Windows_Phone_7) UI infrastructure and Home Screen experience.  This was one of the most talented and effective teams I've worked on in my career thus far.

**The Visual layer**

For the Windows 10 release, we set out to combine the best of the "Splash" compositor from Zune and Windows phone with the power of the Desktop Window Manager (DWM) system compositor and DirectComposition COM API from Windows to deliver a new level of rich capabilities, hither to unseen on Windows.  Secondarily, we aimed to build a new "converged" API surface based on WinRT to enable both managed and native C++ developers to be able to take advantage of all the new capabilities, was well as enabling the XAML stack to replatform their animation system on top.  We call the result of this effort the Windows Visual Layer which you may know it as Windows.UI.Compostion.

![IMG_0114.jpeg](/static/img/2025-04-05-rejoiningwindows/IMG_0114.jpeg)
*Yours truly delivering //Build/ talk in 2015 unveiling the Visual Layer to developers*



![IMG_3443.jpeg](/static/img/2025-04-05-rejoiningwindows/IMG_3443.jpeg)
*Windows 10 ship party*

![IMG_3461.jpeg](/static/img/2025-04-05-rejoiningwindows/IMG_3461.jpeg)
*Windows 10 ship party*

[Smooth as Butter Animations in the Visual Layer with the Windows 10 Creators Update](https://blogs.windows.com/windowsdeveloper/2017/06/23/smooth-butter-animations-visual-layer-windows-10-creators-update/)

[Building amazing applications with the Fluent Design System](https://learn.microsoft.com/en-us/shows/visual-studio-connect-event-2017/b107)

The Visual Layer went on to power "Project Neon" aka the original Fluent Design System which debued in the "Fall Creators Update"

![composit.png](/static/img/2025-04-05-rejoiningwindows/composit.png)

Some of the other initiatives I was involved with in the Windows 10 timeframe included more work on the High DPI problem, [Windowing](https://learn.microsoft.com/en-us/shows/build-2018/brk3506) and input not to mention a bunch of first party device specific work.  Whilst not as sexy, it was nevertheless important work that impacted many users and thus in many ways just as rewarding.

After a 12 year journey which was in many ways my dream job, I left Windows in 2020 to join Azure to work on [service quality](https://azure.microsoft.com/en-us/blog/advancing-microsoft-azure-reliability/) and internal cloud-native infrastructure based on Kubernetes.

**Microsoft Store on Windows**

We delivered the Visual Layer in 2015 and nearly 10 years later the API's and runtime continue to underpin Windows system experiences and apps.  In my opinion, one of the best examples of what the Visual Layer and XAML can do is embodied in the [Windows Store](https://apps.microsoft.com/home?hl=en-US&gl=US) now known as the Microsoft Store on Windows.  I find it so gratifying to see all the capabilities we built being leveraged in one of the flagship experiences in Windows.

A few weeks back, I was very fortunate to join the team as an Engineering Manager; I’m delighted to be returning to my roots and getting more hands on with the code as well as the opportunity to lead a new team.  I also get to work with a new set of amazing people such as [Giorgio](https://x.com/gisardo), [Justin](https://x.com/justinxinliu), [Rudy](https://x.com/rudyhuyn), [Sergio](https://x.com/sergiopedri), [Emil](https://x.com/petroemil) and [Shmueli](https://x.com/shmueli), . The team is passionate about building the best and most performant native experiences and I'm humbled to be joining the group.

![Image1.jpeg](/static/img/2025-04-05-rejoiningwindows/Image1.jpeg)

![Image2.jpeg](/static/img/2025-04-05-rejoiningwindows/Image2.jpeg)

Onwards!
