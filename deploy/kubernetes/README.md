# Installing sock-shop on Kubernetes

See the [documentation](https://microservices-demo.github.io/microservices-demo/deployment/kubernetes.html) on how to deploy Sock Shop using Minikube.

## Kubernestes manifests

There are 2 sets of manifests for deploying Sock Shop on Kubernetes: one in the [manifests directory](manifests/), and complete-demo.yaml. The complete-demo.yaml is a single file manifest
made by concatenating all the manifests from the manifests directory, so please regenerate it when changing files in the manifests directory.

## Monitoring

All monitoring is performed by prometheus. All services expose a `/metrics` endpoint. All services have a Prometheus Histogram called `request_duration_seconds`, which is automatically appended to create the metrics `_count`, `_sum` and `_bucket`.
