# Installing sock-shop on Minikube

1) Install minikube
2) `minikube start`

Make sure minikube is running on http://192.168.99.100:30000

3) Clone the microservices-demo repo

Create the namespace for sock-shop
4) `kubectl create -f microservices-demo/deploy/kubernetes/manifests/ksNamespace.yaml`

Fix a bug!
5) Edit the `microservices-demo/deploy/kubernetes/manifests/front-end-svc.yaml` file, and change the "NodePort" to be 30001.

6) `kubectl create -f microservices-demo/deploy/kubernetes/manifests`

Wait for all the services to start:
7) `watch kubectl get pods --namespace="sock-shop"`

8) http://192.168.99.100:30001
