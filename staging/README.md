# Staging Environment for the Microservice Demo


# Setup cluster

Use the scripts in this directory to set up a Kubernetes cluster on AWS from a Bastion host.

* Create a bastion host in AWS

* Install terraform

* Clone this repository

* Copy [terraform.tfvars.example](./terraform.tfvars.example) to terraform.tfvars and enter the missing information. Look for a description of the variables in [variables.tf](./variables.tf).

* Plan the terraform run: `terraform plan -out staging.plan`

* If all looks well, apply the plan: `terraform apply staging.plan`.

  If it somehow fails, destroy the cluster with `terraform destroy -force` and try again.

* Access the Sock Shop via the elb url displayed when you run `terraform output`. Weave Scope/Flux should be visible from Weave Cloud.

# Kubectl

* kubectl should work from the bastion to control the kubernetes cluster

# Setup/Control Weave Flux

* To gain control of flux download the binary from [here](https://github.com/weaveworks/flux/releases/latest), and export the Weave Cloud flux token.

  ```
  export FLUX_SERVICE_TOKEN=<sock shop weave cloud token>
  ```

* To make changes to the flux config you can run `get-config` to download the current config.

  ```
  fluxctl get-config > flux.conf
  ```

* Fill in missing values, and run `fluxctl set-config --file=flux.conf`


* To set sock-shop services to update automatically you can set it with the command below

  ```
  for svc in front-end catalogue orders queue-master user cart catalogue user-db catalogue-db payment shipping; do
    fluxctl automate --service=sock-shop/$svc
  done
  ```
