# Staging Environment for the Microservice Demo

Use the scripts in this directory to set up a Kubernetes cluster on AWS from a Bastion host. 

* Create a bastion host in AWS

* Install terraform

* Install kubectl

* Clone this repository

* Enter the missing information in [terraform.tfvars](./terraform.tfvars). See a description in [variables.tf](./variables.tf).

* Plan the terraform run: `terraform plan -out staging.plan`

* If all looks well, apply the plan: `terraform apply staging.plan`.

  If it somehow fails, destroy the cluster with `terraform destroy -force` and try again.

* Install the microservices demo

  ```
  kubectl apply -f microservices-demo/deploy/kubernetes/manifests/sock-shop-ns.yml -f microservices-demo/deploy/kubernetes/manifests
  ```

* Install Weave Scope

  ```
  kubectl apply -f microservices-demo/deploy/kubernetes/definitions/scope.yaml --validate=false
  ```