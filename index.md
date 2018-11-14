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
      {{ post.date }}
      <a href="{{ post.url }}">{{ post.title }}</a>
      {{ post.excerpt }}
    </li>
  {% endfor %}
</ul>
