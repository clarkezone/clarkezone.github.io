---
layout: post
title: The one about the Tailscale Kubernetes Operator onion peel
date: 2023-07-29 10:34:00 -0800
categories: [Tailscale]
tags: [Tailscale, Kubernetes, OpenSourceContribution]
---
## Audience
SRE, Dev ops, Platform engineering

<img style="width:370;height:270px" src="/static/img/2023-07-25-howtodocker/neondockercontainer.png" align="right">
## Introduction
I've been a big Tailscale fan for a number of years now and consider Tailscale to be an essential part of my personal infrastructure toolset.  One of the fundamental use cases that I depend on is the ability to use Tailscale for accessing private web applications that I host on a number of kubernetes clusters self-hosted at home.  The approach I've been using up to now is one I learned from David Bond <a href="https://q6o.to/bpdbk3sts" target="_blank">in this post</a>.  In a this approach, each cluster node is individually joined to your tailnet and the cluster itself uses the tailnet for intra-node communication. 

> If you are a tailscale user <a href="https://q6o.to/czt" target="_blank">`Twitter`</a> or <a href="https://q6o.to/czm" target="_blank">`Mastodon`</a>.

## Tailscale Operator
    
 I first learned about the existance of the Tailscale operator over lunch with Brada and Mai in Redmond in July 2022.  I was dimmly aware of it <a href="https://q6o.to/bptsk8sop" target="_blank">going into preview albeit in an unstable state</a> but still hadn't had a chance to try it out.  It was only over the last few days (writing this on Sunday July 30th 2023) that I got around to this.

 The attraction of the tailscale operator for me is that it can expose any Kubernetes service in your cluster on your tailnet without the bother of needing to set up an ingress solution.  In my case it replaces the complexity of building out clusters with tailscale on every node, and gives simple DNS setup via magic DNS. 
 
 There is an aditional feature that enables tailscale to perform theduties of an authenticating proxy for the k8s control plane which 

## Kicking the tyres
I started off by following the seemingly simple instructions outline in the post linked above.  I installed the operator and then created a simple nginx deployment and service to test it out:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: tailscaletest

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-tailscale
  namespace: tailscaletest
  labels:
    app: nginx-tailscale
spec:
  selector:
    matchLabels:
      app: nginx-tailscale
  replicas: 2 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx-tailscale
    spec:
      containers:
      - name: nginx-tailscale
        image: nginx:1.20-alpine
        ports:
        - containerPort: 80

---

apiVersion: v1
kind: Service
metadata:
  name: nginx-tailscale
  namespace: tailscaletest
spec:
  type: LoadBalancer
  loadBalancerClass: tailscale
  ports:
  - port: 80
  selector:
    app: nginx-tailscale
```
## Digging in
Learnings
From code
1. The operator's job is to create a proxy statefulset for service annotated
2. The proxy statefulset if none

From issues

## Wrap-up

Thanks for reading this far!  I hope you've been able to learn something new.  Would love to know how you get on your journey into the fun world of Docker and Containers.  Stay in touch here <a href="https://q6o.to/czt" target="_blank">`Twitter`</a> or <a href="https://q6o.to/czm" target="_blank">`Mastodon`</a>
