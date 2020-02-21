---
layout: post
title:  "Previewing Jekyll blog posts"
date: 2020-02-15 17:06:57 -0800
categories: [blogging]
tags: [jekyll,golang]
---

This github pages blog is powered by [Jekyll](https://jekyllrb.com), a static site generator.  Because I've been using the iPad for content creation and because the posts are written in raw markdown, I've found it quite hard to get previews of posts as I'm writing showing what they will finally look like when rendered in the context of github pages.  Why do I need a preview you may ask?  Well, things like having the Jekyll template applied, seeing the layout, embeds etc often need iteration and tweaking.  And, in order for preview to be useful, I have the following requirements:

1. Preview before the post is "live" with final formatting and styling applied
2. Preview any branch.  I use git branches to author new posts and I'm often writing a number of posts at once
3. Preview can run in the cloud so I can view it from any device including the iPad

To meet the above requirements I needed ideally a docker image for simplicity of deployment capable of running the Jekyll and updating the static content as I push updates into git from my markdown editor.