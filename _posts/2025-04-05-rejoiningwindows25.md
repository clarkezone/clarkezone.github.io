---
layout: post
title: "Rejoining the Windows team in 2025"
date: 2025-04-05
categories: [microsoft, windows]
---

As Microsoft turns 50 and I find myself starting a new position on the Windows team after 5 years in Azure land it seems fitting, if not a little self indulgent, to reminisce about previous experiences working here.

![IMG_1646.jpeg](https://res.craft.do/user/full/c9a642f5-5273-cf94-66ad-848e55a9014f/doc/F0B674C7-08D6-4DB0-A654-D0AF6A689371/6E1FDE0B-825F-4E9B-AA0F-CA2E34982AE7_2/zoD7oerVecPYJkaT8y8ZGwmmrB24inDPBKnc7Qac3w0z/IMG_1646.jpeg)

**Windows 8 era**

My first experience in Windows came in 2011 when I moved to the DWM/Compositor team (known as presentation and composition),  from the Microsoft Expression team; this was around the start of planning for Windows 8.  I had been working on Silverlight developer tooling and in the transition, aspired to contributing to building out native XAML as the developer surface for Windows.  Ironically, I would end up working on a new UI platform based on HTML. Consequently I devoted the next 3 years to leading feature crews building and shipping CSS extensions (animations, transforms et al) in the Internet Explorer Trident codebase and separately bringing up a new low level graphics API for UI composition (DirectComposition) that we then used to hardware accelerate the CSS.  It was kind of like building the house and the foundations at the same time.  The result was the “fast and fluid” touch experiences in that shipped in Windows 8 powering the new full screen Start menu, web-based apps and the web platform panning and zooming experience.  Although there are aspects of WIndows 8 that clearly were untenable (like removing the Start button!), I remain extremely proud with the work the team did to start laying modern UX foundations.

![HomeSelect.png](https://res.craft.do/user/full/c9a642f5-5273-cf94-66ad-848e55a9014f/doc/F0B674C7-08D6-4DB0-A654-D0AF6A689371/F1A8C6B8-457A-415A-A49F-0BCE9126E123_2/yO4Xw2iFLFO7B2t1yC5kDxDxDEWhdyLRSqPuxAZE5kEz/HomeSelect.png)



![IMG_1582.jpeg](https://res.craft.do/user/full/c9a642f5-5273-cf94-66ad-848e55a9014f/doc/F0B674C7-08D6-4DB0-A654-D0AF6A689371/57A12C0C-6714-4A60-85E6-27970E258972_2/fvJTFNV4iAgaP6FomlkCEsUCHCwASvPB4fMkh7CnKx4z/IMG_1582.jpeg)
Bumping into Steve Ballmer at the Windows 8 ship party.



In Windows 8.1 aka Windows Blue, I moved on from graphics to work on the user32 / ntuser subsystem, [High DPI](https://learn.microsoft.com/en-us/windows/win32/hidpi/high-dpi-desktop-application-development-on-windows) and a bunch of other low level Win32 APIs.  I also led the effort to enable picker hosting (eg from the photos app) in the open file dialog.  Sounds riveting I know!

**Windows 10 era**

After the [merger of the Windows Phone and Windows teams](https://www.theverge.com/2013/7/12/4515830/terry-myerson-microsoft-windows-reorganization), I became a founding member of a new team called Windows Composition whose mission was to build a modern high level set of APIs and platform capabilities to bring Windows up to par with Apple’s CoreAnimation, thus unlocking richer effects and animation capabilities; that could be leveraged in C# XAML apps as well as in C++ desktop apps.  We took an already strong team of engineers and PMs from Windows and added the phone crew who had been behind the excellent Windows Phone 7 UI infrastructure and Home Screen experience.  This was one of the most talented and effective teams I've worked on in my career thus far.

**The Visual layer**

For the Windows 10 release, we set out to combine the best of the "Splash" compositor from Zune and Windows phone with the power of the Desktop Window Manager (DWM) system compositor and DirectComposition COM API from Windows to deliver a new level of rich capabilities, hither to unseen on Windows.  Secondarily, we aimed to build a new "converged" API surface based on WinRT to enable both managed and native c++ developers to be able to take advantage of all the new capabilities, was well as enabling the XAML stack to replatform their animation system on top.  We call the result of this effort the Windows Visual Layer which you may know it as Windows.UI.Compostion.

![IMG_0114.jpeg](https://res.craft.do/user/full/c9a642f5-5273-cf94-66ad-848e55a9014f/doc/F0B674C7-08D6-4DB0-A654-D0AF6A689371/32A38C65-B97B-4BC7-921C-70334BED3B82_2/6n3rqYxOHyweFVgy7gtzxXzOLTE9d1JQSGQwYxoYx0Iz/IMG_0114.jpeg)
Yours truly delivering //Build/ talk in 2015 unveiling the Visual Layer to developers



![IMG_3443.jpeg](https://res.craft.do/user/full/c9a642f5-5273-cf94-66ad-848e55a9014f/doc/F0B674C7-08D6-4DB0-A654-D0AF6A689371/A803821A-C480-40FB-A3F8-817CD2261393_2/NjpFF5NPdzSw8pfU55iyHDxH09ddmI9zmvyniHnOGzUz/IMG_3443.jpeg)

![IMG_3461.jpeg](https://res.craft.do/user/full/c9a642f5-5273-cf94-66ad-848e55a9014f/doc/F0B674C7-08D6-4DB0-A654-D0AF6A689371/8715F40E-024C-47EC-8AE8-33DBB68113F8_2/Ep4lsgkkqc1Qow8ns2jdJ5EeY2luDNypDqK1FyuKES4z/IMG_3461.jpeg)

[Smooth as Butter Animations in the Visual Layer with the Windows 10 Creators Update](https://blogs.windows.com/windowsdeveloper/2017/06/23/smooth-butter-animations-visual-layer-windows-10-creators-update/)

[Building amazing applications with the Fluent Design System](https://learn.microsoft.com/en-us/shows/visual-studio-connect-event-2017/b107)

The Visual Layer went on to power "Project Neon" aka the original Fluent Design System which debued in the "Fall Creators Update"

![composit.png](https://res.craft.do/user/full/c9a642f5-5273-cf94-66ad-848e55a9014f/doc/F0B674C7-08D6-4DB0-A654-D0AF6A689371/b23c4b1d-5887-635c-abc9-cc4d000a1907/oOvMpRmYjys7URDApBY0WALvcuypAG0bXL6dSyRzeLQz/composit.png)

Some of the other initiatives I was involved with in the Windows 10 timeframe included working on the High DPI problem, Windowing and input not to mention a bunch of first party device specific work.  Whilst not as sexy, it was nevertheless important work that impacted many users and thus in many ways just as rewarding.

After a 12 year journey which was in many ways my dream job, I left Windows in 2020 to join Azure to work on service quality and internal cloud-native infrastructure.

Microsoft Store on Windows

We delivered the Visual Layer in 2015 and nearly 10 years later the API's and runtime continue to underpin Windows system experiences and apps.  In my opinion, one of the best examples of what the VIsual Layer and XAML can do is embodied in the Windows Store.  I find it so gratifying to see all the capabilities we built being leveraged in one of the flagship experiences in Windows.

A few weeks back, I was very fortunate to join the team as an Engineering Manager; I’m delighted to be returning to my roots and getting more hands on with the code as well as the opportunity to lead a new team.  I also get to work with a new set of amazing people such as [Giorgio](https://x.com/gisardo), [Justin](https://x.com/justinxinliu), [Rudy](https://x.com/rudyhuyn), [Sergio](https://x.com/sergiopedri), [Emil](https://x.com/petroemil) and [Shmueli](https://x.com/shmueli), . The team is passionate about building the best and most performant native experiences and I'm humbled to be joining the group.

![Image.jpeg](https://res.craft.do/user/full/c9a642f5-5273-cf94-66ad-848e55a9014f/doc/F0B674C7-08D6-4DB0-A654-D0AF6A689371/58207422-3f81-dda4-ff6d-10969b213cc9/POcrmU5Mq7EV0zl0zT5rSUxJjdg5lRbUPq3SlTo513gz/Image.jpeg)

![Image.jpeg](https://res.craft.do/user/full/c9a642f5-5273-cf94-66ad-848e55a9014f/doc/F0B674C7-08D6-4DB0-A654-D0AF6A689371/3281c922-fba4-3897-6b47-7019edc1ea05/72X0isXzzY0XvXnUmcggLjw4DqSMAD4RwcAZpI7AL9Az/Image.jpeg)

Onwards!
