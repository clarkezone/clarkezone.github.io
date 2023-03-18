---
layout: post
commentshortlink: "http://ps-s.clarkezone.dev/p3"
title:  "Fancy style test reloaded"
date: 2018-11-16 09:06:02 -0800
categories: [blogging]
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
* `--no-parent` // Dont download something from the parent directory
