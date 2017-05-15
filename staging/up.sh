#!/bin/bash

WEAVE_SERVICE_TOKEN=$1
KUBE_VERSION=$(kubectl version | base64 | tr -d '\n')

kubectl apply -f "https://git.io/weave-kube-1.6"
kubectl apply -n kube-system -f "https://cloud.weave.works/k8s/scope.yaml?service-token=$WEAVE_SERVICE_TOKEN&k8s-version=$KUBE_VERSION"
kubectl apply -n kube-system -f "https://cloud.weave.works/k8s/flux.yaml?service-token=$WEAVE_SERVICE_TOKEN&k8s-version=$KUBE_VERSION"
kubectl apply -n kube-system -f "https://cloud.weave.works/k8s/cortex.yaml?service-token=$WEAVE_SERVICE_TOKEN&k8s-version=$KUBE_VERSION"
kubectl apply -f ~/microservices-demo/deploy/kubernetes/manifests/sock-shop-ns.yaml -f ~/microservices-demo/deploy/kubernetes/manifests/zipkin-ns.yaml -f ~/microservices-demo/deploy/kubernetes/manifests
rm join.cmd
