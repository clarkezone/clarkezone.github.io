---
layout: page
title: Front Page
tagline: Clarkezone's dev place
description: Still building out this site.. under construction
---

# Hello World

*some markdown*

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>

  {% for post in site.posts %}

      [{{ post.title }}]({{ post.url }})

  {% endfor %}
