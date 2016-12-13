# Installing sock-shop on Minikube

1) Install minikube (https://github.com/kubernetes/minikube)

2) `minikube start`

Make sure minikube is running on http://192.168.99.100:30000

3) Clone the microservices-demo repo

Fix a bug!

4) Edit the `microservices-demo/deploy/kubernetes/manifests/front-end-svc.yaml` file, and change the "NodePort" to be 30001.

Start the Sock Shop application

5) `kubectl create -f microservices-demo/deploy/kubernetes/manifests/sock-shop-ns.yml -f microservices-demo/deploy/kubernetes/manifests`

Wait for all the services to start:

6) `kubectl get pods --namespace="sock-shop"`

Visit the Sock Shop webpage

7) http://192.168.99.100:30001
