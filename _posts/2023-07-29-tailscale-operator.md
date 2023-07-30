---
layout: post
title: The one about the Tailscale Kubernetes Operator onion peel
date: 2023-07-29 10:34:00 -0800
categories: [Tailscale]
tags: [Tailscale, Kubernetes, OpenSourceContribution]
---
## Audience
SRE, Dev ops, Platform engineering

<img style="width:370;height:270px" src="/static/img/2023-07-25-howtodocker/neondockercontainer.png" align="right">
## Introduction
The purpose of this post is to assist you in starting your Docker learning journey by sharing resources, tips, and methods that I have acquired over the years. It is based on my personal experiences from the last 8 years or so spent in and around the Docker ecosystem, as well as from experiences helping my colleagues at work who are starting from scratch. If you are new to the Docker ecosystem, it can be quite overwhelming to begin because there is so much information available. The lessons here are some of the things I wish I had known when I first started.

> If you have experience with Docker and happen to be reading this, please consider sharing this beginner's guide with friends or colleagues who could benefit from it. Additionally, I would appreciate hearing from you on <a href="https://q6o.to/czt" target="_blank">`Twitter`</a> or <a href="https://q6o.to/czm" target="_blank">`Mastodon`</a> if you have any favorite resources or tips that you think are missing.

## Optimize for How you prefer to learn
    
When it comes to learning, it's important to find an approach that works best for you. This is where the concept of bias learning comes in. Bias learning means that you tailor your learning approach to your personal preferences and goals. For instance, some people may find that they learn best by reading, while others learn better through visual aids or hands-on experiences.

## Getting started:
1. For mature projects like Docker or Kubernetes, I usually recommend starting with the <a href="https://q6o.to/dodocs" target="_blank">official documentation</a> to get oriented on what the tool in question does and learn the basics of how to install it into your environment.  You don’t need to read the entirity but consider starting with the overview and getting started sections as a first order of business.
2. The YouTube recording of the <a href="https://q6o.to/doinws" target="_blank">intro workshop by Shy Ruparel from Docker Con 2022</a> is both approachable and a good overview of how to get started with a total runtime of 2 hours 40 minutes.
3. If you have a LinkedIn learning subscription and prefer a more structured approach, the Beginning Docker course is worth a look: <a href="https://q6o.to/dolilgs" target="_blank">Beginning Docker</a>.  If you have a Pluralsight subscrtion, <a href="https://q6o.to/pludogs" target="_blank">getting started with docker</a> is a equaly good.
4. Bret Fisher has a bunch of great Docker content on his YouTube channel.  You can find his channel here: <a href="https://q6o.to/ytbrfi" target="_blank">https://www.youtube.com/@BretFisher/videos</a> I highly recommend looking through the many videos and picking out what is interesting.
5. Some amount of hands-on experience with Docker is essential.  Whilst getting your own environment setup is highly recommended, a quicker way is to use a pre-built cloud hosted environment.  In the old days, the go-to used to be Katacoda but that site sadly went the way of the dodo.  A promising replacement that you may find helpful is play-with-docker.com: <a href="https://q6o.to/doplwi" target="_blank">training.play-with-docker.com</a>.

> Basic tip for searching for topics on YouTube.  Pay attention to the number of views on search results.
> 
> If you have a favorite docker into video, would love to hear about it!  HMU on <a href="https://q6o.to/czt" target="_blank">`Twitter`</a> or <a href="https://q6o.to/czm" target="_blank">`Mastodon`</a> if you have any questions or comments.



## Tooling esentials
1. <a href="https://q6o.to/dodeski" target="_blank">Docker desktop</a> is a great place to start as, if you are new to the space the GUI can make it easier to discover and learn concepts.  Plus docker desktop is available on all popular platforms.  One thing to watch out for is the license which was <a href="https://q6o.to/doli" target="_blank">revised in August 2021 such that it is no longer free to use in all cases</a>.  Worth being aware of this and checking out some of the free alternatives.
2. Starting with the GUI is great, but I would recommend spending some time in the terminal of your choice gaining familiarity with the <a href="https://q6o.to/docli" target="_blank">docker CLI</a>.  If you are on Linux I always recommend talking a look at <a href="https://q6o.to/podma" target="_blank">Podman</a> as a docker alternative as it’s completely free for all types of usage including commercial and it’s command compatible with the docker CLI.  There is also a <a href="https://q6o.to/podmagui" target="_blank">fledgling GUI project for Podman</a> which, whilst not as mature as docker desktop, has the basics and is completely free.
3. If you are using Windows, it’s well worth installing <a href="https://q6o.to/wsla" target="_blank">Windows Subsystem for Linux version 2 (WSL2)</a> with your Linux distro of choice and enabling docker support said distro as described here <a href="https://q6o.to/wsldo" target="_blank">https://docs.docker.com/desktop/windows/wsl/</a>.  The benefit of this approach over legacy mode desktop is that the Docker utility Linux VM shares the same resources with the WSL Linux environment which enables scenarios such as sharing resources such as volumes with great mount performance.  Another reason to do this is support for <a href="https://q6o.to/wslrc" target="_blank">remote container scenarios as described here</a>.

