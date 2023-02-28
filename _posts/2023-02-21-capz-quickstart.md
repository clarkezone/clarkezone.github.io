---
layout: post
title:  "Kubernetes Cluster API for Azure quick start"
date: 2023-02-21 08:51:02 -0800
categories: [kubernetes]
tags: [CAPI, CAPZ]
---
Audience for this post: kubernetes admins, SRE, dev ops 

This post is a quick primer on leveraging the Cluster API Provider for Azure (CAPZ) to quickly deploy an AKS cluster.

To quote from the <a href="https://s.clarkezone.dev/capza" target="_blank">introdutory post for this feature</a>, 

> Managing Kubernetes clusters is hard.
> 
> Managing Kubernetes clusters at scale across a variety of infrastructures is—well—even harder.
> 
> The Kubernetes community project Cluster API (CAPI) enables users to manage fleets of clusters across multiple infrastructure providers. The Cluster API Provider for Azure (CAPZ) is the solution for users who need to manage Kubernetes clusters on Azure IaaS. In the past, we have recommended AKS Engine for this common scenario.  While we will continue to provide regular, stable releases for AKS Engine, the Azure team is excited to share that CAPZ is now ready for users and will be our primary tool for enabling customers to operate self-managed Kubernetes clusters on Azure IaaS.

I wasn't personally familar with the Cluster API until I participated in a hackathon with a couple of folks from the AKS team last year.

Prerequisizes
- docker
- make
- Azure ClI
- Tilt: https://docs.tilt.dev/install.html
- kind

### Clone the CAPZ repo
1. `git clone https://github.com/kubernetes-sigs/cluster-api-provider-azure.git`

### Get tiltsettings.json going:
1. Create placeholder file named `tilt-settings.json` in the root of the repository as follows:

```json
{
  "kustomize_substitutions": {
    "AZURE_SUBSCRIPTION_ID": "00000000-0000-0000-0000-000000000000",
    "AZURE_TENANT_ID": "00000000-0000-0000-0000-000000000000",
    "AZURE_CLIENT_SECRET": "AaA1A~1AaA1111AAAaaaaaAaaaaaa-A1A1aaaaAa",
    "AZURE_CLIENT_ID": "00000000-0000-0000-0000-000000000000",
    "AZURE_ENVIRONMENT": "AzurePublicCloud",
    "AZURE_SSH_PUBLIC_KEY_B64": ""
  },
  "worker-templates": {
    "flavors": {
      "default": {
        "WORKER_MACHINE_COUNT": "1",
        "KUBERNETES_VERSION": "v1.23.6",
        "AZURE_LOCATION": "westus2",
        "AZURE_NODE_MACHINE_TYPE": "Standard_D2s_v3",
        "CONTROL_PLANE_MACHINE_COUNT": "1"
      }
    },
    "metadata": {}
  }
}
```

For convenience you can grab the above with curl -LO 

### Populate subscription and service principal details
2. Login via Azure CLI:
`az login`


3. Get subscription details:
`az account show --output=table`

4. Grab account and foo:
Get first 3 details from sub

4. 
Create service principal and grab details


Get SP details

### Run tilt
The makefile has a handy dandy help command which you can get via `make help` to help get oriented.

1. Create a kind cluster
`make kind-create`

2. Generate the machine templates
`make generate-flavors`

3. Start tilt to enable GUI for creating clusters
`make tilt-up`

### Deploy vanilla AKS cluster to your supscription

### Delete vanilla AKS cluster

5. Create a new receipe

6. Deploy that

9. Tear down 
`make kind-reset`

Deploy a cluster without tilt

Delete a cluster without tilt

Next how to install CAPZ into a homeland cluster














<img style="transform: translatex(0%);left:0; padding-right:20px" src="/static/img/2022-12-31-coding-stats/nwesso.jpeg" align="left"/>
I’m writing this post on my phone backstage at Seatle Symphony on the last night of 2022. I'm here to sing in the chorus in Beethoven's 9th symphony for the New Year concert.  So first off, let me wish you a very **Happy New Year** and thanks for staying subscribed despite the lack of content!  One of my New Year resolutions for 2022 was to start blogging again which clearly hasn't gone so well; I hope you've had better luck with your goals and resolutions for the year.

Over the course of the last 12 months I have been doing a ton of work with Kubernetes and microservices and I'm hopeful that the fruits of those labors will be manifested in blog posts over the course of 2023.  We will see how that goes; stay subscribed to find out and / or follow me on in the fediverse on hachyderm: <a href="https://hachyderm.io/@clarkezone" target="_blank">https://hachyderm.io/@clarkezone</a>
<br clear="left">

## Wakatime

How much coding did you do this year?  Do you know what you worked on?  Did you have any particular goals you were aiming for and did you neet them?  These were questions that I always wondered about at this time of year but never had very specific answers to until I started using <a href="https://wakatime.com" target="_blank">Wakatime</a>.  Now I have a dashboard to consult as well as an annual summary which just showed up in my inbox for 2022:

![Summary](/static/img/2022-12-31-coding-stats/wakasummary.png)

