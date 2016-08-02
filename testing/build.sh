#!/usr/bin/env bash

module=${PWD##*/}
REPO=weaveworksdemo/${module}
echo "Building $module"
if [[ "${module}" == "payment" ]] || [[ "${module}" == "catalogue" ]] || [[ "${module}" == "login" ]] ; then
    docker build -t ${REPO}-dev .;
    docker create --name ${module} ${REPO}-dev;
    docker cp ${module}:/app/main ./app;
    docker rm ${module};
    docker build -t $1 -f ./Dockerfile-release .;
else
    docker build -t $1 .;
fi;
