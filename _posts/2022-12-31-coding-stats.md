---
layout: post
title:  "2022 Coding stats"
date: 2022-12-31 08:51:02 -0800
categories: [timetracking]
tags: [goalng]
---
Audience for this post: software developers

<img style="transform: translatex(0%);left:0; padding-right:20px" src="/static/img/2022-12-31-coding-stats/nwesso.jpeg" align="left"/>
I’m writing this post on my phone while backstage at Seatle Symphony on the last night of 2022. I'm here to sing tenor in the chorus performing Beethoven's 9th symphony in the New Year concert.  So first off,  very happy holidays and Happy New Year to all of you and thanks for staying subscribed!  One of my New Year resolutions for 2021 was to start blogging again which clearly hasn't gone so well as this is my first post here in over 2 years:-)  Hope you've had better luck with your goals and resolutions for 2022 as we close out the year.

I've been working on a bunch of blogging related infra that is yet to ship, so hoping that the fruits of those labors will be manifested over the course of 2023.  We will see how that goes; stay subscribed to find out and / or follow me on in the fediverse here: [https://hachyderm.io/@clarkezone](https://hachyderm.io/@clarkezone).
<br clear="left">
## Wakatime

How much coding did you do this year?  Do you know what you worked on?  Did you have any particular goals you were aiming for?  Did you neet them?  These were questions that I always wondered about at this time of year but never had very specific answers to until I started using Wakatime.  Now I have a dashboard and a annual summary which I just received for 2022:

![Summary](/static/img/2022-12-31-coding-stats/wakasummary.png)

I like Wakatime because it unobtrusively integrates with most popular editors I use (including terminal mode VIM) and tracks activity on a fairly granular basis so I can get a breakdown of editors, languages projects etc. 

## 2022 Insights

At a high level

1. I've been focussed on microservices hence golang is my top language
2. The totals are a bit skewed due to large amount of YAML infra work
3. I didn't do as much .NET 7 / Rust dev as planned.

Languages

![Summary](/static/img/2022-12-31-coding-stats/languages.png)

Editors

![Summary](/static/img/2022-12-31-coding-stats/editors.png)

OS

![Summary](/static/img/2022-12-31-coding-stats/osbreakdown.png)

To unpack the above a bit, my current focus at work is cloud native kubernetes and so golang targeting k8s on linux is where it's at and has been the most applicable language for me to be spending time in for microservice development.  I've been taking the opportunity to do more than kick the tires by going deeper and building some production services end-to-end.  Overall, I like the relative simplicity of the language, excellent tooling and overall consistency.

On the infra side, I've been doing a shit ton of infra and the numbers bare witness in YAML, Makefile, Docker.  This is not coding in the purest sence but shows up here as I'm using the same tools and it's coming from the same time budgets.  In general, there is still a massive opportunity for better tooling for working with YAML manifests, particularly in the kubernetes domain from validation, to refactoring and general power tooling.  But right now it is painful and takes way too much time.  I hope I don't spend 141 hours munging YAMl in 2023!

In terms of missed opportunities, I'm excited for .NET7 and was hoping to do more with it this year.  Same goes for Rust.  Just couldn't put enough focus there.  Hoping that will change in 2023

## Wrapup

Curious to know what you have been focussing on in the last year, dear reader?  Are you happy with your progress?  What are your goals for 2023?