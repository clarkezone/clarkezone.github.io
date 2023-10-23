---
layout: post
title: The one about the Tailscale Kubernetes Operator onion peel
date: 2023-07-29 10:34:00 -0800
categories: [Tailscale]
tags: [Tailscale, Kubernetes, OpenSourceContribution]
mermaid: true
---
## Audience
Kubernetes Homelab users, Tailscale users

<!--<img style="width:370;height:270px" src="/static/img/2023-tailscaleoperator/matrixoperator.jpg" >-->
<div style="position:relative;overflow:hidden;width:100%;padding-top:46%">
<iframe frameBorder="0" style="position:absolute;top:0px;left:0px;width:100%;height:100%" src="http://clarkezonedevbox5-tr:4000/static/img/2023-tailscaleoperator/index.html">
</iframe>
</div>

## Introduction
In this post I tell the story of my attempt to replace an <a href="https://q6o.to/bpdbk3sts" target="_blank">existing workable but cumbersome solution for Tailscale traffic routing</a> for my Kubernetes homelab with the simplicity and elegance of the <a href="https://q6o.to/bptsk8sop" target="_blank">Tailscale Operator for Kubernetes</a>.  Along the way I share learnings about a compatibility gotcha with recent Ubuntu distros including the work-around, as well as a mini tutorial on deploying a private version of the operator from source.  I cover both the existing incarnation of the Tailscale operator which supports Kubernetes Services (OSI L3) as well as the <a href="https://q6o.to/ghptsc9048" target="_blank">awesome new L7 ingress capability that was recently merged</a>.

## Tailscale X Kubernetes
<img style="width:370;height:270px" src="/static/img/2023-tailscaleoperator/Redpill.jpg" > <br/>

I've been deep down the Kubernetes selfhosting rabbit hole for a while now with multiple home clusters running <a href="https://q6o.to/k3sa">k3s</a>.  Outside of learning Linux and Kubernetes, I have been embracing homelabs as part of a strategy to regain control over my digital footprint running home instances of a number of services including TODO links [Bitwarden](https://github.com/dani-garcia/vaultwarden), [Home Assistant](https://www.home-assistant.io), [Gitea](https://about.gitea.com) and a private instance of docker hub to name a few.  And this is where the interesting union of Kubernetes selfhosting and Tailscale comes about.

The services I host are largely private in the sense that they don’t need to be internet visible but they do need to be reachable from all devices.  Which means internet somehow.  Putting these services on the tailnet that connects all devices makes them available securely everywhere without the need or risks inherent of exposing them publically on the internet.  It's a bit like a virtual private intranet.

> If you are selfhosting services in another manner such as using Docker on a Synology home NAS, Tailscale is still worth checkout out as these scenarios are <a href="https://q6o.to/tsckb1131" target="_blank">natively supported</a>.

The technique I've been using to expose services from Kubernetes clusters to my tailnet is one learned from <a href="https://q6o.to/davidsbond" target="_blank">David Bond</a> in <a href="https://q6o.to/bpdbk3sts" target="_blank">in this post from 2020</a>.  In David's approach (simplified here for brevity), each cluster node is individually joined to a tailnet and the cluster itself uses the tailnet for intra-node communication.


```mermaid
graph TD
    subgraph Internet
        vpn[Tailscale tailnet private VPN]
    end
    subgraph House
        pc[PC]
        cluster[Kubernetes Cluster]
        nas[Synology NAS]
        service1[Service 1 Bitwarden]
        service2[Service 2 Gitea]
        cluster --> service1
        cluster --> service2
    end
    phone[Phone] --> vpn
    pc --> vpn
    nas --> vpn
    laptop[Laptop] --> vpn
```

Name resolution and ingress come via public Cloudflare DNS entries for inbound traffic secured by Let's Encrypt for SSL certificates and routed to cluster nodes via the k3s Traefik ingress controller.  This approach works but requires multiple services to be installed and configured on the cluster, each node must be on the tailnet and DNS config is manual and external to the home network.  Definitely sub-optimal.

> If you are a Tailscale user playing with homelab setups would love to hear from you  <a href="https://q6o.to/czt" target="_blank">`X Twitter`</a> or <a href="https://q6o.to/czm" target="_blank">`Mastodon`</a>.

## Tailscale Operator
The Tailscale Operator vastly simplifies this picture by enabling a single extension to be installed into the cluster which then exposes the desired services to the tailnet with simple annotations of existing Kubernetes manifests.
<img style="width:370;height:270px" src="/static/img/2023-tailscaleoperator/ineedanexitfast.jpg" >
    

The feature <a href="https://q6o.to/bptsk8sop" target="_blank">went into preview</a> earlier this year and I got further hyped about it talking to <a href="https://q6o.to/maisenali" target="_blank">Maism Ali</a> at Tailscale Up in May 2023 but it was only over the last few days (writing this on Sunday July 30th 2023) that I finally got around to trying the operator out in my setup.

The attraction of the Tailscale operator is that it makes it possible to expose any Kubernetes service running in a selfhosted cluster into a tailnet without the need to install any other cluster components or perform out-of-band config changes.