> CLI tip: When using docker in the terminal, make sure you learn how to use command autocompletion.  This makes learning the CLI easier and removes repetitive typing.  I watch so many beginners struggling to type and remember commands unnecessarily.  Get into the habit of using command completion.  Type docker,  a few characters of the command, hitting tab whenever you get stuck.  This works not only for remembering docker sub-commands but also command arguments, for example if you type docker rm <tab> or docker image rm <tab>.  Command completion is enabled by default in docker, for podman look at the help for ‘podman completion’

## Going Deeper
1. If you are going to be using Docker in your job day to day it’s well worth going deeper by investing some time in structured learning program, for example if you are going to be managing Docker in production:  <a href="https://q6o.to/pludopr" target="_blank">Pluralsight Managing docker in production</a>
2. If you are curious about docker internals or are also interested in progressing from docker to kubernetes, worth drilling in to better understand container fundamentals and some of the underlying Linux constructs such as `cgroups`, `namespaces` and `junctionpoints`.  For this I recommend taking the excellent <a href="https://q6o.to/lfs253" target="_blank">Container Fundamentals course</a> (this is a paid course).
3. To get a more hands on view of what it takes to leverage Linux primitives to get something like a container working check out <a href="https://q6o.to/ghliricfs" target="_blank">Liz Rice's containers from scratch repo</a>.
4. Another great source of internals infor can be found in <a href="https://q6o.to/ghkhol" target="_blank">Kal Hendiaks's on linux repo</a>.

## Self Assesment

If you were joining my team and I was assessing your knowledge of docker, these are some of the things I'd be asking you to explain to me:

### Concepts

- DockerFile
- Container Image
- Container Registry
- Container Instance
- Image Tags
- Volumes and volume mounts
- OCI image format
- Image Digests
- Image Layers
- Interactive vs TODO background
- Linux namespaces
- Linux CGroups
- Linux Junction points
- Windows Containers
- Distroless Linux container images
- Rootless Linux container images
- CPU architecture and OS: Linux/Windows, ARM64v8, AMD64
- Networking IP address, listening rules (127.0.0.1 vs 0.0.0.0), ports
- Environment variables
- Access control

### Techniques / scenarios

Basic
1. Pull an nginx docker image from a public container registry using docker or podman
2. Run a local nginx container from nginx image using docker or podman
3. Build a local image from a Dockerfile using docker or podman (refernece <a href="https://q6o.to/ghczshttp" target="_blank">https://github.com/clarkezone/cloudnativeplayground/tree/main/testapps/golang/simplehttpserver</a>)
4. List local images
5. Delete a local image
6. Tag a local image
7. Push a local image to a public registry (docker or ghcr)
4. Run a container and mount a volume
3. Run a container setting environment variables
9. Run a static website using nginx connecting a volume with static content and exposing ports (See <a href="https://q6o.to/donginxim" target="_blank">*Running a basic web server*</a>.
10. Run a conatiner in interactive mode with terminal attached
11. List running and stopped containers
12. Manually clean up stopped containers
13. Run a container enabling automatic clean up on exit

Intermediate
8. List tags for an image in public registry (docker or ghcr)
1. Create a private registry e.g. Azure Container Registry
2. Push an image to a private registry
5. list digests
4. Run a multi-container image using Docker Compose
5. Detatch from running container / attach to detached running container
6. Enable command completion for the docker command
7. use `${pwd}` to map current working directory as volume for testing
8. Building a container image as part of a CI/CD pipeline

Advanced
1. Use `docker exec` into a running container
2. Override entrypoint for container image
3. Reclaim disk space from unused images
4. Perform local multi-image builds

## Reference

There are many great tool lists that I use for discovering and keeping track of what's hot in the world of Docker.  These two are well worth bookmarking if you are interested in keeping up: <a href="https://q6o.to/ghclbdt" target="_blank">https://collabnix.github.io/dockertools/</a> and <a href="https://q6o.to/ghvmad" target="_blank">https://github.com/veggiemonk/awesome-docker</a>.

## Wrap-up

Thanks for reading this far!  I hope you've been able to learn something new.  Would love to know how you get on your journey into the fun world of Docker and Containers.  Stay in touch here <a href="https://q6o.to/czt" target="_blank">`Twitter`</a> or <a href="https://q6o.to/czm" target="_blank">`Mastodon`</a>
