#!/usr/bin/env bash

SCRIPT_NAME=`basename "$0"`
GROUP="weaveworksdemos"
NAMESPACE="sock-shop"

if [ "$#" -ne 2 ]
then
  echo "Script to deploy images to a k8s cluster. Requires working kubectl.
  Usage: $SCRIPT_NAME [service/image name] [image tag]"
  exit 1
fi

kubectl set image deployment/$1 $1=$GROUP/$1:$2 --namespace=$NAMESPACE
