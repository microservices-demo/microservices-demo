# Installing sock-shop on Minikube

1) Install minikube (https://github.com/kubernetes/minikube)

2) Start minikube

```
minikube start
```

Make sure minikube is running on http://192.168.99.100:30000

3) Clone the microservices-demo repo

```
git clone https://github.com/microservices-demo/microservices-demo
```

4) Start the Sock Shop application

```
kubectl create -f microservices-demo/deploy/kubernetes/manifests/sock-shop-ns.yml -f microservices-demo/deploy/kubernetes/manifests
```

5) Wait for all the services to start

```
kubectl get pods --namespace="sock-shop"
```

6) Visit the Sock Shop webpage at http://192.168.99.100:30001
