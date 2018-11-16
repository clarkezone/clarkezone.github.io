---
layout: post
title:  "Fancy style test"
date: 2018-11-15 17:44:02 -0800
categories: [jekyll, blogging]
tags:
---
Let's try some fancy stuff

{% highlight html %}
<input id="id_price" type="number" min=0 onkeypress="return isNumber(event)"/>
<script type="text/javascript">
function isNumber(evt) {
    evt = (evt) ? evt : window.event;
    var charCode = (evt.which) ? evt.which : evt.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57)) {
        return false;
    }
    return true;
}
</script>
{% endhighlight %}

and

* `-r`     //recursive Download
* `--no-parent` // Don´t download something from the parent directory