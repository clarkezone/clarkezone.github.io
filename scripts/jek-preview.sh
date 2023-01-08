#!/bin/sh
# docker run -it --rm --entrypoint /bin/sh -v /home/james/src/:/src -p 0.0.0.0:4000:4000 registry.hub.docker.com/clarkezone/jekyll:sha-df0a146
# use ctrl p, ctrl q to detach and lead docker running
cd /src/github.com/clarkezone/clarkezone.github.io || exit
apk add build-base
bundle install
bundle exec jekyll serve --host=0.0.0.0
