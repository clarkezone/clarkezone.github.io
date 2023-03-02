---
layout: post
title:  "Kubernetes Cluster API for Azure quick start"
date: 2023-02-21 08:51:02 -0800
categories: [kubernetes]
tags: [CAPI, CAPZ]
---
Audience for this post: kubernetes admins, SRE, dev ops 

This post is a quick primer on leveraging the Cluster API Provider for Azure (CAPZ) to quickly deploy an AKS cluster.

To quote from the <a href="https://s.clarkezone.dev/capza" target="_blank">introdutory post for this feature</a>, 

> Managing Kubernetes clusters is hard.
> 
> Managing Kubernetes clusters at scale across a variety of infrastructures is—well—even harder.
> 
> The Kubernetes community project Cluster API (CAPI) enables users to manage fleets of clusters across multiple infrastructure providers. The Cluster API Provider for Azure (CAPZ) is the solution for users who need to manage Kubernetes clusters on Azure IaaS. In the past, we have recommended AKS Engine for this common scenario.  While we will continue to provide regular, stable releases for AKS Engine, the Azure team is excited to share that CAPZ is now ready for users and will be our primary tool for enabling customers to operate self-managed Kubernetes clusters on Azure IaaS.

I wasn't personally familar with the Cluster API until I participated in a hackathon with a couple of folks from the AKS team last year.

Prerequisizes
- docker
- make
- Azure ClI
- Tilt: https://docs.tilt.dev/install.html
- kind

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

For convenience you can grab the above with curl -LO 

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

4. Create service principal passing in subscription id from above:
`az ad sp create-for-rbac --role contributor --scopes="/subscriptions/<REPLACE-WITH-SUBSCRIPTION-ID-FIELD>"`

5. Update the tilt-settings.json updating
  - AZURE_SUBSCRIPTION_ID with subscription id
  - AZURE_TENANT_ID with tenant id
  - AZURE_CLIENT_SECRET with password from create-for-rbac
  - AZURE_CLIENT_ID with appId from create-for-rbac

### Run tilt
The makefile has a handy dandy help command which you can get via `make help` to help get oriented.

1. Create a kind cluster
`make kind-create`

2. Generate the machine templates
`make generate-flavors`

3. Start tilt to enable GUI for creating clusters
`make tilt-up`

### Deploy vanilla AKS cluster to your supscription
1. Open a browser and navigate to the tilt web server that you just started above:

2. Click on the AKS-TODO item

3. wait for deploy

4. confirm in subscription

5. take a look at the cluster resource you created in you capz control cluster


### Delete vanilla AKS cluster
Tilt is just a web front end manipulating resources in the capz control cluster running in kind.  Even though we created the cluster from the GUI, we are going to delete the cluster by manipulating objects in the control cluster.

1. `kubectl delete cluster`

## Create a new receipe
Now that we've created a cluster based on the default template, let's create a new template that alters the recepie of the AKS cluster.

6. Deploy that

9. Tear down 
`make kind-reset`

Deploy a cluster without tilt

Delete a cluster without tilt

Next how to install CAPZ into a homeland cluster
