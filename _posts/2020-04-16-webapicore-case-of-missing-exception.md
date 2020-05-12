---
layout: post
title:  "ASP.NET Core 3.1 WebAPI: The case of the failing POST request"
date: 2020-04-15 08:51:02 -0800
categories: [REST]
tags: [ASP.NET Core]
---

I've recently been spending a lot of time getting back into the groove with distributed computing.  As part of that I'm been kicking the tires of .NET Core for the first time (and loving it so far, but that's another story).  A couple of weeks ago, came across a classic problem which I'm sure all backend web developers have come across all too often: a mysterious 400 Bad Request.

I had created and deployed a simple REST API using a WebAPI endpoint backed by EFCore and a SQL database. Classic hello world scenario.  I was deploying to Azure Linux App Service using modern shiny containers and then hitting it with a simple golang client to call the API.  Extremely simple stuff.  All of the GET calls were working great but when it came time to test a create operation via a POST I started seeing a 400 Bad Request from WebAPI:

```bat
azureplayclient.exe LearningResource -create -name "JamesTest" -serviceid "6ca52516-d42e-46a1-6a0e-087dd9ec1a7" -uri "http://mytestlearningresource"

2020/05/04 16:49:17 Post failed: 400 Bad Request
```

Time to dig in.  The first step was to look at my Azure telemetry to see if I could get any clues from there.  Only problem was, I discovered my app had no Azure telementry!  OK why is that?  Turns out I hadn't gone through the steps detailed here:

[https://docs.microsoft.com/en-us/azure/azure-monitor/app/asp-net-core#feedback](https://docs.microsoft.com/en-us/azure/azure-monitor/app/asp-net-core#feedback)

which were super helpful and got me up and running with the client library configured and a telemetry endpoint set up in azure by simply picking Add Application Insights from the project menu in VS:

![adding](/static/img/2020-5-6-case-of-failing-post/addtelemetry.png)

![telemtry](/static/img/2020-5-6-case-of-failing-post/telemetrythingsadded.png)

Let's check this is running by deliberately throwing an exception in our view controller:

```cs
 [HttpGet("foo")]
 public void Foo() {
    throw new Exception("Test exception");
 }

```

and low and behold this shows up under the failures tab in the portal:

![telemtry](/static/img/2020-5-6-case-of-failing-post/exceptiondetails.png)

Furthermore, there is a really nice feature called live metrics which even shows events happening in realtime including good / bad request and, yes, exceptions!  Look, ma there it is.

![realtimedetections](/static/img/2020-5-6-case-of-failing-post/lookmatheresmyexception.png)

I was certainly emblodened by this new found sense of data infused power.  But I did stop short of investigating snapshot debugging which will have to wait for a later foray.

As I dug deeper, it was clear that although the telemetry did show my failing request as a 400 error, becuase the framework was catching the error I was no closer to understanding the problem.

I started off by looking for hooks in the API Controller to try and catch the exceptions and find the cause of the problem.  I came across a `UseExceptionHandler` property on the `IApplicationBuilder` object which, in retrospect, seems more about how to handle and report the error but still seemed like it might help me route-cause the problem:

```cs
app.UseExceptionHandler(a => a.Run(async context =>
{
    var feature = context.Features.Get<IExceptionHandlerPathFeature>();
    var exception = feature.Error;
    await context.Response.WriteAsync(exception.ToString());
}));
```

Next idea was to try hooking the action as it was executing to see if the exception would be exposed there somehow (hint of desperation creeping in here), I started looking into overriding `OnActionExecuting(ActionExecutingContext)` in my API Controller:

```cs
public override void OnActionExecuting(ActionExecutingContext filterContext)
{
    // Do whatever here...
    Debug.WriteLine("can i somehow handle the exception here?  Erm turns out no.");
}
```

So now, ASP.NET the gloves come off.

This is the moment, pre-opensource of .NET, that nasty words would have start to have flown liberaly.  Luckily, these days we can simply check a box.

![jekyll image](/static/img/2020-5-6-case-of-failing-post/enablesourcestepping.png)

and turn on thown CLR Runtime exceptions.  That immediately yeilded the exception that was being thrown inside of System.Text.Json, specifically:

`System.FormatException: THe JSON value is not in a supported Guid format'`

Drilling in further, turned out I'd missed a parameter in my JSON package and actually I was passing NULL.  Doh; well that certainly won't deserialize into a GUID.  But this did cause me to scratch my head and wonder why the heck I don't just get with the program and code generate my API contract like the cool SOAP kids were doing 20 years ago.  An email to Tim Heuer later and I'm now hooked up with swashbuckle and ready to navigate the novel world of Swagger.  Something for a future post.