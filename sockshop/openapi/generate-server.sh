#!/usr/bin/env bash

set -e

module=$1
output=$2

self=$(basename $0)

function help() {
    echo "Usage: $self <json-spec-location-filename (should be under sockshop/openapi directory)> <server-code-output-location>"   
}

if [[ "$module" == "" ]] || [[ "$output" == "" ]] ; then
    help
    exit 1
fi

fileUrl=https://raw.githubusercontent.com/weaveworks/microservices-demo/"$(git rev-parse HEAD)"/sockshop/openapi/"$module"

if ! out=$(curl -sf $fileUrl); then
    echo "Couldn't get the file at $fileUrl"
    exit 1;
fi

link=$(curl -sf -XPOST -H "content-type:application/json" -d "{\"swaggerUrl\":\"$fileUrl\"}" https://generator.swagger.io/api/gen/servers/go | jq .link | sed s/\"//g)

if [ "$link" == "" ]; then
    echo "Download link is broken. This error needs to improve."
    exit 1
fi

mkdir -p $output

curl -sf $link > $output/go-server.tar && tar -xvf $output/go-server.tar -C $output/ && rm -f $output/go-server.tar
