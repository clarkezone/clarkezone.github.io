---
layout: post
title:  "Previewing Jekyll blog posts"
date: 2020-02-15 17:06:57 -0800
categories: [blogging]
tags: [jekyll,golang]
---

My git blog is powered by Jekyll, a static site generator.  Because I've been using the iPad for content creation and because the posts are written in raw markdown, I've found it quite hard to get previews of blog posts showing what they will finally look like.  Why do I need a preview you may ask?  Well, things like having the Jekyll template applied, seeing the layout, embeds etc often need iteration and tweaking.  And, in order for preview to be useful, I have the following requirements:

1. Preview any branch.  I'm often writing a number of posts at once and I use different branches to keep things organized
2. Preview before the post is "live"
3. Preview can run in the cloud so I can view it from the iPad

To meet the above requirements I wanted a docker image capable of listening for updates to a branch on git via a webhook and a component for previewing using the template etc.  For the second part, there is a pre-existing docker image Jekyll/Jekyll.  For the first part a little work is required.  Luckily, there is a great 