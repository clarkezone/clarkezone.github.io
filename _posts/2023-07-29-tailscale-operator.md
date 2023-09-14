---
layout: post
title: The one about the Tailscale Kubernetes Operator onion peel
date: 2023-07-29 10:34:00 -0800
categories: [Tailscale]
tags: [Tailscale, Kubernetes, OpenSourceContribution]
---
## Audience
Kubernetes Homelab users, Tailscale users

## Introduction
In this post I tell the story of an attempt to replace my [existing workable but cumbersome Tailscale Kubernetes traffic routing solution](TODO) for my home-lab with the simplicity and elegance of the [Tailscale Operetor for Kubernetes](TODO) using  both the existing incarnation which supports Kubernetes Services (OSI L3) as well as the [awesome new L7 ingresss capability that was recently merged](https://github.com/tailscale/tailscale/pull/9048).  Along the way I share learnings about a compatibility gotcha with work-around impacting more recent Ubuntu distros and a mini tutorial on deploying a private version of the Tailscale operator for Kubernetes from source.

## Tailscale x Kubernetes
<img style="width:370;height:270px" src="/static/img/2023-tailscaleoperator/tailscaleoperator.png" align="right">If you use any number of devices in your digital life bit don’t use [Tailscale](TODO) yet I imhighly recommend looking into it.  If you also happen to use a homelab and self-host web services the case is even stronger (if not and your interested check out [this great resource](TODO))

Homelabs offer a great hands-on way of learning Linux and Kubernetes but they are also a means to regaining control over your digital estate.  I started making the move a few years ago and haven’t looked back since.  I self host Bitwarden, Home Assistant, Gitea, an instance of docker hub and more using a number of home made clusters running in [k3s](TODO), a simplified k8s distribution.  The services I host are largely private in that they don’t need to be internet visible but they do need to be reachable from all devices.  This is where Tailscale comes in.  Putting these services on the tail net that connects all devices already makes them available securely everywhere without the need or risks inherent of exposing these on the external internet.

> If you are selfhosting services in another manner such as using Docker on a Synology home NAS, Tailscale is still worth checkout out as these scenarios are [natively supported](TODO).

The approach I've been using to expose services form Kubernetes cluster up to now is one I learned from [David Bond](TODO) in <a href="https://q6o.to/bpdbk3sts" target="_blank">in this post</a>.  In David's approach (simplified here for brevity), each cluster node is individually joined to your tailnet and the cluster itself uses the tailnet for intra-node communication.  This has some advantages (a home cluster can access tailnet resources such as docker repos hosted on another home cluster) but comes with a complex setup process and more devices on the tailnet to manage keys for.


> If you are a tailscale user <a href="https://q6o.to/czt" target="_blank">`Twitter`</a> or <a href="https://q6o.to/czm" target="_blank">`Mastodon`</a>.

## Tailscale Operator
    
 I first learned about the existance of the Tailscale operator for Kubernetes over lunch with several members of the Tailscale dev team in Redmond in July 2022 when it was a twinkle in [Maism's]() eye.  The feature subsequently<a href="https://q6o.to/bptsk8sop" target="_blank">went into preview albeit in an unstable state</a> but still I hadn't had a chance to try it out.  It was only over the last few days (writing this on Sunday July 30th 2023) that I got around to finally trying the operator out in my setup.

 The attraction of the Tailscale operator for me is that it can expose any Kubernetes service in your cluster on your tailnet without the bother of needing to set up an ingress solution.  In my case it replaces the complexity of building out clusters with Tailscale on every node, and gives simple DNS setup via magic DNS.  The remaining gap which is supposedly in the roadmap is a solution for ingress with SSL.  Since all traffic is limited to the tailnet which is encrypted, I'm willing to trade off the reduction in complexity against the lack of double encryption for now.

 > After writing the above, [Maisam submitted a patch to add ingress support](https://github.com/tailscale/tailscale/pull/9048) which fully addresses the above gap.  I cover that later in the post.
 

## Kicking the tyres
I started off by following the seemingly simple instructions outlined in the [Kubernetes Operator kb entry](https://q6o.to/bptsk8sop).  I installed the operator and then created a simple nginx deployment and service to test it out:

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

The basic premise is that, having installed the operator into the cluster, a Kubernetes service object annotated with `loadBalancerClass: tailscale` will be detected by the operator and automatically exposed on your tailnet.  Only in my case, it didn't.

## Problem

Long story short, the operator didn't work for me out of the box with my setup.  Testing initially took place on a k3s test cluster running ARM64 Ubuntu 22.04 and I documented my findings in this issue:
[https://github.com/tailscale/tailscale/issues/8733](https://github.com/tailscale/tailscale/issues/8733).  The punchline is that although the Tailscale operator installed fine and was correctly detecting my test service, it wasn't able to correctly route traffic to the Kubernetes service through my tailnet.

Since the Tailscale operator path forward was blocked, I decided to try some of the [https://tailscale.com/kb/1185/kubernetes](other Kubernetes solutions that Tailscale offers).  Whilst not as elegant as the operator, both the Proxy and Sidecar approaches can achieve a similar result albeit with increasingly more manual steps.  The result of that testing was:

1. Tailscale Proxy for Kubernetes doesn't work
2. Tailscale Sidecar for Kubernetes did work

In summary, of all Tailscale Kubernetes options, only the Sidecar approach worked for my particular configuration.  Whilst providing helpful information about the state of the solution space, the Sidecar approach wasn't going to be a viable solution for my needs so I decided to double click on the two broken cases and try and figure out what was going wrong.

## Digging in
Doing some spelunking around in various issues and code, I was able to identify the following relevant issues in the tailscale repo:

- [https://github.com/tailscale/tailscale/issues/8111](https://github.com/tailscale/tailscale/issues/8111)
- [https://github.com/tailscale/tailscale/issues/8244](https://github.com/tailscale/tailscale/issues/8244)
- [https://github.com/tailscale/tailscale/issues/5621](https://github.com/tailscale/tailscale/issues/5621)
[- https://github.com/tailscale/tailscale/issues/391](https://github.com/tailscale/tailscale/issues/391)
- <a href="https://github.com/tailscale/tailscale/issues/391" target="_blank">https://github.com/tailscale/tailscale/issues/391</a>
- [https://unix.stackexchange.com/questions/588998/check-whether-iptables-or-nftables-are-in-use/589006#589006](https://unix.stackexchange.com/questions/588998/check-whether-iptables-or-nftables-are-in-use/589006#589006)

and from there derive the following learnings:

1. `iptables` provides firewall and route configuration functionality on Linux. Due to limitations (performance and stability) a more modern alternative called `nftables` was developed.  More details here: [https://linuxhandbook.com/iptables-vs-nftables/](https://linuxhandbook.com/iptables-vs-nftables/)
2. Since only one implementation is installed / active on a host at one time, it is necessary to detect which is running and use appropriate API's.
3. Older versions of Ubuntu such as 20.04 use the `iptables` implementation where-as 22.04 moved to `nftables`.
4. Lack of support for `nftables` in the current Tailscale implementation being a common problem.  This impacts tailscale compatibility when running on more recent OS which may default to using `nftables` rather than `iptables`.
5. This is not a new thing.  The KubeProxy previously had to accommodate this situation back in 2018 as mentioned in this issue [https://github.com/kubernetes/kubernetes/issues/71305](https://github.com/kubernetes/kubernetes/issues/71305)
6. On the Tailscale side, an `nftables` patch recently landed adding support for `nftables` albeit experimental and behind a tailscaled flag.
[https://github.com/tailscale/tailscale/pull/8555](https://github.com/tailscale/tailscale/pull/8555)
7. Full support for nfttables in tailscaled including auto-detetcion is still in progress, not on by default and not available for Kubetnetes scenarios.

> At the original time of writing, auto-detetcion and switching for `iptables` and `nftables` hadn't been built, it has subsequently landed behind a flag

From doing some spelunking around the source in the Tailscale repo:

1. The code entrypoint for Tailscale Kubernetes operator lives in `operator.go`
2. The operator's job is to create a Kubernetes statefulset for every service annotated with `type: LoadBalancer`, `loadBalancerClass: tailscale`
3. The statefulset is instantiated from the docker image `tailscale/tailscale` which turns out to be the self-same container image as used by the Tailscale Kubernetes Proxy approach.  From my testing Proxy was a non working case in my setup.
4. The `tailscale/tailscale` docker image is essentially a wrapper around backed by `tailscaled` is configured and run in all container scenarios
5. The code entrypoint for the `tailscale/tailscale` docker image is `containerboot.go` 

Interesting stuff.  Based on the above, first step was to set about verifying that Ubuntu 22.04 does indeed run on `nftables`. I duly ssh'd into one of my cluster nodes, ran `iptables -v` with the following results confirming that 22.04 does indeed run on `nftables`:

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
Repeating on a 20.04 node, in this case it's running on `iptables`:

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
The overall hypothesis from all of the above research is that my issue is the lack of `nftables` support in tailscaled is biting me due to the fact I'm running on Ubuntu 22.04 on my cluster nodes which defaults to nftables.

## Testing the hypothetical fix
Since it looked like my issues is lack of `nftables` support out-of-the-box Tailscale and, as luck would have it, experimental support is supposedly there behind a disabled flag, I set about testing this out to see if it could unblock me.  The approach was:

1. forcing on the `TS_DEBUG_USE_NETLINK_NFTABLES` flag in `wengine/router/router_linux.go`
2. build a private copy of the tailscale/tailscale container image
3. verify this image with Tailscale proxy since the implementation is shared with the Operator and the scenario is simpler
4. if yes, test image with Tailscale Operator

The result of working through these steps was the following private fork: [https://github.com/clarkezone/tailscale/commits/nftoperatortestfix](https://github.com/clarkezone/tailscale/commits/nftoperatortestfix) the testing of which proved very fruitful.  In summary, the nftsupport worked as expected.  Since others had cited this problem, I decided to be a good opensource citizen and submit a PR: [https://github.com/tailscale/tailscale/pull/8749](https://github.com/tailscale/tailscale/pull/8749).

As the ongoing work on [https://github.com/tailscale/tailscale/issues/5621](https://github.com/tailscale/tailscale/issues/5621) continues to land (eg [https://github.com/tailscale/tailscale/pull/8762](https://github.com/tailscale/tailscale/pull/8762)) the need for my fix will go away as the scenario will just work, but until then it's a temporary stop-gap for those blocked on adopting the Tailscale Kubernetes Operator.

If you want to follow along you can do the following:

To try it out

1. (optional) build client docker image substituting appropriate repos and tags: `PUSH=true REPOS=clarkezone/tsopfixtestclient TAGS=6 TARGET=client ./build_docker.sh`
2. (optional) build operator docker image substituting appropriate repos and tags: `PUSH=true REPOS=clarkezone/tsopfixtestoperator TAGS=3 TARGET=operator ./build_docker.sh
`
3. Grab manifest from this branch: `curl -LO https://github.com/clarkezone/tailscale/raw/nftoperatortestfix/cmd/k8s-operator/manifests/operator.yaml`
4. add your clientID and secret per the [official instructions](TODO)
5. (optional) if you built and pushed your own containers, update line 130 and 152 to point to your private images
6. Apply the operator manifest: `kubectl apply -f operator.yaml`
7. apply test manifests to publish a nginx server on tailnet: `kubectl apply -f https://gist.github.com/clarkezone/b22a5851f2e4229f5fd29f1115ddee32/raw/277efaa5e099ef055eb445115dd199dc40829df2/tailscaleoperatortest.yaml`
8. Get the endopoint address for the service on your tailnet with `kubectl get services -n tailscaletest` in the external IP column, you should see a dns entry in your tailnet similar to tailscaletest-nginx-tailscale.tail967d8.ts.net, this is the endpoint your service is exposed on.
9. You should be able to curl the endpoint and see output from nginx: `curl tailscaletest-nginx-tailscale.tail967d8.ts.net`

## Adding Ingress
The ultimate solution I've been looking for with a Tailscale Operator type of solution is something that works at the http layer and supports DNS and SSL integration to enable a better more secure user exterience for connecting to clusters.  Over the course of writing this post, my wish came try when Maism landed the [inital PR that adds ingress support to the Tailscale Operator](TODO).  This provides the final missing link I was looking for. So this post wouldn't be complete with a quick tour of that.  It's also worth noting that because Ingress support doesn't depend on the iptables or nftables layer, my original issue is also solved without any of the concerns I've articulated above. 

In order to leverage Ingress support, the earlier example is modified by removing anotation from the service and adding an ingress manifest with a modified tailscale annotation:
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
  ports:
  - port: 80
  selector:
    app: nginx-tailscale

---

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-tailscale
  namespace: tailscaletest
spec:
  ingressClassName: tailscale
  tls:
  - hosts:
    - "foo"
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-tailscale
            port:
              number: 80
```

If you apply the above to a cluster with the latest operator installed, via

`kubectl apply -f https://gist.github.com/clarkezone/f99ea7f0c08a4f0f7a2487cc73871b89`

you will see something simlar to this:

```bash
k get ingress -n tailscaletest nginx-tailscale
NAME              CLASS       HOSTS   ADDRESS                       PORTS     AGE
nginx-tailscale   tailscale   *       nginx-test.tail967d8.ts.net   80, 443   7m52s
```


## Next steps
There is an aditional feature that enables Tailscale to perform the duties of an authenticating proxy for the k8s control plane which sounds interesting and I plan to try out at some point.

For the scenario of enabling one cluster to access other tailnet resources, there is also an egress proxy solutoin that I need to look at.

## Wrap-up

Thanks for reading this far!  I hope you've been able to learn something new.  Would love to know how you get on your journey into the fun world of Containers, Kubernetes and Tailscale.  Stay in touch here <a href="https://q6o.to/czt" target="_blank">`Twitter`</a> or <a href="https://q6o.to/czm" target="_blank">`Mastodon`</a>
