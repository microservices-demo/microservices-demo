#!/usr/bin/env bash

if [ "$TRAVIS_EVENT_TYPE" == "cron" ]; then
  echo "Not pushing artifacts in cron jobs";
  exit 0;
fi;

if [ -z "$DOCKER_PASS" ] ; then
  echo "This is a build triggered by an external PR. Skipping docker push.";
  exit 0;
fi;

echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

for svc in openapi healthcheck; do
    export REPO=${GROUP}/$(basename $svc);
    echo "Building ${REPO}:$TRAVIS_COMMIT";
    docker build -t ${REPO}:$TRAVIS_COMMIT ./$svc; DOCKER_EXIT=$(echo $?); if [[ "$DOCKER_EXIT" > 0 ]] ; then
      echo "Docker build failed with exit code $DOCKER_EXIT";
      exit 1;
    fi;
    export DOCKER_PUSH=1;
    while [ "$DOCKER_PUSH" -gt 0 ] ; do
      echo "Pushing $REPO:$TRAVIS_COMMIT";
      docker push $REPO:$TRAVIS_COMMIT;
      DOCKER_PUSH=$(echo $?);
      if [[ "$DOCKER_PUSH" -gt 0 ]] ; then
        echo "Docker push failed with exit code $DOCKER_PUSH";
      fi;
    done;
    if [ "$TRAVIS_BRANCH" == "master" ]; then
      docker tag $REPO:$TRAVIS_COMMIT $REPO:snapshot;
      echo "Pushing $REPO:snapshot";
      docker push $REPO:snapshot;
    fi;
    if [ ! -z "$TRAVIS_TAG" ];
      then docker tag $REPO:$TRAVIS_COMMIT $REPO:$TRAVIS_TAG;
      docker push $REPO:$TRAVIS_TAG;
      docker tag $REPO:$TRAVIS_COMMIT $REPO:latest;
      docker push $REPO:latest;
    fi;
done

mkdir cfn-to-publish
jq ".Description += \" (microservices-demo/microservices-demo@${TRAVIS_COMMIT})\"" "deploy/aws-ecs/cloudformation.json" > cfn-to-publish/microservices-demo.json
