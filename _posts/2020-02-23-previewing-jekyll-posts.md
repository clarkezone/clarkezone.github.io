---
layout: post
commentshortlink: "http://ps-s.clarkezone.dev/p10"
title:  "Previewing Jekyll blog posts"
date: 2020-02-23 08:06:57 -0800
categories: [blogging,jekyll]
tags: [golang]
---

This github pages blog is powered by [Jekyll](https://jekyllrb.com), a static site generator.  Because I've been using the iPad for content creation and because the posts are written in raw markdown, I've found it quite hard to get previews of posts; I need a way of  seeing what they will look like in final form when rendered in the context of github pages.  Why do I need a preview you may ask?  Well, things like having the Jekyll template applied, seeing the layout, embeds etc often need iteration and tweaking.  In order for preview to be useful, I have the following requirements:

1. Preview before the post is "live" with final formatting and styling applied
2. Preview any branch.  I use git branches to author new posts and I'm often writing a number of posts at once
3. Preview can run in the cloud so I can view it from any device including the iPad

### Jekyll

To meet the above requirements I was looking for a docker image for simplicity of deployment capable of running Jekyll and updating the static content as I push updates into git from my markdown editor.  The solution turned out to be part off-the-shelf and part bespoke.  For Jekyll preview there is an [existing docker image of jekyll on docker hub](https://hub.docker.com/r/jekyll/jekyll) 

![jekyll image](/static/img/2020-02-15-jekyllpreview/jekylljekyll.png)

which does most of the business for us out of the box including rendering markdown to HTML and monitoring a folder for changes and keeping the preview updated.

### WebHook

The one missing feature of the pre-built image is a mechanism for getting the content from Github and updating it as changes are made.  This translates to  performing the initial clone of the relavent repository and then waiting for webhook triggers to indicate when to pull the relavent branch in response to changes being pushed from other clients.

This part required a bit of code.  I found a great library called hookserve that makes it easy to build a webhook handler in Go: [github.com/phayes/hookserve/hookserve](github.com/phayes/hookserve/hookserve).  It's trivial to listen for changes and and respond accordingly:

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

I opted for using the [os.exec package](https://golang.org/pkg/os/exec/) to interact with git for pulling, changing branches etc rather than a git library mainly because I'm familiar with that approach.  I might well change this in future iterations.

The whole solution is pretty trivial.  If you're interested, the complete source code is at [https://github.com/clarkezone/JekyllPreview](https://github.com/clarkezone/JekyllPreview).

### WebHook configuration

In order to get the webhook triggers, we need to configure webooks on the blocg repo pointing to the preview server where we'll be deploying the docker image to.  This will target port 8080 where our webhook listener will be listening.

![jekyll image](/static/img/2020-02-15-jekyllpreview/webhookconfig.png)

### Docker build

To make the Docker image, we will use a multi-stage docker build that compiles our golang helper and adds it to the existing jekyll docker image:

```docker
FROM golang:alpine as builder
RUN mkdir /build
ADD . /build
WORKDIR /build
RUN go build

FROM jekyll/jekyll
USER root
RUN mkdir /app
COPY --from=builder /build/JekyllBlogPreview /app/.
WORKDIR /app
ADD startjek.sh .
RUN chmod +x startjek.sh
ENV JEKPREV_LOCALDIR=/srv/jekyll/source
ENV JEKPREV_monitorCmd=/app/startjek.sh

ENTRYPOINT [ "/app/JekyllBlogPreview" ]
```

At some point it would be nice to make this not jekyll specific and support different static site generators but for now this project is jekyll only.

### Docker Compose

For simplicity of deployment, I've published the image [on docker hub](https://hub.docker.com/repository/docker/clarkezone/jekpreview).  To use it, you'll need a machine with docker and docker-compose installed, then a `docker-compose.yml` similar to

```docker-compose
version: "3.7"
services:
        grpcservice:
                image: clarkezone/jekpreview:release-0.0.3
                ports:
                        - "8080:8080"  #wehhook targets this port
                        - "80:4000" #preview is hosted on port 80
                environment:
                        - JEKPREV_REPO=<URL to git repo containing blog>
                        - JEKPREV_SECRET=<Secret you configured on your web hook>
```
replacing `JEKPREV_REPO` and `JEKPREV_SECRET` substituting the secret you set up your webhook with.  Make sure that when you configure the webhook, you pointed it at the url / ip address of server on which you deploy the image.

That's it.  After a quick `docker-compose up -d` it's preview a go-go.  Every time a change or new branch is pushed to the blog repository, the webhook will trigger a git pull

![jekyll image](/static/img/2020-02-15-jekyllpreview/webhookfire.png)

and jekyll will regenerate the site.

![jekyll image](/static/img/2020-02-15-jekyllpreview/preview.jpeg)

### Future
Although this simple solution is functional and working, there are a couple of limitations which I plan on addressing in future revisions:

1. Currently the last writer wins.. whichever branch was last pushed is what will be previewed and only a single branch can be previewed at once.  In the future, each branch get's it's own folder enabling previews of multiple branches at the same time.  
2. Currently I'm working on posts in branches on the main github repo.  In the future I intend to move to using a secure fork of the blog hosted on gitlab for post creation.  Supporting that workflow will require a better way of talking securly to git servers
3. Currently, previews are hosted in the open secured only by the obscurity of the server the preview system is running on.  In the future I will add  basic security for previews
4. Currently, there is no web UI for managing previews, view progress or errors.  I'll likely build a simple webui for managing all of this

