---
layout: post
title:  "Kubernetes Cluster API for Azure quick start"
date: 2023-02-21 08:51:02 -0800
categories: [kubernetes, AzureKubernetesService, ClusterAPI]
tags: [CAPI, CAPZ, AKS]
---
_Audience for this post: Platform engineers, Kubernetes admins, SREs, dev ops peeps_

This post is the first in a series on <a href="https://q6o.to/capzb" target="_blank">Cluster API Provider for Azure (CAPZ).</a>

<img style="transform: translatex(0%);left:0; padding-right:20px" src="/static/img/2023-02-21-capz-quickstart/kenny-eliason-uq5RMAZdZG4-unsplash.jpg" align="left"/>
To quote from the <a href="https://q6o.to/capzi" target="_blank">introdutory post from the Azure team</a>: 

> Managing Kubernetes clusters is hard.
> 
> Managing Kubernetes clusters at scale across a variety of infrastructures is—well—even harder.
> 
> The Kubernetes community project Cluster API (CAPI) enables users to manage fleets of clusters across multiple infrastructure providers. The Cluster API Provider for Azure (CAPZ) is the solution for users who need to manage Kubernetes clusters on Azure IaaS. In the past, we have recommended AKS Engine for this common scenario.  While we will continue to provide regular, stable releases for AKS Engine, the Azure team is excited to share that CAPZ is now ready for users and will be our primary tool for enabling customers to operate self-managed Kubernetes clusters on Azure IaaS.

I wasn't personally familar with the <a href="https://q6o.to/kcapi" target="_blank">Kubernetes Cluster API</a> until I participated in a hackathon with a couple of folks from the <a href="https://q6o.to/aksa" target="_blank">Azure Kubernetes Service</a> team last year.  I lucked out in that <a href="https://q6o.to/jackfrancis" target="_blank">Jack Francis</a>, one of the AKS devs sponsoring the hackathon,  worked on the project and co-authored the above blog post.  I learned a great deal from Jack on that hack (thank you Sir!); that the Kubernetes Cluster API is a means of representing kubernetes clusters as <a href="https://q6o.to/kcrd" target="_blank">CRD's</a> and using the declaritive nature of <a href="https://q6o.to/kmana" target="_blank">kubernetes manifests</a> to describe and manage kubernetes infrastructure in a cloud neutral way.  CAPZ is the provider that brings Azure support to the cluster API.  CAPZ replaces the erstwhile <a href="https://q6o.to/aksengine" target="_blank">AKS Engine</a> for performing self-managed kubernetes on Azure on <a href="https://q6o.to/vmssa" target="_blank">VM scale sets</a>.  All the things about kustodian.  But I digress.

I'm going to start the series with the place I myself started: cloning the <a href="https://q6o.to/capzr" target="_blank">CAPZ repo</a>, building a local management cluster using <a href="https://q6o.to/kinda" target="_blank">Kind</a> and then using a handy built in <a href="https://q6o.to/tilta" target="_blank">Tilt</a> setup to graphically enable me to create different types of clusters. 

Prerequisizes
- git: (<a href="https://q6o.to/giti" target="_blank">install</a>)
- docker: (<a href="https://q6o.to/dockeri" target="_blank">install</a>)
- make: (<a href="https://q6o.to/makei" target="_blank">install</a>)
- Azure CLI: (<a href="https://q6o.to/azclii" target="_blank">install</a>)
- Tilt: (<a href="https://q6o.to/tilti" target="_blank">install</a>)
- kind: (<a href="https://q6o.to/kindi" target="_blank">install</a>)

### Clone the CAPZ repo
1. `git clone https://github.com/kubernetes-sigs/cluster-api-provider-azure.git`

### Get tiltsettings.json going:
1. Create placeholder file named `tilt-settings.json` in the root of the repository as follows:

```json
{
  "kustomize_substitutions": {
    "AZURE_SUBSCRIPTION_ID": "00000000-0000-0000-0000-000000000000",
    "AZURE_TENANT_ID": "00000000-0000-0000-0000-000000000000",
    "AZURE_CLIENT_SECRET": "AaA1A~1AaA1111AAAaaaaaAaaaaaa-A1A1aaaaAa",
    "AZURE_CLIENT_ID": "00000000-0000-0000-0000-000000000000",
    "AZURE_ENVIRONMENT": "AzurePublicCloud",
    "AZURE_SSH_PUBLIC_KEY_B64": ""
  },
  "worker-templates": {
    "flavors": {
      "default": {
        "WORKER_MACHINE_COUNT": "1",
        "KUBERNETES_VERSION": "v1.23.6",
        "AZURE_LOCATION": "westus2",
        "AZURE_NODE_MACHINE_TYPE": "Standard_D2s_v3",
        "CONTROL_PLANE_MACHINE_COUNT": "1"
      }
    },
    "metadata": {}
  }
}
```

