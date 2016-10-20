#!/usr/bin/env bash
# https://github.com/jekyll/docker/wiki/Usage:-Running
docker run --rm --label=jekyll --volume=$(pwd):/srv/jekyll \
    -it -p 127.0.0.1:4000:4000 jekyll/jekyll $@