```mermaid
graph TD
    subgraph Internet
        vpn[Tailscale tailnet private VPN]
    end
    subgraph House
        pc[PC]
        cluster[Kubernetes Cluster]
        nas[Synology NAS]
        service1[Service 1 Bitwarden]
        service2[Service 2 Gitea]
        cluster --> service1
        cluster --> service2
    end
    phone[Phone] --> vpn
    pc --> vpn
    nas --> vpn
    laptop[Laptop] --> vpn
    service1 --> vpn
    service2 --> vpn

```
In my case it replaces the complexity of building out clusters with Tailscale on every node, and gives simple DNS setup via magic DNS and I don't need to install another ingress controller.  The remaining gap, which is supposedly in the roadmap, is a solution for L7 ingress with built in SSL.

 > After writing the above in late July, <a href="https://q6o.to/ghptsc9048" target="_blank">Maisam submitted a patch to add ingress support</a> which fully addresses the above gap.  I cover that [later in the post](#adding-ingress)

## Kicking the tyres
TODO simulation pix
I started off by following the seemingly simple instructions outlined in the <a href="https://q6o.to/bptsk8sop" target="_blank">Kubernetes Operator kb entry</a>.  I installed the operator and then created a simple nginx deployment and service to test it out:

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

## A glitch in The Tailnet

Long story short, at the time of writing in July 2023, the operator didn't work out of the box with my setup.

<img style="width:370;height:270px" src="/static/img/2023-tailscaleoperator/glitch.jpg" >

Testing initially took place on a k3s test cluster running ARM64 Ubuntu 22.04 and I documented my findings in this issue:
<a href="https://q6o.to/ghitsc8735" target="_blank">https://github.com/tailscale/tailscale/issues/8733</a>. 

> As of October 2023 this issue is resolved in the upstream and latest Tailscale container images.  If you are intersted in the gory details including how to install the operator into a cluster from source read on, else jump forward to [Ingress below](#adding-ingress).

The short form was that although the Tailscale operator installed fine and was correctly detecting my test service, it wasn't able to correctly route traffic to the Kubernetes service through my tailnet.

Since I now found myself blocked with the Operator solution, I decided to try some of the <a href="https://q6o.to/tsckb1185" target="_blank">other Kubernetes solutions that Tailscale offers</a>.  Whilst not as elegant as the operator, both the Proxy and Sidecar approaches can achieve a similar result albeit with increasingly more manual steps.  The result of that testing was:

1. Tailscale Proxy for Kubernetes doesn't work
2. Tailscale Sidecar for Kubernetes did work

At that point in the journey, of all Tailscale Kubernetes options, only the Sidecar approach worked for my particular configuration.  Whilst providing helpful information about the state of the solution space, the Sidecar approach wasn't going to be a viable solution for my needs so I decided to double click on the two broken cases and try and figure out what was going wrong.

### Digging in
Doing some spelunking around in various issues and code, I was able to identify the following relevant issues in the Tailscale repo:

- <a href="https://q6o.to/ghitsc8111" target="_blank">https://github.com/tailscale/tailscale/issues/8111</a>
- <a href="https://q6o.to/ghitsc8244" target="_blank">https://github.com/tailscale/tailscale/issues/8244</a>
- <a href="https://q6o.to/ghitsc5621" target="_blank">https://github.com/tailscale/tailscale/issues/5621</a>
<a href="https://q6o.to/ghitsc391" target="_blank">- https://github.com/tailscale/tailscale/issues/391</a>
- <a href="https://github.com/tailscale/tailscale/issues/391" target="_blank">https://github.com/tailscale/tailscale/issues/391</a>
- <a href="https://q6o.to/se588998" target="_blank">https://unix.stackexchange.com/questions/588998/check-whether-iptables-or-nftables-are-in-use/589006#589006</a>

and from there derive the following learnings:

1. `iptables` provides firewall and route configuration functionality on Linux. Due to limitations (performance and stability) a more modern alternative called `nftables` was developed.  More details here: <a href="https://q6o.to/ipvsnft" target="_blank">https://linuxhandbook.com/iptables-vs-nftables/</a>
2. Since only one implementation is installed / active on a host at one time, it is necessary to detect which is running and use appropriate API's.
3. Older versions of Ubuntu such as 20.04 use the `iptables` implementation where-as 22.04 moved to `nftables`.
4. Lack of support for `nftables` in the current Tailscale implementation being a common problem.  This impacts tailscale compatibility when running on more recent OS which may default to using `nftables` rather than `iptables`.
5. This is not a new thing.  The KubeProxy previously had to accommodate this situation back in 2018 as mentioned in this issue <a href="https://q6o.to/ghik8s71305" target="_blank">https://github.com/kubernetes/kubernetes/issues/71305</a>
6. On the Tailscale side, an `nftables` patch recently landed adding support for `nftables` albeit experimental and behind a tailscaled flag.
<a href="https://q6o.to/ghptsca8555" target="_blank">https://github.com/tailscale/tailscale/pull/8555</a>
7. Full support for nfttables in tailscaled including auto-detection is still in progress, not on by default and not available for Kubernetes scenarios.

> At the original time of writing, auto-detection and switching for `iptables` and `nftables` hadn't been built, it has subsequently landed behind a flag

From the [source code](https://github.com/tailscale/tailscale/blob/main/cmd/k8s-operator/operator.go)

1. The code entrypoint for Tailscale Kubernetes operator lives in `operator.go`
2. The operator's job is to create a Kubernetes statefulset for every service annotated with `type: LoadBalancer`, `loadBalancerClass: tailscale`
3. The statefulset is instantiated from the docker image `tailscale/tailscale` which turns out to be the self-same container image as used by the Tailscale Kubernetes Proxy approach.  From my testing Proxy was a non working case in my setup.
4. The `tailscale/tailscale` docker image is essentially a wrapper around backed by `tailscaled` is configured and run in all container scenarios
5. The code entrypoint for the `tailscale/tailscale` docker image is `containerboot.go` 

Insightful.  Based on this, first step was to set about verifying that Ubuntu 22.04 does indeed run on `nftables`. I duly ssh'd into one of my cluster nodes, ran `iptables -v` with the following results confirming that 22.04 does indeed run on `nftables`:

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
The overall hypothesis from all of the above research is that my issue is the lack of `nftables` support in `tailscaled` is biting me due to the fact I'm running on Ubuntu 22.04 on my cluster nodes which defaults to `nftables`.

### Testing the hypothetical fix
TODO fix image move animatuon to operator
Since it looked like my issue was lack of `nftables` support out-of-the-box Tailscale and, as luck would have it, experimental support is supposedly there behind a disabled flag, I set about testing this out to see if it could unblock me.  The approach was:

1. forcing on the `TS_DEBUG_USE_NETLINK_NFTABLES` flag in `wengine/router/router_linux.go`
2. build a private copy of the tailscale/tailscale container image
3. verify this image with Tailscale proxy since the implementation is shared with the Operator and the scenario is simpler
4. if yes, test image with Tailscale Operator

The result of working through these steps was the following private fork: <a href="https://q6o.to/ghcnftopf" target="_blank">https://github.com/clarkezone/tailscale/commits/nftoperatortestfix</a> the testing of which proved very fruitful.  In summary, the `nfttables` support worked as expected.  Since others had cited this problem, I decided to be a good opensource citizen and submit a PR: <a href="https://q6o.to/ghptsc8749" target="_blank">https://github.com/tailscale/tailscale/pull/8749</a>.

As the ongoing work on <a href="https://q6o.to/ghitsc5621" target="_blank">https://github.com/tailscale/tailscale/issues/5621</a> continues to land (eg <a href="https://q6o.to/ghptsc8762" target="_blank">https://github.com/tailscale/tailscale/pull/8762</a>) the need for my fix will go away as the scenario will just work, but until then it's a temporary stop-gap for those blocked on adopting the Tailscale Kubernetes Operator.

If you want to follow along you can do the following:

To try it out

1. (optional) build client docker image substituting appropriate repos and tags: `PUSH=true REPOS=clarkezone/tsopfixtestclient TAGS=6 TARGET=client ./build_docker.sh`
2. (optional) build operator docker image substituting appropriate repos and tags: `PUSH=true REPOS=clarkezone/tsopfixtestoperator TAGS=3 TARGET=operator ./build_docker.sh
`
3. Grab manifest from this branch: `curl -LO https://github.com/clarkezone/tailscale/raw/nftoperatortestfix/cmd/k8s-operator/manifests/operator.yaml`
4. add your clientID and secret per the <a href="https://q6o.to/bptsk8sop" target="_blank">official instructions</a>
5. (optional) if you built and pushed your own containers, update line 130 and 152 to point to your private images
6. Apply the operator manifest: `kubectl apply -f operator.yaml`
7. apply test manifests to publish a nginx server on tailnet: `kubectl apply -f https://gist.github.com/clarkezone/b22a5851f2e4229f5fd29f1115ddee32/raw/277efaa5e099ef055eb445115dd199dc40829df2/tailscaleoperatortest.yaml`
8. Get the endopoint address for the service on your tailnet with `kubectl get services -n tailscaletest` in the external IP column, you should see a dns entry in your tailnet similar to tailscaletest-nginx-tailscale.tail967d8.ts.net, this is the endpoint your service is exposed on.
9. You should be able to curl the endpoint and see output from nginx: `curl tailscaletest-nginx-tailscale.tail967d8.ts.net`

## Adding Ingress
<div id="canvasholder" style="width:100%;height:400px;">
</div>
<script> 
ch = document.getElementById("canvasholder");
el = document.createElement("canvas");
el.style.width="100%";
el.style.heigh="400px";
ch.appendChild(el);

class Matrix {
            constructor(canvasthing) {
                this.canvas = canvasthing;
                this.ctx = this.canvas.getContext('2d');
                this.init();
            }

init() {
                this.font_size = 20;
                this.columns = Math.floor(this.canvas.width / this.font_size);
                this.matrix = Array(this.columns).fill(1);
                this.PROBABILITY_SVG = 0.48;
                this.PROBABILITY_RESET = 0.275;
                this.TICKS_BEFORE_UPDATE = 7;
                this.tickCounter = 0;
                this.images = [];
                this.imagesLoaded = 0;

const svgData = {
                   'tss': 'data:image/svg+xml;base64,PHN2ZyBmaWxsPSJub25lIiBoZWlnaHQ9IjEyMCIgdmlld0JveD0iMCAwIDEyMCAxMjAiIHdpZHRoPSIxMjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGcgZmlsbD0iI2ZmZiI+PGNpcmNsZSBjeD0iNDAuNjI1IiBjeT0iNTkuNSIgcj0iNi42MjUiLz48Y2lyY2xlIGN4PSI2MC40OTk5IiBjeT0iNTkuNSIgcj0iNi42MjUiLz48Y2lyY2xlIGN4PSI0MC42MjUiIGN5PSI3OS4zNzUiIG9wYWNpdHk9Ii4yIiByPSI2LjYyNSIvPjxjaXJjbGUgY3g9IjgwLjM3NSIgY3k9Ijc5LjM3NSIgb3BhY2l0eT0iLjIiIHI9IjYuNjI1Ii8+PGNpcmNsZSBjeD0iNjAuNDk5OSIgY3k9Ijc5LjM3NSIgcj0iNi42MjUiLz48Y2lyY2xlIGN4PSI4MC4zNzUiIGN5PSI1OS41IiByPSI2LjYyNSIvPjxjaXJjbGUgY3g9IjQwLjYyNSIgY3k9IjM5LjYyNSIgb3BhY2l0eT0iLjIiIHI9IjYuNjI1Ii8+PGNpcmNsZSBjeD0iNjAuNDk5OSIgY3k9IjM5LjYyNSIgb3BhY2l0eT0iLjIiIHI9IjYuNjI1Ii8+PGNpcmNsZSBjeD0iODAuMzc1IiBjeT0iMzkuNjI1IiBvcGFjaXR5PSIuMiIgcj0iNi42MjUiLz48L2c+PC9zdmc+',
    'k8s': 'data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjwhLS0gQ3JlYXRlZCB3aXRoIElua3NjYXBlIChodHRwOi8vd3d3Lmlua3NjYXBlLm9yZy8pIC0tPgoKPHN2ZwogICB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iCiAgIHhtbG5zOmNjPSJodHRwOi8vY3JlYXRpdmVjb21tb25zLm9yZy9ucyMiCiAgIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyIKICAgeG1sbnM6c3ZnPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIKICAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIgogICB4bWxuczpzb2RpcG9kaT0iaHR0cDovL3NvZGlwb2RpLnNvdXJjZWZvcmdlLm5ldC9EVEQvc29kaXBvZGktMC5kdGQiCiAgIHhtbG5zOmlua3NjYXBlPSJodHRwOi8vd3d3Lmlua3NjYXBlLm9yZy9uYW1lc3BhY2VzL2lua3NjYXBlIgogICB3aWR0aD0iNzIyLjg0NTciCiAgIGhlaWdodD0iNzAxLjk2NjM3IgogICBpZD0ic3ZnMiIKICAgdmVyc2lvbj0iMS4xIgogICBpbmtzY2FwZTp2ZXJzaW9uPSIwLjQ4LjQgcjk5MzkiCiAgIHNvZGlwb2RpOmRvY25hbWU9ImxvZ28uc3ZnIgogICBpbmtzY2FwZTpleHBvcnQtZmlsZW5hbWU9Ii9ob21lL3Rob2NraW4vc3JjL2t1YmVybmV0ZXMvbmV3LnBuZyIKICAgaW5rc2NhcGU6ZXhwb3J0LXhkcGk9IjQ2MC45NTAwMSIKICAgaW5rc2NhcGU6ZXhwb3J0LXlkcGk9IjQ2MC45NTAwMSI+CiAgPGRlZnMKICAgICBpZD0iZGVmczQiIC8+CiAgPHNvZGlwb2RpOm5hbWVkdmlldwogICAgIGlkPSJiYXNlIgogICAgIHBhZ2Vjb2xvcj0iI2ZmZmZmZiIKICAgICBib3JkZXJjb2xvcj0iIzY2NjY2NiIKICAgICBib3JkZXJvcGFjaXR5PSIxLjAiCiAgICAgaW5rc2NhcGU6cGFnZW9wYWNpdHk9IjAuMCIKICAgICBpbmtzY2FwZTpwYWdlc2hhZG93PSIyIgogICAgIGlua3NjYXBlOnpvb209IjE2LjE5MDUwOSIKICAgICBpbmtzY2FwZTpjeD0iMjc3LjU2ODUxIgogICAgIGlua3NjYXBlOmN5PSIxNTcuNTQ0OTQiCiAgICAgaW5rc2NhcGU6ZG9jdW1lbnQtdW5pdHM9InB4IgogICAgIGlua3NjYXBlOmN1cnJlbnQtbGF5ZXI9ImczMDUyIgogICAgIHNob3dncmlkPSJmYWxzZSIKICAgICBpbmtzY2FwZTp3aW5kb3ctd2lkdGg9IjE1MTkiCiAgICAgaW5rc2NhcGU6d2luZG93LWhlaWdodD0iODIyIgogICAgIGlua3NjYXBlOndpbmRvdy14PSI1MSIKICAgICBpbmtzY2FwZTp3aW5kb3cteT0iMjUiCiAgICAgaW5rc2NhcGU6d2luZG93LW1heGltaXplZD0iMCIKICAgICBpbmtzY2FwZTpzbmFwLWdsb2JhbD0iZmFsc2UiCiAgICAgZml0LW1hcmdpbi10b3A9IjEwIgogICAgIGZpdC1tYXJnaW4tbGVmdD0iMTAiCiAgICAgZml0LW1hcmdpbi1yaWdodD0iMTAiCiAgICAgZml0LW1hcmdpbi1ib3R0b209IjEwIiAvPgogIDxtZXRhZGF0YQogICAgIGlkPSJtZXRhZGF0YTciPgogICAgPHJkZjpSREY+CiAgICAgIDxjYzpXb3JrCiAgICAgICAgIHJkZjphYm91dD0iIj4KICAgICAgICA8ZGM6Zm9ybWF0PmltYWdlL3N2Zyt4bWw8L2RjOmZvcm1hdD4KICAgICAgICA8ZGM6dHlwZQogICAgICAgICAgIHJkZjpyZXNvdXJjZT0iaHR0cDovL3B1cmwub3JnL2RjL2RjbWl0eXBlL1N0aWxsSW1hZ2UiIC8+CiAgICAgICAgPGRjOnRpdGxlIC8+CiAgICAgIDwvY2M6V29yaz4KICAgIDwvcmRmOlJERj4KICA8L21ldGFkYXRhPgogIDxnCiAgICAgaW5rc2NhcGU6bGFiZWw9IkxheWVyIDEiCiAgICAgaW5rc2NhcGU6Z3JvdXBtb2RlPSJsYXllciIKICAgICBpZD0ibGF5ZXIxIgogICAgIHRyYW5zZm9ybT0idHJhbnNsYXRlKC02LjMyNjA5NDIsLTE3NC43NTI0KSI+CiAgICA8ZwogICAgICAgaWQ9ImczMDUyIj4KICAgICAgPHBhdGgKICAgICAgICAgc3R5bGU9ImZpbGw6IzMyNmNlNTtmaWxsLW9wYWNpdHk6MTtzdHJva2U6I2ZmZmZmZjtzdHJva2Utd2lkdGg6MDtzdHJva2UtbWl0ZXJsaW1pdDo0O3N0cm9rZS1vcGFjaXR5OjE7c3Ryb2tlLWRhc2hhcnJheTpub25lIgogICAgICAgICBkPSJtIDM2NS4zMTI1LDE4NC44MTI1IGEgNDYuNzI0NjIxLDQ2LjM0MjI0NiAwIDAgMCAtMTcuOTA2MjUsNC41MzEyNSBsIC0yNDQuMzQzNzUsMTE2Ljc1IGEgNDYuNzI0NjIxLDQ2LjM0MjI0NiAwIDAgMCAtMjUuMjgxMjUsMzEuNDM3NSBMIDE3LjUsNTk5Ljc4MTI1IEEgNDYuNzI0NjIxLDQ2LjM0MjI0NiAwIDAgMCAyMy44NDM3NSw2MzUuMzEyNSA0Ni43MjQ2MjEsNDYuMzQyMjQ2IDAgMCAwIDI2LjUsNjM5IGwgMTY5LjEyNSwyMTAuMjgxMjUgYSA0Ni43MjQ2MjEsNDYuMzQyMjQ2IDAgMCAwIDM2LjUzMTI1LDE3LjQzNzUgTCA1MDMuMzc1LDg2Ni42NTYyNSBBIDQ2LjcyNDYyMSw0Ni4zNDIyNDYgMCAwIDAgNTM5LjkwNjI1LDg0OS4yNSBMIDcwOC45Njg3NSw2MzguOTM3NSBBIDQ2LjcyNDYyMSw0Ni4zNDIyNDYgMCAwIDAgNzE4LDU5OS43MTg3NSBsIC02MC4zNzUsLTI2Mi4yNSBhIDQ2LjcyNDYyMSw0Ni4zNDIyNDYgMCAwIDAgLTI1LjI4MTI1LC0zMS40Mzc1IGwgLTI0NC4zNzUsLTExNi42ODc1IEEgNDYuNzI0NjIxLDQ2LjM0MjI0NiAwIDAgMCAzNjUuMzEyNSwxODQuODEyNSB6IgogICAgICAgICBpZD0icGF0aDMwNTUiCiAgICAgICAgIGlua3NjYXBlOmNvbm5lY3Rvci1jdXJ2YXR1cmU9IjAiCiAgICAgICAgIGlua3NjYXBlOmV4cG9ydC1maWxlbmFtZT0ibmV3LnBuZyIKICAgICAgICAgaW5rc2NhcGU6ZXhwb3J0LXhkcGk9IjI1MC41NSIKICAgICAgICAgaW5rc2NhcGU6ZXhwb3J0LXlkcGk9IjI1MC41NSIgLz4KICAgICAgPHBhdGgKICAgICAgICAgaW5rc2NhcGU6Y29ubmVjdG9yLWN1cnZhdHVyZT0iMCIKICAgICAgICAgaWQ9InBhdGgzMDU5IgogICAgICAgICBkPSJtIDM2Ny43MzM2NiwyNzQuMDU5NjIgYyAtOC4wNzY5Niw4LjJlLTQgLTE0LjYyNTk2LDcuMjc1OTEgLTE0LjYyNSwxNi4yNSAxZS01LDAuMTM3NzMgMC4wMjgyLDAuMjY5MzQgMC4wMzEyLDAuNDA2MjUgLTAuMDExOSwxLjIxOTM2IC0wLjA3MDgsMi42ODgzNiAtMC4wMzEyLDMuNzUgMC4xOTI2Miw1LjE3NiAxLjMyMDksOS4xMzc0OSAyLDEzLjkwNjI1IDEuMjMwMjgsMTAuMjA2NjYgMi4yNjExNywxOC42NjczNiAxLjYyNSwyNi41MzEyNSAtMC42MTg2OSwyLjk2NTQgLTIuODAyODgsNS42Nzc0MSAtNC43NSw3LjU2MjUgbCAtMC4zNDM3NSw2LjE4NzUgYyAtOC43NzY4MiwwLjcyNzE3IC0xNy42MTIzNSwyLjA1ODc0IC0yNi40Mzc1LDQuMDYyNSAtMzcuOTc0NjEsOC42MjIxOCAtNzAuNjcwMDgsMjguMTgzMDcgLTk1LjU2MjUsNTQuNTkzNzUgLTEuNjE1MjIsLTEuMTAxOTMgLTQuNDQxMDMsLTMuMTI5MTQgLTUuMjgxMywtMy43NSAtMi42MTExNywwLjM1MjYyIC01LjI1MDIxLDEuMTU4MjkgLTguNjg3NSwtMC44NDM3NSAtNi41NDQ5MSwtNC40MDU2MyAtMTIuNTA1ODcsLTEwLjQ4NjkzIC0xOS43MTg3NSwtMTcuODEyNSAtMy4zMDQ5OCwtMy41MDQxOSAtNS42OTgzMiwtNi44NDEwMSAtOS42MjUsLTEwLjIxODc1IC0wLjg5MTcyLC0wLjc2NzA3IC0yLjI1MjU4LC0xLjgwNDU1IC0zLjI1LC0yLjU5Mzc1IC0zLjA2OTg4LC0yLjQ0NzU3IC02LjY5MDcsLTMuNzI0MDIgLTEwLjE4NzUsLTMuODQzNzUgLTQuNDk1ODksLTAuMTUzOTQgLTguODIzOTQsMS42MDM4NSAtMTEuNjU2MjUsNS4xNTYyNSAtNS4wMzUyMSw2LjMxNTM4IC0zLjQyMzEyLDE1Ljk2ODA1IDMuNTkzNzUsMjEuNTYyNSAwLjA3MTIsMC4wNTY3IDAuMTQ3MDIsMC4xMDA3OCAwLjIxODc1LDAuMTU2MjUgMC45NjQyMiwwLjc4MTYyIDIuMTQ0OTYsMS43ODMxMyAzLjAzMTI1LDIuNDM3NSA0LjE2Njg3LDMuMDc2NTUgNy45NzMyLDQuNjUxNDUgMTIuMTI1LDcuMDkzNzUgOC43NDcsNS40MDE4MSAxNS45OTgzNyw5Ljg4MDg2IDIxLjc1LDE1LjI4MTI1IDIuMjQ2MDIsMi4zOTQxNyAyLjYzODU4LDYuNjEyOTIgMi45Mzc1LDguNDM3NSBsIDQuNjg3NSw0LjE4NzUgYyAtMjUuMDkzNDIsMzcuNzYzNjggLTM2LjcwNjg2LDg0LjQwOTQ2IC0yOS44NDM3LDEzMS45Mzc1IGwgLTYuMTI1LDEuNzgxMjUgYyAtMS42MTQzLDIuMDg0NjEgLTMuODk1NDEsNS4zNjQ3NCAtNi4yODEzLDYuMzQzNzUgLTcuNTI1MTMsMi4zNzAyMSAtMTUuOTk0MjQsMy4yNDA1OSAtMjYuMjE4NzUsNC4zMTI1IC00LjgwMDMxLDAuMzk5MTUgLTguOTQyMTgsMC4xNjA5NSAtMTQuMDMxMjUsMS4xMjUgLTEuMTIwMDgsMC4yMTIxOCAtMi42ODA3MiwwLjYxODc3IC0zLjkwNjI1LDAuOTA2MjUgLTAuMDQyNiwwLjAwOSAtMC4wODI0LDAuMDIxNiAtMC4xMjUsMC4wMzEyIC0wLjA2NjgsMC4wMTU1IC0wLjE1NDU2LDAuMDQ3OSAtMC4yMTg3NSwwLjA2MjUgLTguNjIwMTQsMi4wODI3OSAtMTQuMTU3NzQsMTAuMDA2IC0xMi4zNzUsMTcuODEyNSAxLjc4MzE2LDcuODA4MzMgMTAuMjAzMTQsMTIuNTU2NzcgMTguODc1LDEwLjY4NzUgMC4wNjI2LC0wLjAxNDMgMC4xNTM1LC0wLjAxNjcgMC4yMTg3NSwtMC4wMzEyIDAuMDk3OSwtMC4wMjI0IDAuMTg0MDksLTAuMDY5OSAwLjI4MTI1LC0wLjA5MzcgMS4yMDg4NSwtMC4yNjUzNiAyLjcyMzc3LC0wLjU2MDYgMy43ODEyNSwtMC44NDM3NSA1LjAwMzM0LC0xLjMzOTYzIDguNjI2OTQsLTMuMzA3OTYgMTMuMTI1LC01LjAzMTI1IDkuNjc2OTQsLTMuNDcwNzcgMTcuNjkxNzMsLTYuMzcwMjIgMjUuNSwtNy41IDMuMjYxMTgsLTAuMjU1NDIgNi42OTcxMSwyLjAxMjE2IDguNDA2MjUsMi45Njg3NSBsIDYuMzc1LC0xLjA5Mzc1IGMgMTQuNjcwMTgsNDUuNDgyODIgNDUuNDE0MTYsODIuMjQ1MDIgODQuMzQzNzUsMTA1LjMxMjUgbCAtMi42NTYyNSw2LjM3NSBjIDAuOTU3NDIsMi40NzU0MiAyLjAxMzQxLDUuODI0NyAxLjMwMDIyLDguMjY5MzIgLTIuODM4NjgsNy4zNjEyIC03LjcwMDk3LDE1LjEzMDk3IC0xMy4yMzc3MiwyMy43OTMxOCAtMi42ODA4NSw0LjAwMTkyIC01LjQyNDUzLDcuMTA3NjEgLTcuODQzNzUsMTEuNjg3NSAtMC41Nzg5LDEuMDk1ODkgLTEuMzE2MTgsMi43NzkzMiAtMS44NzUsMy45Mzc1IC0zLjc1ODg0LDguMDQyMzYgLTEuMDAxNjQsMTcuMzA1MiA2LjIxODc1LDIwLjc4MTI1IDcuMjY1NzUsMy40OTc4OCAxNi4yODQ0NywtMC4xOTEzNCAyMC4xODc1LC04LjI1IDAuMDA2LC0wLjAxMTQgMC4wMjU3LC0wLjAxOTggMC4wMzEyLC0wLjAzMTIgMC4wMDQsLTAuMDA5IC0wLjAwNCwtMC4wMjI1IDAsLTAuMDMxMiAwLjU1NTkzLC0xLjE0MjU1IDEuMzQzNTMsLTIuNjQ0MzcgMS44MTI1LC0zLjcxODc1IDIuMDcyMTMsLTQuNzQ3MDIgMi43NjE2MSwtOC44MTUwNiA0LjIxODc1LC0xMy40MDYyNSAzLjg2OTYyLC05LjcyMDE0IDUuOTk1NjcsLTE5LjkxOTAzIDExLjMyMjU4LC0yNi4yNzQxMSAxLjQ1ODY4LC0xLjc0MDIzIDMuODM2ODEsLTIuNDA5NSA2LjMwMjQyLC0zLjA2OTY0IGwgMy4zMTI1LC02IGMgMzMuOTM4MjQsMTMuMDI2OCA3MS45MjY2NiwxNi41MjI0NiAxMDkuODc1LDcuOTA2MjUgOC42NTY5NywtMS45NjU1NyAxNy4wMTQ0NCwtNC41MDk0NSAyNS4wOTM3NSwtNy41NjI1IDAuOTMwOTgsMS42NTEzMyAyLjY2MTEzLDQuODI1NyAzLjEyNSw1LjYyNSAyLjUwNTU5LDAuODE1MTggNS4yNDA0NCwxLjIzNjE0IDcuNDY4NzUsNC41MzEyNSAzLjk4NTM5LDYuODA4OTggNi43MTA5LDE0Ljg2NDE2IDEwLjAzMTI1LDI0LjU5Mzc1IDEuNDU3MzgsNC41OTExMSAyLjE3NzYyLDguNjU5MzMgNC4yNSwxMy40MDYyNSAwLjQ3MjM0LDEuMDgxOTUgMS4yNTYsMi42MDQ4NiAxLjgxMjUsMy43NSAzLjg5NDgyLDguMDg0ODQgMTIuOTQyMTIsMTEuNzg2NjcgMjAuMjE4NzUsOC4yODEyNSA3LjIxOTUsLTMuNDc3OSA5Ljk3OTc0LC0xMi43Mzk5IDYuMjE4NzUsLTIwLjc4MTI1IC0wLjU1ODg5LC0xLjE1ODE0IC0xLjMyNzMsLTIuODQxNjQgLTEuOTA2MjUsLTMuOTM3NSAtMi40MTk0NiwtNC41Nzk3NiAtNS4xNjI3LC03LjY1NDQ4IC03Ljg0Mzc1LC0xMS42NTYyNSAtNS41MzcyMSwtOC42NjE5MiAtMTAuMTI5NjgsLTE1Ljg1NzcgLTEyLjk2ODc1LC0yMy4yMTg3NSAtMS4xODcxMSwtMy43OTY1NyAwLjIwMDI4LC02LjE1Nzc0IDEuMTI1LC04LjYyNSAtMC41NTM3OCwtMC42MzQ3NyAtMS43Mzg4MSwtNC4yMjAwOSAtMi40Mzc1LC01LjkwNjI1IDQwLjQ1NzQsLTIzLjg4ODE2IDcwLjI5ODU2LC02Mi4wMjEyOSA4NC4zMTI1LC0xMDYuMDYyNSAxLjg5MjQsMC4yOTc0MiA1LjE4MTU0LDAuODc5MzYgNi4yNSwxLjA5Mzc1IDIuMTk5NTQsLTEuNDUwNyA0LjIyMTk0LC0zLjM0MzUyIDguMTg3NSwtMy4wMzEyNSA3LjgwODMyLDEuMTI5MzcgMTUuODIyODgsNC4wMjk3MyAyNS41LDcuNSA0LjQ5ODE1LDEuNzIzMDYgOC4xMjE2LDMuNzIzMTMgMTMuMTI1LDUuMDYyNSAxLjA1NzQ5LDAuMjgzMDkgMi41NzIzOCwwLjU0NzIgMy43ODEyNSwwLjgxMjUgMC4wOTcyLDAuMDIzOCAwLjE4MzMsMC4wNzE0IDAuMjgxMjUsMC4wOTM3IDAuMDY1MywwLjAxNDYgMC4xNTYxNSwwLjAxNjkgMC4yMTg3NSwwLjAzMTIgOC42NzIzNiwxLjg2Njk1IDE3LjA5Mzg0LC0yLjg3ODcxIDE4Ljg3NSwtMTAuNjg3NSAxLjc4MDc0LC03LjgwNjk2IC0zLjc1NDMsLTE1LjczMjAxIC0xMi4zNzUsLTE3LjgxMjUgLTEuMjUzOTMsLTAuMjg1MTMgLTMuMDMyMjUsLTAuNzY5MzggLTQuMjUsLTEgLTUuMDg5MTIsLTAuOTYzNzggLTkuMjMwOTIsLTAuNzI2MSAtMTQuMDMxMjUsLTEuMTI1IC0xMC4yMjQ1NiwtMS4wNzEzOCAtMTguNjkzNSwtMS45NDI2OSAtMjYuMjE4NzUsLTQuMzEyNSAtMy4wNjgyNiwtMS4xOTAyOCAtNS4yNTEwMywtNC44NDEyNCAtNi4zMTI1NSwtNi4zNDM3NSBsIC01LjkwNjI1LC0xLjcxODc1IGMgMy4wNjIyNiwtMjIuMTU0NDIgMi4yMzY1NSwtNDUuMjExMzQgLTMuMDYyNSwtNjguMjgxMjUgLTUuMzQ4MzksLTIzLjI4NDcxIC0xNC44MDAzNywtNDQuNTgwODQgLTI3LjQwNjI1LC02My4zNDM3NSAxLjUxNTA1LC0xLjM3NzI5IDQuMzc2MTksLTMuOTEwOTEgNS4xODc1LC00LjY1NjI1IDAuMjM3MTYsLTIuNjI0MTcgMC4wMzM0LC01LjM3NTUzIDIuNzUsLTguMjgxMjUgNS43NTEzNCwtNS40MDA2OSAxMy4wMDMyOSwtOS44Nzg5OCAyMS43NSwtMTUuMjgxMjUgNC4xNTE2NywtMi40NDI1MiA3Ljk4OTU0LC00LjAxNjk4IDEyLjE1NjI1LC03LjA5Mzc1IDAuOTQyMjUsLTAuNjk1NzYgMi4yMjg5LC0xLjc5NzU5IDMuMjE4NzUsLTIuNTkzNzUgNy4wMTUzOCwtNS41OTYzMyA4LjYzMDU4LC0xNS4yNDg0MiAzLjU5Mzc1LC0yMS41NjI1IC01LjAzNjgzLC02LjMxNDA4IC0xNC43OTcxMiwtNi45MDg4MyAtMjEuODEyNSwtMS4zMTI1IC0wLjk5ODU2LDAuNzkwODUgLTIuMzUzNTMsMS44MjI1MiAtMy4yNSwyLjU5Mzc1IC0zLjkyNjUsMy4zNzc5NiAtNi4zNTE0NSw2LjcxNDM5IC05LjY1NjI1LDEwLjIxODc1IC03LjIxMjQ5LDcuMzI1OTUgLTEzLjE3NDA3LDEzLjQzNzc3IC0xOS43MTg3NSwxNy44NDM3NSAtMi44MzYwMSwxLjY1MTA2IC02Ljk4OTk2LDEuMDc5NzggLTguODc1MDUsMC45Njg3NSBsIC01LjU2MjUsMy45Njg3NSBjIC0zMS43MTg4LC0zMy4yNjA1NyAtNzQuOTA0NjYsLTU0LjUyNTQ2IC0xMjEuNDA2MDUsLTU4LjY1NjMgLTAuMTMwMDYsLTEuOTQ4NzIgLTAuMzAwNDUsLTUuNDcxMTcgLTAuMzQzNzUsLTYuNTMxMjUgLTEuOTAzNzEsLTEuODIxNjUgLTQuMjAzNDIsLTMuMzc2ODYgLTQuNzgxMjUsLTcuMzEyNSAtMC42MzYxNywtNy44NjM4OSAwLjQyNTk3LC0xNi4zMjQ1OSAxLjY1NjI1LC0yNi41MzEyNSAwLjY3OTEsLTQuNzY4NzYgMS44MDczOCwtOC43MzAyNSAyLC0xMy45MDYyNSAwLjA0MzgsLTEuMTc2NjMgLTAuMDI2NSwtMi44ODQwMSAtMC4wMzEyLC00LjE1NjI1IC05LjZlLTQsLTguOTc0MDkgLTYuNTQ4MDQsLTE2LjI1MDgyIC0xNC42MjUsLTE2LjI1IHogbSAtMTguMzEyNSwxMTMuNDM3NSAtNC4zNDM3NSw3Ni43MTg3NSAtMC4zMTI1LDAuMTU2MjUgYyAtMC4yOTEzNCw2Ljg2MzM1IC01LjkzOTk2LDEyLjM0Mzc1IC0xMi44NzUsMTIuMzQzNzUgLTIuODQwODEsMCAtNS40NjI5NCwtMC45MTIyOSAtNy41OTM3NSwtMi40Njg3NSBsIC0wLjEyNSwwLjA2MjUgLTYyLjkwNjI1LC00NC41OTM3NSBjIDE5LjMzMzY1LC0xOS4wMTExNSA0NC4wNjI5MSwtMzMuMDYwMzkgNzIuNTYyNSwtMzkuNTMxMjUgNS4yMDU5OSwtMS4xODIwMyAxMC40MDk2NiwtMi4wNTkxIDE1LjU5Mzc1LC0yLjY4NzUgeiBtIDM2LjY1NjI1LDAgYyAzMy4yNzM0Nyw0LjA5MjMyIDY0LjA0NTAxLDE5LjE1ODgyIDg3LjYyNSw0Mi4yNSBsIC02Mi41LDQ0LjMxMjUgLTAuMjE4NzUsLTAuMDkzNyBjIC01LjU0NzQ1LDQuMDUxNjkgLTEzLjM2MzQzLDMuMDQ2MzkgLTE3LjY4NzUsLTIuMzc1IC0xLjc3MTMyLC0yLjIyMDk2IC0yLjcwMDcyLC00LjgzMjM5IC0yLjgxMjUsLTcuNDY4NzUgbCAtMC4wNjI1LC0wLjAzMTIgeiBtIC0xNDcuNjI1LDcwLjg3NSA1Ny40Mzc1LDUxLjM3NSAtMC4wNjI1LDAuMzEyNSBjIDUuMTg0MzcsNC41MDY5NyA1Ljk0ODg4LDEyLjMyNzk0IDEuNjI1LDE3Ljc1IC0xLjc3MTIsMi4yMjEwNSAtNC4xNDIwOCwzLjcxMDc0IC02LjY4NzUsNC40MDYyNSBsIC0wLjA2MjUsMC4yNSAtNzMuNjI1LDIxLjI1IGMgLTMuNzQ3MjgsLTM0LjI2NTE3IDQuMzI4NTUsLTY3LjU3MzY0IDIxLjM3NSwtOTUuMzQzNzUgeiBtIDI1OC4xNTYyNSwwLjAzMTIgYyA4LjUzNDEsMTMuODMyNTYgMTQuOTk2NTUsMjkuMjgyMTQgMTguODQzNzUsNDYuMDMxMjUgMy44MDEwNiwxNi41NDgyOCA0Ljc1NDk5LDMzLjA2Njk3IDMuMTg3NSw0OS4wMzEyNSBsIC03NCwtMjEuMzEyNSAtMC4wNjI1LC0wLjMxMjUgYyAtNi42MjY1LC0xLjgxMTA0IC0xMC42OTg5MywtOC41NTE2MiAtOS4xNTYyNSwtMTUuMzEyNSAwLjYzMjAzLC0yLjc2OTYyIDIuMTAyMjIsLTUuMTEyNjQgNC4wOTM3NSwtNi44NDM3NSBsIC0wLjAzMTIsLTAuMTU2MjUgNTcuMTI1LC01MS4xMjUgeiBtIC0xNDAuNjU2MjUsNTUuMzEyNSAyMy41MzEyNSwwIDE0LjYyNSwxOC4yODEyNSAtNS4yNSwyMi44MTI1IC0yMS4xMjUsMTAuMTU2MjUgLTIxLjE4NzUsLTEwLjE4NzUgLTUuMjUsLTIyLjgxMjUgeiBtIDc1LjQzNzUsNjIuNTYyNSBjIDAuOTk5OTcsLTAuMDUwNSAxLjk5NTU4LDAuMDM5NiAyLjk2ODc1LDAuMjE4NzUgbCAwLjEyNSwtMC4xNTYyNSA3Ni4xNTYyNSwxMi44NzUgYyAtMTEuMTQ1NSwzMS4zMTMxIC0zMi40NzI4MSw1OC40NDAxOCAtNjAuOTY4NzUsNzYuNTkzNzUgbCAtMjkuNTYyNSwtNzEuNDA2MjUgMC4wOTM3LC0wLjEyNSBjIC0yLjcxNTYxLC02LjMwOTk5IDAuMDAyLC0xMy43MDk1NiA2LjI1LC0xNi43MTg3NSAxLjU5OTY1LC0wLjc3MDQxIDMuMjcwODksLTEuMTk3MDEgNC45Mzc1LC0xLjI4MTI1IHogbSAtMTI3LjkwNjI1LDAuMzEyNSBjIDUuODExNzQsMC4wODE1IDExLjAyNDYyLDQuMTE1MjUgMTIuMzc1LDEwLjAzMTI1IDAuNjMyMTksMi43Njk1OCAwLjMyNDUsNS41MTM3NSAtMC43MTg3NSw3LjkzNzUgbCAwLjIxODc1LDAuMjgxMjUgLTI5LjI1LDcwLjY4NzUgYyAtMjcuMzQ3MTYsLTE3LjU0ODYgLTQ5LjEyOTI3LC00My44MjQwMyAtNjAuNzgxMjUsLTc2LjA2MjQ1IGwgNzUuNSwtMTIuODEyNSAwLjEyNSwwLjE1NjI1IGMgMC44NDQ1MSwtMC4xNTU0MSAxLjcwMSwtMC4yMzA0IDIuNTMxMjUsLTAuMjE4NzUgeiBtIDYzLjc4MTI1LDMwLjk2ODggYyAyLjAyNDQ1LC0wLjA3NDQgNC4wNzg2NSwwLjM0MDk4IDYuMDMxMjUsMS4yODEyNSAyLjU1OTUxLDEuMjMyNTMgNC41MzY3MywzLjE3MzE5IDUuNzgxMjUsNS41IGwgMC4yODEyNSwwIDM3LjIxODc1LDY3LjI1IGMgLTQuODMwMjksMS42MTkyMyAtOS43OTYwOSwzLjAwMzA4IC0xNC44NzUsNC4xNTYyNSAtMjguNDY0NTMsNi40NjI5IC01Ni44Mzg2Miw0LjUwNDY3IC04Mi41MzEyNSwtNC4yNSBsIDM3LjEyNSwtNjcuMTI1IDAuMDYyNSwwIGMgMi4yMjc2NywtNC4xNjQ0MSA2LjQ1MjQ3LC02LjY0ODg3IDEwLjkwNjI1LC02LjgxMjUgeiIKICAgICAgICAgc3R5bGU9ImZvbnQtc2l6ZTptZWRpdW07Zm9udC1zdHlsZTpub3JtYWw7Zm9udC12YXJpYW50Om5vcm1hbDtmb250LXdlaWdodDpub3JtYWw7Zm9udC1zdHJldGNoOm5vcm1hbDt0ZXh0LWluZGVudDowO3RleHQtYWxpZ246c3RhcnQ7dGV4dC1kZWNvcmF0aW9uOm5vbmU7bGluZS1oZWlnaHQ6bm9ybWFsO2xldHRlci1zcGFjaW5nOm5vcm1hbDt3b3JkLXNwYWNpbmc6bm9ybWFsO3RleHQtdHJhbnNmb3JtOm5vbmU7ZGlyZWN0aW9uOmx0cjtibG9jay1wcm9ncmVzc2lvbjp0Yjt3cml0aW5nLW1vZGU6bHItdGI7dGV4dC1hbmNob3I6c3RhcnQ7YmFzZWxpbmUtc2hpZnQ6YmFzZWxpbmU7Y29sb3I6IzAwMDAwMDtmaWxsOiNmZmZmZmY7ZmlsbC1vcGFjaXR5OjE7c3Ryb2tlOiNmZmZmZmY7c3Ryb2tlLXdpZHRoOjAuMjU7c3Ryb2tlLW1pdGVybGltaXQ6NDtzdHJva2Utb3BhY2l0eToxO3N0cm9rZS1kYXNoYXJyYXk6bm9uZTttYXJrZXI6bm9uZTt2aXNpYmlsaXR5OnZpc2libGU7ZGlzcGxheTppbmxpbmU7b3ZlcmZsb3c6dmlzaWJsZTtlbmFibGUtYmFja2dyb3VuZDphY2N1bXVsYXRlO2ZvbnQtZmFtaWx5OlNhbnM7LWlua3NjYXBlLWZvbnQtc3BlY2lmaWNhdGlvbjpTYW5zIgogICAgICAgICBzb2RpcG9kaTpub2RldHlwZXM9ImNjY2NjY2Njc2NjY2NzY3NzY2NzY2NjY2NjY2NzY2Njc2NjY2NjY2NjY2NjY2Njc2NjY3Njc2Njc2NjY2NzY3Njc2NjY2NjY2Njc2NjY3Njc2NjY2NzY2NjY3Njc2NzY2NjY2NjY2NjY2NjY2Njc2NjY3NjY2NjY2NjY2NjY2NzY2NjY2NzY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NzY2Njc2NjY2NjY2NjY3NjY2NzY2NjYyIKICAgICAgICAgaW5rc2NhcGU6ZXhwb3J0LWZpbGVuYW1lPSIuL3BhdGgzMDU5LnBuZyIKICAgICAgICAgaW5rc2NhcGU6ZXhwb3J0LXhkcGk9IjI1MC41NSIKICAgICAgICAgaW5rc2NhcGU6ZXhwb3J0LXlkcGk9IjI1MC41NSIgLz4KICAgIDwvZz4KICA8L2c+Cjwvc3ZnPgo='
};
                 

                for (const svg in svgData) {
                    const img = new Image();
                    img.src = svgData[svg];
                    img.onload = () => {
                        this.images.push(img);
                        this.imagesLoaded++;
                        if (this.imagesLoaded === Object.keys(svgData).length) {
                            this.start();
                        }
                    };
                }
            }

            draw() {
                this.ctx.fillStyle = 'rgba(0, 0, 0, 0.05)';
                this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
                this.ctx.fillStyle = '#0F0';
                this.ctx.font = this.font_size + 'px arial';

                this.tickCounter++;

                if (this.tickCounter >= this.TICKS_BEFORE_UPDATE) {
                    this.matrix = this.matrix.map((y, x) => {
                        let newY = y;

                        if (Math.random() > this.PROBABILITY_SVG) {
                            const randomImage = this.images[Math.floor(Math.random() * this.images.length)];
                            this.ctx.drawImage(randomImage, x * this.font_size, y * this.font_size, this.font_size, this.font_size);
                            newY = y + 1;
                        } else {
                            const text = String.fromCharCode(0x30A0 + Math.random() * (0x30FF - 0x30A0 + 1));
                            this.ctx.fillText(text, x * this.font_size, y * this.font_size);
                        }

                        if (y * this.font_size > this.canvas.height && Math.random() > this.PROBABILITY_RESET) newY = 0;

                        return newY;
                    });
                    this.tickCounter = 0;
                }
            }

            start() {
                setInterval(() => this.draw(), 16);
            }
        }

new Matrix(el);

</script>
The ultimate solution I've been looking for with a Tailscale Operator type of solution is something that works at the http layer and supports DNS and SSL integration (via letsencrypt) to enable a better more secure user experience for connecting to clusters.  Over the course of writing this post, my wish came try when Maism landed the <a href="https://q6o.to/ghptsc9048" target="_blank">initial PR that adds ingress support to the Tailscale Operator</a>.  This provided the final missing link I was looking for. So this post wouldn't be complete with a quick tour of that.  It's also worth noting that because Ingress support doesn't depend on the iptables or nftables layer, my original issue is also solved without any of the concerns I've articulated above.  Time heals all.

In order to leverage Ingress support, the earlier example is modified by removing annotation from the service and adding an ingress manifest with a modified tailscale annotation:
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
nginx-tailscale   tailscale   *       nginx-test.tailxxxx.ts.net   80, 443   7m52s
```

Assuming you have Tailscales' wonderful <a href="https://q6o.to/tsckb1081" target="_blank">MagicDNS</a> enabled, you can now visit https://nginx-test.tailxxxx.ts.net from the browser of any device on your tailnet and get SSL secured access to your cluster.  Mission accomplished!  Thx Maisem!

## Funnel
Fast forward to October and even more of the feature has now landed including support for Tailscale's [funnel functionality](https://tailscale.com/kb/1223/tailscale-funnel/) which allows you to route traffic from the wider internet to the cluster curtoursey of the operator.  The [official documentation for the Tailscale operator](https://github.com/tailscale/tailscale/issues/502#issuecomment-1729911852) has also been been updated with instructions for all of this goodness.

Funnel support builds on the previous ingress example, my adding a simple annotation:

```yaml
    annotations:
       tailscale.com/funnel: "true"
```

In order for this to work, it's also necessary to ensure that the correct scope is present in the Tailnet policy file as follows:

```json
"target": ["autogroup:members","tag:k8s"]
```

## Next steps
There is an additional feature that enables Tailscale to perform the duties of an authenticating proxy for the k8s control plane which sounds interesting and I plan to try out at some point.

For the scenario of enabling one cluster to access other tailnet resources, there is also an egress proxy solution that I need to look at.

## Wrap-up

Thanks for reading this far!  I hope you've been able to learn something new.  Would love to know how you get on your journey into the fun world of Containers, Kubernetes and Tailscale.  Stay in touch here <a href="https://q6o.to/czt" target="_blank">`x Twitter`</a> or <a href="https://q6o.to/czm" target="_blank">`Mastodon`</a>
