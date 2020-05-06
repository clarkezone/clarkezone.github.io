---
layout: post
title:  "ASP.NET Core 3.1 WebAPI: The case of the 400 Bad Request"
date: 2020-04-15 08:51:02 -0800
categories: [REST]
tags: [ASP.NET Core]
---

I've recently been spending a lot of time getting back into the groove with distributed computing.  As part of that I'm been kicking the tires of .NET Core for the first time (and loving it so far, but that's another story).  A couple of weeks ago, came across a classic problem which I'm sure all the backend web developers have come across in the past: a mysterious 400 Bad Request.  I had created and deployed a simple REST API using a WebAPI endpoint backed by EntityFramework and a SQL database. Classic hello world scenario.  I was deploying Azure Linux App Service using modern shiny containers and was hitting it with a simple golang client to call the API.  Extremely simple stuff.  On the backend was a "modern" SQL database instance.  All of the read operations were working great but when it came time to test posting to the endpoint I started hitting a 400 Bad Request from WebAPI:

```bat
azureplayclient.exe LearningResource -create -name "JamesTest" -serviceid "6ca52516-d42e-46a1-6a0e-087dd9ec1a7" -uri "http://mytestlearningresource"

2020/05/04 16:49:17 Post failed: 400 Bad Request
```

Time to dig in.  I started off by looking for hooks in the API Controller to try and catch the exceptions and find the cause of the problem.  I came across a `UseExceptionHandler` property on the `IApplicationBuilder` object which I duely hooked up:

Next idea was to try hooking the action as it was executing, I started looking into overriding `OnActionExecuting(ActionExecutingContext)`

Finally I figured it was time to really roll up the sleaves.  Turning on all throw exceptions, 