---
layout: post
title:  "ASP.NET Core 3.1 WebAPI: The case of the failing POST request"
date: 2020-05-25 08:51:02 -0800
categories: [rpc]
tags: [ASP.NET Core, Azure Telemetry]
---

I've recently been spending time getting back into the groove with distributed computing after a decade or so of absense.  As part of that I've been kicking the tires of .NET Core for the first time (and loving it so far, but that's another story).  A couple of weeks ago, I came across a classic problem which all backend web developers have encountered all too often: a mysterious 400 Bad Request error originating from a REST request.

I had created and deployed a simple REST API using a WebAPI endpoint backed by EFCore and a SQL database. Classic hello world scenario.  Deploying this to Azure Linux App Service using modern shiny containers and then hitting it with a simple golang client to call the API.  Extremely simple stuff.  All of the GET calls were working great but when it came time to test a `create` operation via a HTTP POST I started seeing a 400 Bad Request from WebAPI:

```bat
azureplayclient.exe LearningResource -create -name "JamesTest" -serviceid "6ca52516-d42e-46a1-6a0e-087dd9ec1a7" -uri "http://mytestlearningresource"

2020/05/04 16:49:17 Post failed: 400 Bad Request
```

Time to dig in.  The first step was to look at my Azure telemetry to see if I could get any clues from there.  Only problem was, I discovered my app had no Azure telementry!  OK why is that?  Turns out I hadn't gone through the steps detailed here:

[https://docs.microsoft.com/en-us/azure/azure-monitor/app/asp-net-core#feedback](https://docs.microsoft.com/en-us/azure/azure-monitor/app/asp-net-core#feedback)

Having found that article, was pretty quick to get up and running with the .NET client library and a telemetry endpoint set up in Azure by simply picking Add Application Insights from the project menu in VS:

![adding](/static/img/2020-05-25-case-of-failing-post/addtelemetry.png)

resulting in a configured environment:

![telemtry](/static/img/2020-05-25-case-of-failing-post/configured.png)

By default the telemetry system is set up to collect bad requests and unhandled exceptions.  Let's quickly check this by deliberately throwing an exception in our view controller:

```cs
 [HttpGet("foo")]
 public void Foo() {
    throw new Exception("Test exception");
 }

```

Low and behold the exception shows up in the Application Insights blade under the failures tab in the portal:

![telemtry](/static/img/2020-05-25-case-of-failing-post/exceptiondetails.png)

Furthermore, there is a really nice feature called live metrics which even shows events happening in realtime including good / bad request and, yes, exceptions!  Look, ma there it is.

![realtimedetections](/static/img/2020-05-25-case-of-failing-post/lookmatheresmyexception.png)

I was certainly emboldened by this new found sense of data infused power but did stop short of investigating snapshot debugging which will have to wait for a later foray.

As I dug deeper, it was clear that although the telemetry did show my failing request as a 400 error, becuase the .NET framework layer was catching the exception and mapping to bad request I was no closer to understanding the problem.

![telemtry](/static/img/2020-05-25-case-of-failing-post/400error.png)

To dig in further, I started a hunt for aditional places to tap in to the ASP.NET pipeline first of which  was the `UseExceptionHandler` property on the `IApplicationBuilder` object.   Quick test showed no dice:

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

Finally, I tried overriding the `BadRequestRest`, and `BadRequestObjectResult` overridese on the view controller all to no avail.  In summary, I don't know if there is a way of catching deserializing errors such as these and getting the internal call stack.. if you know of one do leave a comment on this post.

So now, ASP.NET the gloves come off.

This is the moment, pre-opensource of .NET, that nasty words would have start to have flown liberaly.  Luckily, these days we can simply check a box.

![jekyll image](/static/img/2020-05-25-case-of-failing-post/enablesourcestepping.png)

and turn on thown CLR Runtime exceptions.  That immediately yeilded the exception that was being thrown inside of System.Text.Json, specifically:

`System.FormatException: THe JSON value is not in a supported Guid format'`

Drilling in further, turned out I'd missed a parameter in my JSON package and actually I was passing NULL.  Doh; well that certainly won't deserialize into a GUID.

## Enlightenment

In the course of getting this post proof-read by the most awesome Mark Osborn, a solution to the problem has come to light.  Turns out you can hook model validation errors and log them if desired.  The was a funny co-incidence here in that Mark had faced a similar issue that I was facing and had done a better job at tracking down a workable solution.  Credit for what follows goes entirely to him!

Turns out that there is a property on the base `Controller` object called `ModelSate` and you can query it to see if it is valid.  I chose to do this by overriding `OnActionExecuted`; from there it's pretty trivial to extract which key is invalid.

This is what I ended up doing, logging the result to my Application Insights instance:

```cs
    public override void OnActionExecuted(ActionExecutedContext context)
    {
        if (!base.ModelState.IsValid)
        {
            var problemDetails = base.ProblemDetailsFactory.CreateValidationProblemDetails(base.HttpContext, base.ModelState);

            string errors = string.Join(";", problemDetails.Errors.Select(x => "key:" + x.Key + " error:" + x.Value[0]));

            _logger.LogWarning("Client API call failed with invalid model state: key {0} with problem ", errors);
        }
        base.OnActionExecuted(context);
    }
```

## Can we generate that?

At a high level, this incident did cause me to scratch my head and wonder why the heck I don't just get with the program and code generate my API contract like the cool SOAP kids were doing 20 years ago.  An email to Tim Heuer later and I'm now hooked up with swashbuckle and ready to investigate the novel world of Swagger.  Something for a future post.