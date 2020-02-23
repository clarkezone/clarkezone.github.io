---
layout: post
title:  "Previewing Jekyll blog posts"
date: 2020-02-15 17:06:57 -0800
categories: [blogging]
tags: [jekyll,golang]
---

This github pages blog is powered by [Jekyll](https://jekyllrb.com), a static site generator.  Because I've been using the iPad for content creation and because the posts are written in raw markdown, I've found it quite hard to get previews of posts as I'm writing showing what they will finally look like when rendered in the context of github pages.  Why do I need a preview you may ask?  Well, things like having the Jekyll template applied, seeing the layout, embeds etc often need iteration and tweaking.  In order for preview to be useful, I have the following requirements:

1. Preview before the post is "live" with final formatting and styling applied
2. Preview any branch.  I use git branches to author new posts and I'm often writing a number of posts at once
3. Preview can run in the cloud so I can view it from any device including the iPad

### Jekyll

To meet the above requirements I was looking for a docker image for simplicity of deployment capable of running the Jekyll and updating the static content as I push updates into git from my markdown editor.  The solution turned out to be part off-the-shelf and part bespoke.  For Jekyll preview there is an [existing docker image of jekyll on docker hub](https://hub.docker.com/r/jekyll/jekyll) 

![jekyll image](/static/img/2020-02-15-jekyllpreview/jekylljekyll.png)

which does most of the business for us out of the box including monitoring a folder for changes.

### WebHook

The one missing part is doing the initial clone the relavent github repo and then waiting for webhook updates to pull the relavent branch in response to changes being pushed to the branch.  This part required a bit of code.  I found a great library called hookserve that makes it easy to build a webhook in Go: [github.com/phayes/hookserve/hookserve](github.com/phayes/hookserve/hookserve).  It's then trivial to listen for changes and grab them:

```go
    for event := range server.Events {
		fmt.Println(event.Owner + " " + event.Repo + " " + event.Branch + " " + event.Commit)

		if event.Branch != currentBranch {
			currentBranch = event.Branch
			fmt.Printf("Checking out new branch %v\n", currentBranch)
			cmd := exec.Command("git", "checkout", currentBranch)
			cmd.Dir = localfolder
			err := cmd.Run()

			if err != nil {
				return err
			}
		}

		fmt.Printf("Pull branch: %v\n", event.Branch)
		cmd := exec.Command("git", "pull")
		cmd.Dir = localfolder
		err := cmd.Run()

		if err != nil {
			return err
		}

	}
```

I opted for using os.exec to interact with git rather than a git library.  The complete source code is at [https://github.com/clarkezone/JekyllPreview](https://github.com/clarkezone/JekyllPreview).

### WebHook configuration

In order to get the webhook triggers, we need to configure webooks on the repo pointing to the server where we'll be deploying the docker image to targeting port 8080 where our webhook listener will be listening.

![jekyll image](/static/img/2020-02-15-jekyllpreview/webhookconfig.png)

### Docker build

We then need to do a multi-stage docker build that compiles our golang helper and adds it to the existing jekyll docker image:

```docker
FROM golang:alpine as builder
RUN mkdir /build
ADD . /build
WORKDIR /build
RUN go build

FROM jekyll/jekyll
user root
RUN mkdir /app
COPY --from=builder /build/JekyllBlogPreview /app/.
WORKDIR /app
ADD startjek.sh .
env JEKPREV_LOCALDIR=/srv/jekyll/source
env JEKPREV_monitorCmd=/app/startjek.sh

CMD ["sh", "-c", "/app/JekyllBlogPreview"]
```

### Docker Compose

For simplicity, I've published the image and made [available on docker hub](https://hub.docker.com/repository/docker/clarkezone/jekpreview).  To use it, this simple docker compose file is all you need with blog repo url and the secret for the webhook.  Make sure that when you configure the webhook, you point it at the server on which you deploy the image.

```docker-compose
version: "3.7"
services:
        grpcservice:
                image: clarkezone/jekpreview:latest
                ports:
                        - "8080:8080"  #wehhook targets this port
                        - "80:4000" #preview is hosted on port 80
                environment:
                        - JEKPREV_REPO=<URL to git repo containing blog>
                        - JEKPREV_SECRET=<Secret you configured on your web hook>
```

That's it.  Preview a go-go.

![jekyll image](/static/img/2020-02-15-jekyllpreview/preview.jpeg)

![jekyll image](/static/img/2020-02-15-jekyllpreview/webhookfire.png)

TODO image of preview

