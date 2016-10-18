# Staging Environment for the Microservice Demo

Use the scripts in this directory to set up a Kubernetes cluster on AWS from a Bastion host. 

* Create a bastion host in AWS

* Install terraform

* Install kubectl

* Clone this repository

* Copy [terraform.tfvars.example](./terraform.tfvars.example) to terraform.tfvars and enter the missing information. Look for a description of the variables in [variables.tf](./variables.tf).

* Plan the terraform run: `terraform plan -out staging.plan`

* If all looks well, apply the plan: `terraform apply staging.plan`.

  If it somehow fails, destroy the cluster with `terraform destroy -force` and try again.

* Install the microservices demo

  ```
  kubectl apply -f ~/microservices-demo/deploy/kubernetes/manifests/sock-shop-ns.yml -f ~/microservices-demo/deploy/kubernetes/manifests
  ```

* Install Weave Scope

  ```
  kubectl apply -f ~/microservices-demo/deploy/kubernetes/definitions/weavescope.yaml --validate=false
  ```

* Get the NodePort of the sock-shop front-end service

  ```
  kubectl describe svc front-end --namespace sock-shop
  ```

* Get the NodePort of the scope service

  ```
  kubectl describe svc weavescope-app
  ```

* Add the NodePorts to the AWS Security Group

  ```
  aws ec2 authorize-security-group-ingress --group-name microservices-demo-staging-k8s --protocol tcp --port [front-end NodePort] --cidr 0.0.0.0/0
  aws ec2 authorize-security-group-ingress --group-name microservices-demo-staging-k8s --protocol tcp --port [weavescope NodePort] --cidr 0.0.0.0/0
  ```

* Access the Sock Shop front end and Weave Scope on any of the addresses output by `terraform output` on their respective ports.

