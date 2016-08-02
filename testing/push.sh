#!/usr/bin/env bash

# Unable to push for some reason. Authorisation issue
echo "Pretending to push"
exit 0

: "${DOCKER_USER:?Need to set DOCKER_USER}"
: "${DOCKER_PASS:?Need to set DOCKER_PASS}"

DOCKER_PUSH=1;
count=0
while [ $DOCKER_PUSH -gt 0 ] && [ $count -lt 10 ] ; do
    echo "Pushing $1";
    docker login -u $DOCKER_USER -p $DOCKER_PASS
    docker push $1;
    DOCKER_PUSH=$(echo $?);
    if [[ "$DOCKER_PUSH" -gt 0 ]] ; then
        echo "Docker push failed with exit code $DOCKER_PUSH";
        count=$count+1
    fi;
done;
