#!/usr/bin/env bash
# https://github.com/jekyll/docker/wiki/Usage:-Running
docker run -it --rm \
  --label=jekyll \
  --volume=$(pwd):/srv/jekyll \
  --volume=$(pwd)/_config.yml.dev:/srv/jekyll/_config.yml \
  -p 127.0.0.1:4000:4000 \
  jekyll/jekyll $@

