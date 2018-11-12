---
layout: page
title: Front Page
tagline: Clarkezone's dev place
description: Still building out this site.. under construction
---

# Hello World

*some markdown*

  {% for post in site.posts %}

      [{{ post.title }}]({{ post.url }})

  {% endfor %}
