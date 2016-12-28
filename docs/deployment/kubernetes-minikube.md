---
layout: default
deployDoc: true
---

## Sock Shop on Minikube

This demo demonstrates running the Sock Shop on Minikube.

### Pre-requisites
* Install [Minikube](https://github.com/kubernetes/minikube)
* Install [kubectl](http://kubernetes.io/docs/user-guide/prereqs/)

### Clone the microservices-demo repo 

```
git clone https://github.com/microservices-demo/microservices-demo
cd microservices-demo
```

### Start Minikube

You can start Minikube by running:

<!-- deploy-doc-start start-minikube -->


    minikube start

<!-- deploy-doc-end -->

Check if it's running with `minikube status`, and make sure the Kubernetes dashboard is running on http://192.168.99.100:30000.

##### Run with Fluentd logging

If you want to run the application using a more advanced logging setup based on Fluentd + ELK stack, you need to login to the minikube vm and increase the vm.max_map_count.
This step is required because Elasticsearch will not start if it detects a value lower than 262144, and boot2docker, which is the VM used by minikube, has a default value which lower that. 

```
sudo sysctl -w vm.max_map_count=262144
```

Another requirement for running the logging applications is a higher amount of memory for the Minikube VM. The VM is configured by default with 4GB and we recommend assigning at least 6GB.

```
minikube delete
minikube config set memory 6144
minikube start
```

Once these settings are done you can start the logging manifests.

```
kubectl create -f deploy/kubernetes/manifests-logging
```

### Deploy Sock Shop

Deploy the Sock Shop application on Minikube

<!-- deploy-doc-start create-application -->

    kubectl create -f deploy/kubernetes/manifests/sock-shop-ns.yml -f deploy/kubernetes/manifests

<!-- deploy-doc-end -->

Wait for all the Sock Shop services to start:

```
kubectl get pods --namespace="sock-shop"
```

### Check the Sock Shop webpage

Once the application is deployed, navigate to http://192.168.99.100:30001 to see the Sock Shop home page.

### Uninstall the Sock Shop application

<!-- deploy-doc-start delete-application -->

    kubectl delete -f deploy/kubernetes/manifests/sock-shop-ns.yml -f deploy/kubernetes/manifests

<!-- deploy-doc-end -->

If you don't need the Minikube instance anynmore you can delete it by running:

<!-- deploy-doc-start delete-minikube -->

    minikube delete

<!-- deploy-doc-end -->