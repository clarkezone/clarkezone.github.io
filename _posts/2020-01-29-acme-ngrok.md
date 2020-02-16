---
layout: post
title:  "Hello world Lets encrypt via nGrok in Go"
date: 2020-01-29 09:51:02 -0800
categories: [golang]
tags: [ngrok, letsencrypt]
---

I've been playing with gRPC and microservice recently (more on that later). One aspect that I've needed to figure out as part of that particular adventure has been getting gRPC endpoint running securely over SSL.  To do that, I turned to [Let's Encrypt](https://letsencrypt.org) as I'm a massive fan of free certs that can be automatically acquired and renewed.  Since I'm working in GoLang, there are a number of great solutions that work off the shelf (the package I'm using is [http://golang.org/x/crypto/acme/autocert](http://golang.org/x/crypto/acme/autocert)).  Before figuring out how to get autocert working with gRPC, what does a hello world server look like?

{% gist 0000a9057bd973000057e31f1085ccfc main.go %}

Pretty easy right?  But there's one slight problem.. how do we test this locally on our dev box?  In order for autocert to work and get me a certificate for my site from the Let's Encrypt service, you need a domain name, an ip address isn't enough.  That's simply how SSL works.  And with a domain name in play, we need a way to have traffic routed to our dev machine for https requests for that domain.  And for the magic needed for autocert to get a certificate to enable SSL traffic, we also need a secondary tunnel for the let's encrypt certificate acquisition machinery.

My favored solution to this problem is [nGrok](https://ngrok.com) from [Alan Shreve](https://twitter.com/inconshreveable).  Can't say enough good things about nGrok, have been a pro subscriber for a number of years at this point and have been super happy with the product and service.  nGrok allows you to simply set up a tunnel that maps a remote ip address, subdomain or full on domain name to a local ip address and port on your dev box.  Setting up a trivial tunnel would look something like:

```console
ngrok http 3000 -subdomain myapp
```

which would result in any requests to myapp.ngrok.io being routed to port 3000 on my dev box.  That is the simple case, getting ngrok configured to not only route SSL traffic but also allow certificate retreval needed by let's encrypt requires multiple concurrent tunnels.  I'm not going to go into much depth on why this is or how it works (you can read about that [here:https://letsencrypt.org/how-it-works/](https://letsencrypt.org/how-it-works/)) but I am going to present my solution as I wasn't able to find an explanation of this elsewhere.

{% gist 0000a9057bd973000057e31f1085ccfc ngrokconfig.yaml %}

The trick is you need two tunnels running simultaniously, one for autocert to handshake with let's encrypt and grab a free certificate (which critically requires our local server to be visible on the internet to respond to a remote challenge request on port 80) and one for the SSL traffic inbound over port 443.  I didn't initially appreciate the need for the first tunnel because I didn't understand the fact that our dev server needs to respond to the challenge request on port 80.  You can see this if you look carefully at the Go code above.. there are two separate ListAndServe calls, one on port 8080 for the challenge and one of 8443 for the actual server.  nGrok helpfully maps the external requests on 443 and 80 to 8443 and 8080 as part of it's tunneling magic.

```Go
    go http.ListenAndServe(":8080", certManager.HTTPHandler(nil))

    log.Fatal(server.ListenAndServeTLS("", ""))
```

So with the above ngrokconfig file, all we need is to start nGrok using that:

{% gist 0000a9057bd973000057e31f1085ccfc startngrok.sh %}

and we're off to the races.  If you want to try the above, you'll need to replace example.com with an actual domain you own in the Go code, configure that domain in the nGrok portal and update the config file with your matching values.

I was able to get all of that running inside of an Ubuntu session running in WSL2 no problem and successfully hit the server over SSL running over an LTE connection on my ARM-based Surface Pro X.