I like Wakatime because it unobtrusively integrates with most popular editors I use (including terminal mode VIM) and tracks activity on a fairly granular basis so I can get a breakdown of editors, languages projects I've been working on etc.  During 2022 I started paying for Wakatime pro for the second time as they appear to have fixed ARM compatibility finally.

## 2022 Insights

At a high level

1. I've been focussed on microservices and golang is my top language
2. The totals are a bit skewed due to large amount of YAML infra work
3. I didn't do as much .NET 7 / Rust dev as planned.
4. I started a bunch of small opensource projects but didn't contribute to anything big
5. I'm pretty much a Linux dev these days

Languages

![Language Summary](/static/img/2022-12-31-coding-stats/languages.png)

Editors

![Editor Summary](/static/img/2022-12-31-coding-stats/editors.png)

OS

![OS Summary](/static/img/2022-12-31-coding-stats/osbreakdown.png)

### Cloudnative Golang

To unpack the above a bit, my current focus at work is cloud native kubernetes so golang targeting k8s on linux is what my team at work is using and hence what I want my forus to be on.  For the projects I've been building, I could have picked golang or dotnet and my choice was deliberate as a forcing function to brush up on Go.  I've been taking the opportunity to do more than kick the tires by going deeper and building some production services end-to-end, including getting familiar with common patterns and libraries.  Overall, I like the relative simplicity of the language, excellent tooling and overall consistency.  I've read a number of books previously, this year's title (which I can highly recommned by the way) was: 

<a href="https://www.goodreads.com/en/book/show/55767844-cloud-native-go" target="_blank">
![Cloud Natiev Go](/static/img/2022-12-31-coding-stats/cloudnativegopng.png)
</a>

One last tidbit on golang if you are a dotnet developer.  There was a pretty good episode on <a href="https://unhandledexceptionpodcast.com/posts/0045-go/" target="_blank">Go for dotnet devs on the Unhandled Exception podcast</a> on this topic with <a href="https://twitter.com/_josephwoodward" target="_blank">Joseph Woodward</a>.  A lot of Joseph's experiences mirror my own and hence if you have any interest I highly recommend giving this a listen.

### All the infra

On the infra side, I've been doing a ton of learning in the cloud native domain, building out several k3s clusters on bare metal, diving in to k8s storage, cluster observability, continuous profiling etc.  The stats bare witness to this with YAML being the "Language" I've spent the second largest amount of time in (as well as Makefile, Docker).

My learning here is that, in general, there is still a massive opportunity for better tooling in cloud native, particularly for working with YAML manifests in the kubernetes domain from validation, to refactoring and general power tooling.  Right now, despite VSCode extensions, it is painful and takes way too much time.  I hope I don't spend 141 hours munging YAMl in 2023!

To learn more and start to try and help myself elimiate a repetitive task I found myself doing again and again (converting a manifest set to using <a href="https://kustomize.io" target="_blank">`kustomize`</a>), I did some early work on a <a href="https://github.com/clarkezone/rk" target="_blank">refactoring tool</a> to create `kustomize` flavored k8s manifests layered for staging, production etc from vanilla manifests but didn't get that project to critical mass yet.

BTW, if you know of any helpful tooling here, would love to hear about it (in the comments or on twitter / fedi)!

### Misses for 2022

In terms of missed opportunities, I'm excited for .NET7 and was hoping to do more with it this year.  Same goes for Rust.  Just couldn't put enough focus with either.  Hoping that will change in 2023.  On the .NET side, I'm particularly interested in diving in more deeply to the related cloud native areas including the new [Rate Limiting stack](https://devblogs.microsoft.com/dotnet/announcing-rate-limiting-for-dotnet/) and <a href="https://microsoft.github.io/reverse-proxy/" target="_blank">YARP</a> inspired by <a href="https://devblogs.microsoft.com/dotnet/bringing-kestrel-and-yarp-to-azure-app-services/)" target="_blank">Azure App Service usage of YARP as an application gateway</a>.  On the Rust side I started the <a href="https://buildspace.so/solana-core" target="_blank">Solana Core</a> program on Buildspace but didn't progress far enough in to do anything with Rust yet.

### OSS

In previous years I've done pretty substantial contributions to opensource, <a href="https://github.com/flutter/engine/pulls?q=is%3Apr+author%3Aclarkezone+" target="_blank">most notably Flutter</a>.  This year was a year where my contributions to any big project with virtually zero.  Hoping that will change at some point as I learned a ton contributing to a sizable project / codebase.  This will likely by in kubernetes or something in the native related ecosystem.

### Tooling and sharpening the saw

From a dev tooling perspective, as the stats show I more or less exlusively use a Linux VM on my home devbox, accessed via <a href="https://tailscale.com" target="_blank">Tailscale</a> using either a ssh session, <a href="https://code.visualstudio.com/docs/remote/ssh" target="_blank">VS Code remote ssh extension</a> or <a href="https://github.com/coder/code-server" target="_blank">code-server</a>.  This year I have started building out an <a href="https://github.com/clarkezone/infra" target="_blank">infra repository</a> to be able to easily recreate the linux environment and also just started working through <a href="https://vim-adventures.com" target="_blank">Vim Adventures</a>.

## Wrapup

Curious to know what you have been focussing on in the last year, dear reader?  Are you happy with your progress?  What are your goals for 2023?
