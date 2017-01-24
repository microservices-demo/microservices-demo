# Installing sock-shop on Kubernetes

See the [documentation](https://microservices-demo.github.io/microservices-demo/deployment/kubernetes.html) on how to deploy Sock Shop using Minikube.

## Kubernestes manifests

There are 2 sets of manifests for deploying Sock Shop on Kubernetes: one in the [manifests directory](manifests/), and complete-demo.yaml. The complete-demo.yaml is a single file manifest
made by concatenating all the manifests from the manifests directory, so please regenerate it when changing files in the manifests directory.
