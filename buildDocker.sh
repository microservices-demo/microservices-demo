#!/usr/bin/env bash
#Usage: ./buildDocker.sh $MODULE $BRANCH $COMMIT
set -x

export MODULE=$1
export BRANCH=$2
export COMMIT=$3
echo "Building $MODULE docker image"
export REPO=weaveworksdemos/$MODULE
export TAG=`if [ "$BRANCH" == "master" ]; then echo "snapshot"; else echo $BRANCH ; fi`
docker build -t $REPO:$COMMIT ./$MODULE
docker tag $REPO:$COMMIT $REPO:$TAG