For convenience you can grab the above with `curl -o tilt-settings.json -L https://raw.githubusercontent.com/clarkezone/cluster-api-provider-azure/blogpost/tilt-settings-template.json`

### Populate subscription and service principal details
2. Login via Azure CLI:
`az login`


3. Get subscription id and tenant id using az cli:

```bash
# subscription id
az account show --query id --outpt tsv

# tenant id
az account show --query homeTenantId --output tsv
```

4.Create service principal passing in subscription id from above:
```bash
az ad sp create-for-rbac --role contributor --scopes="/subscriptions/<REPLACE-WITH-SUBSCRIPTION-ID-FIELD>"
```

5. Update the tilt-settings.json updating
  - AZURE_SUBSCRIPTION_ID with subscription id
  - AZURE_TENANT_ID with tenant id
  - AZURE_CLIENT_SECRET with password from create-for-rbac
  - AZURE_CLIENT_ID with appId from create-for-rbac

### Run tilt
The makefile has a handy dandy help command which you can get via `make help` to help get oriented.

1. Create a kind cluster
```bash
make kind-create
```
If all goes well, the result of this command is a bunch of terminal spew for kind spinning up a cluster.  If you check registered contexts with `kubectl config get-contexts` you should see kind-capz that has been selected as the current.

<img style="" src="/static/img/2023-02-21-capz-quickstart/kindrunning.png" align="left"/>

2. Generate the machine templates
```bash
make generate-flavors
```
This step can take quite a bit of time.  The result is a bunch of under-the-covers template expansion which enabnles subsequent steps.

<img style="" src="/static/img/2023-02-21-capz-quickstart/generate-flavors.png" align="left"/>

3. Start tilt to enable GUI for creating clusters
```bash
make tilt-up
```

This comand starts a tilt session which you can connect to from your browser.  This is esentially a GUI in front of CAPZ which enables you to create various flavors via the browser.

<img style="" src="/static/img/2023-02-21-capz-quickstart/tiltupcmd.png" align="left"/>
It's worth noting here that Tilt is incidental to CAPZ.  There is no hard dependency here, if you follow the instructions for installing CAPZ (TODO link) into your own "pilot" cluster, you won't end up with tilt at all.

### Deploy vanilla AKS cluster to your supscription
1. Open a browser and navigate to the tilt web server that you just started above.  In my case this is `localhost:3333`

<img style="" src="/static/img/2023-02-21-capz-quickstart/tiltupgui.png" align="left"/>

2. Click on the AKS link which should take you to a detailed streen as follows:

<img style="" src="/static/img/2023-02-21-capz-quickstart/launchakspng.png" align="left"/>

3. click on the refresh icon.  Result is a bunch of console spew showing up in the window. 

<img style="" src="/static/img/2023-02-21-capz-quickstart/startinstall.png" />

If all went well, you shuold see the final line `Cluster 'aks-20648' created, don't forget to delete`

<img style="" src="/static/img/2023-02-21-capz-quickstart/aksinstallcompletetiltgui.png" align="left"/>

You can now monitor the provision progress in capz:

```bash
kubectl get cluster
```

<img style="" src="/static/img/2023-02-21-capz-quickstart/get-cluster.png" align="left"/>

And once it gets beyond a certain point also in the azure portal:



4. confirm in subscription

5. take a look at the cluster resource you created in you capz control cluster


### Delete vanilla AKS cluster
Tilt is just a web front end manipulating resources in the capz control cluster running in kind.  Even though we created the cluster from the GUI, we are going to delete the cluster by manipulating objects in the control cluster.

1. `kubectl delete cluster aks-20648`

## Create a new receipe
Now that we've created a cluster based on the default template, let's create a new template that alters the recepie of the AKS cluster.

6. Deploy that

9. Tear down 
`make kind-reset`

Deploy a cluster without tilt

Delete a cluster without tilt

Next how to install CAPZ into a homeland cluster
