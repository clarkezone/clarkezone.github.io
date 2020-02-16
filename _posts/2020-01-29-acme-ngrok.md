---
layout: post
title:  "Hello world Lets encrypt via nGrok in Go"
date: 2020-01-29 09:51:02 -0800
categories: [golang]
tags: [ngrok, letsencrypt]
---

I've been playing with gRPC and microservice recently (more on that later). One aspect that I've needed to figure out as part of that particular adventure has been getting gRPC endpoint running securely over SSL.  To do that, I turned to [Let's Encrypt](https://letsencrypt.org) as I'm a massive fan of free certs that can be automatically acquired and renewed.  Since I'm working in GoLang, there are a number of great solutions that work off the shelf (the one I'm using is Acme).  Before figuring out how to get letsencrypt working with gRPC, what does a hello world server in Golang look like?

{% gist 0000a9057bd973000057e31f1085ccfc main.go %}

Pretty easy right?  But there's one slight problem.. how do we test this locally?  In order for Let's Encrypt to work, you need a domain name, an ip address isn't enough.  That's simply how SSL works.  And with a domain name in play, we need a way to have traffic routed to my machine for https requests for that domain.  And for the magic needed for Acme to get a certificate to enable SSL traffic, we also need a secondary tunnel for the let's encrypt certificate acquisition machinery.

My favored solution to this problem is [nGrok](https://ngrok.com) from Allan Shreve.  Can't say enough good things about nGrok, have been a pro subscriber for a number of years at this point and have been super happy with the product and service.  nGrok allows you to 
