---
layout: post
title:  "Hello world Lets encrypt via nGrok in Go"
date: 2020-01-29 09:51:02 -0800
categories: [golang]
tags: [ngrok, letsencrypt]
---

I've been playing with gRPC and microservice recently (more on that later). One aspect that I've needed to figure out as part of that particular adventure has been getting gRPC endpoint running securely over SSL.  To do that, I turned to [Let's Encrypt](https://letsencrypt.org) as I'm a massive fan of free certs that can be automatically acquired and renewed.  Since I'm working in GoLang, there are a number of great solutions that work off the shelf (the one I'm using is Acme).  Before figuring out how to get letsencrypt working with gRPC, I wanted to establish a way of testing everything locally.  My favored solution to this problem is nGrok from Allan Shreve.

What does hello world look like for a let's encrypt endpoint in go?

{% gist 0000a9057bd973000057e31f1085ccfc main.go %}

Figuring out how to do this on github pages.

```cs
class test {
    string hello;
}
```