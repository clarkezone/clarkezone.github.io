---
layout: post
title: The one about the Tailscale Kubernetes Operator onion peel
date: 2023-07-29 10:34:00 -0800
categories: [Tailscale]
tags: [Tailscale, Kubernetes, OpenSourceContribution]
---
## Audience
SRE, Dev ops, Platform engineering

<img style="width:370;height:270px" src="/static/img/2023-tailscaleoperator/tailscaleoperator.png" align="right"> ## Introduction
I've been a big Tailscale fan for a number of years now and consider Tailscale to be an essential part of my personal infrastructure toolset.  One of the fundamental use cases that I depend on is the ability to use Tailscale for accessing private web applications that I host on a number of kubernetes clusters self-hosted at home.  The approach I've been using up to now is one I learned from David Bond <a href="https://q6o.to/bpdbk3sts" target="_blank">in this post</a>.  In a this approach, each cluster node is individually joined to your tailnet and the cluster itself uses the tailnet for intra-node communication.  The fiddly part of this current approach comes when layering on DNS resolution, SSL and Kubernetes ingress.  The current solutions I'm using for each of these has limitations and annoyances and are ripe for replacement with a more elegent solution. 

> If you are a tailscale user <a href="https://q6o.to/czt" target="_blank">`Twitter`</a> or <a href="https://q6o.to/czm" target="_blank">`Mastodon`</a>.

## Tailscale Operator
    
 I first learned about the existance of the Tailscale operator for Kubernetes over lunch with BradA and Mai in Redmond in July 2022.  I was subsequently aware of it <a href="https://q6o.to/bptsk8sop" target="_blank">going into preview albeit in an unstable state</a> but still hadn't had a chance to try it out.  It was only over the last few days (writing this on Sunday July 30th 2023) that I got around to finally trying the operator out in my setup.

 The attraction of the Tailscale operator for me is that it can expose any Kubernetes service in your cluster on your tailnet without the bother of needing to set up an ingress solution.  In my case it replaces the complexity of building out clusters with Tailscale on every node, and gives simple DNS setup via magic DNS.  The remaining gap which is supposedly in the roadmap is a solution for SSL.  Since all traffic is limited to the tailnet which is encrypted, I'm willing to trade off the reduction in complexity against the lack of double encryption for now.
 
 There is an aditional feature that enables Tailscale to perform the duties of an authenticating proxy for the k8s control plane which sounds interesting and I plan to try out at some point.

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

The basic premis of the Tailscale Kubernetes Operator is you install the operator in the cluster and then annotate the service with `loadBalancerClass: tailscale` and magic suposedly happens.

## Problem

Only it didn't.  Long story short, the operator didnt work out of the box for me.  My testing initially took place on a k3s test cluster running ARM64 Ububtu 22.04.  The details of my findings in the above testing is summarized in this issue:
https://github.com/tailscale/tailscale/issues/8733.  The punchline is that although the Tailscale operator installs fine was correctly detecting my test service, it wasn't able to correctly route traffic to the Kubernetes service through my tailnaet.

Since the Tailscale operator path was blocked, I decided to try some of the other Kubernetes solutions that Tailscale offers as described here: https://tailscale.com/kb/1185/kubernetes/.  Result of that testing was

1. Tailscale Sidecar for Kubernetes works
2. Tailscale Proxy for Kubernetes doesn't work

So of all options, only the sidecar works for my particular configuration.  Whilst helpful information, the sidecar approach isn't going to scale for me across all the applications I need to support so I decided to double click on the two broken cases and try and figure out what was going wrong.

## Digging in
Doing some splunking around in various issues and code, I was able to garner the following:

(from issues)
- https://github.com/tailscale/tailscale/issues/8111
- https://github.com/tailscale/tailscale/issues/8244
- https://github.com/tailscale/tailscale/issues/5621
- https://github.com/tailscale/tailscale/issues/391
- https://unix.stackexchange.com/questions/588998/check-whether-iptables-or-nftables-are-in-use/589006#589006

1. A common hypthysis for why the Tailscale proxy doesn't work in some instances is lack of support for NFTABLEs in the current Tailscale implementation.  This will be problematic for hosts running the newer nftables implementation.
2. iptables provides firewall and route configuration functionality. Due to limitations (performance and stability) a more modern alternative called nftables was developerd.  More details here: https://linuxhandbook.com/iptables-vs-nftables/
3. Ubuntu 20.04 uses the legacy iptables implementation where-as 22.04 moved to nftables.
4. Since only one implementaiton is installed / active on a host at one time, it is necessary to detect which is running and use appropriate API's.
5. This is not a new thing.  The KubeProxy had to accomodate this situation back in 2018 as mentioned in this issue https://github.com/kubernetes/kubernetes/issues/71305
6. On the Tailscale side, an NFTABLE patch recently landed adding support for NFTABLES albiet experimental and behind a tailscaled flag.
https://github.com/tailscale/tailscale/pull/8555
7. Full support for ntrables in tailscaled including autodetetcion is sitll in progress, not on by default and not available for Kubetnetes scenarios.

(from code inspection in the Tailscale repo)

1. The Tailscale Kubernetes operator code entrypoint lives in `operator.go`
2. The operator's job is to create a Kubernetes statefulset for every service annotated with `type: LoadBalancer`, `loadBalancerClass: tailscale`
3. The proxy statefulset is instantiated from the docker image `tailscale/tailscale` which turns out to be the self-same container image as used by the Tailscale Kubernetes proxy example
4. The `tailscale/tailscale` docker image is esentially a wrapper around backed by `tailscaled` is configured and run in all container scenarios
5. The code entrypoint for the `tailscale/tailscale` docker image is `containerboot.go` 

Interesting stuff.  Based on the above, first step was to set about verifying that Ubuntu 22.04 does indeed run on nftables. I duly ssh'd into one of my cluster nodes, ran iptables -v and:

Ubuntu 20.04
```bash
james@rapi-c1-n1:~$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 20.04.5 LTS
Release:        20.04
Codename:       focal
james@rapi-c1-n1:~$ iptables -V
iptables v1.8.4 (legacy)
```

Ubuntu 22.04
```bash
james@rapi-c4-n1:~$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 22.04.2 LTS
Release:        22.04
Codename:       jammy
james@rapi-c4-n1:~$ iptables -V
iptables v1.8.7 (nf_tables)
james@rapi-c4-n1:~$ 
```

The conclusion from thr above research is my issue is the lack of nftables support in tailscaled is biting me due to the fact I'm running on Ubuntu 22.04 which defaults to nftables.

## Testing the hypothetical fix
Since it looked like my issues is lack of `nftables` support out-of-the-box Tailscale and, as luck would have it, experimental support is suposedly there I set about testing this out to see if it could unblock me.  The approach was:

1. forcing on the `TS_DEBUG_USE_NETLINK_NFTABLES` flag in `wengine/router/router_linux.go`
2. build a private copy of the tailscale/tailscale image
3. verify this with Tailscale proxy
4. if yes, test with Tailscale operator

The result of this test was the following branch: https://github.com/clarkezone/tailscale/commits/nftoperatortestfix the testing of which proved very fruitful.

## The fix
With a fix in hand, it was time to see if we could build a patch to unblock others hitting this issue by exposing a toggle that would be settable in the Kubernetes manifest

here is the PR

## Wrap-up

Thanks for reading this far!  I hope you've been able to learn something new.  Would love to know how you get on your journey into the fun world of Docker and Containers.  Stay in touch here <a href="https://q6o.to/czt" target="_blank">`Twitter`</a> or <a href="https://q6o.to/czm" target="_blank">`Mastodon`</a>
