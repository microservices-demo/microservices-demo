# Setup and Installation on Kubernetes

(If you already have running k8s cluster skip to [here](#deploy-app))

Setup up Kubernetes cluster on AWS using [kubernetes-anywhere](https://github.com/kubernetes/kubernetes-anywhere) (with Terraform)

```
git clone https://github.com/microservices-demo/microservices-demo
cd deploy/kubernetes/terraform
```

Add AWS credentials to main.tf file, or set them via environmental variables. For example: `export TF_VAR_aws_access_key="YOURACCESSKEY"`.

Run terraform

```
terraform get
terraform plan
terraform apply
```

### Configure CNI
On each node 

```
mkdir -p /opt/cni/bin
mkdir -p /etc/cni/net.d
weave setup
```

### Setup Sky DNS
```
kubectl create -f kubernetes/definitions/ksNamespace.yaml
kubectl create -f kubernetes/definitions/skydns-rc.yaml
kubectl create -f kubernetes/definitions/skydns-svc.yaml
```


## Deploy App

If using kubernetes-anywhere, log in to one of the nodes and run the toolbox:
```
$ kubernetes-anywhere-toolbox
toolbox-v1.2: Pulling from weaveworks/kubernetes-anywhere
a3ed95caeb02: Already exists
1534505fcbc6: Already exists
8ff1c5a70d4f: Already exists
c09721473cfb: Already exists
0a7bcdbea144: Already exists
Digest: sha256:f1aa045e94af6348737ea10434f5c6c4e2007eb7ffdd8cab06073986ac5163a6
Status: Image is up to date for weaveworks/kubernetes-anywhere:toolbox-v1.2
toolbox: Pulling from kubernetes-weave1/node/pki
4b6551c216ec: Already exists
d2f125e331a0: Already exists
987137dc1ed6: Already exists
Digest: sha256:2bb7fe2155bc390f110cbffa532c3b036b18ea2092d6807bab9c22da2a2a99cc
Status: Image is up to date for 477246929820.dkr.ecr.eu-west-1.amazonaws.com/kubernetes-weave1/node/pki:toolbox
```

From within the toolbox, launch the app (services can also be run individually):
```
[root@35e9a53bd68e resources]#kubectl create -f kubernetes/definitions/wholeWeaveDemo.yaml
```

To find external address, run:
```
# kubectl describe service front-end
Name:			front-end
Namespace:		default
Labels:			name=front-end
Selector:		name=front-end
Type:			LoadBalancer
IP:			10.19.148.205
LoadBalancer Ingress:	a9371cf443f6e11e6aa5f0242ac11000-1884285323.eu-west-1.elb.amazonaws.com
Port:			<unset>	80/TCP
NodePort:		<unset>	31633/TCP
Endpoints:		10.45.0.6:8079
Session Affinity:	None
Events:
  FirstSeen	LastSeen	Count	From			SubobjectPath	Type		Reason			Message
  ---------	--------	-----	----			-------------	--------	------			-------
  47m		47m		2	{service-controller }			Normal		CreatingLoadBalancer	Creating load balancer
  47m		47m		2	{service-controller }			Normal		CreatedLoadBalancer	Created load balancer
  ```

Connect to "LoadBalancer Ingress" address

### Install Scope

On each node
```
sudo wget -O /usr/local/bin/scope https://git.io/scope
sudo chmod a+x /usr/local/bin/scope
sudo scope launch --no-app
```
On Master
```
sudo wget -O /usr/local/bin/scope https://git.io/scope
sudo chmod a+x /usr/local/bin/scope
sudo scope launch
```

Access port 4040 on Master to view Scope App

## Uninstall App

Remove all deployments (will also remove pods)
```
kubectl delete deployments --all
```
Remove all services, except kubernetes
```
kubectl delete service $(kubectl get services | cut -d" " -f1 | grep -v NAME | grep -v kubernetes)
```
