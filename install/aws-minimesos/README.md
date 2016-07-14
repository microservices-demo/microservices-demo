# Running the Weave Demo on AWS Using Minimesos and Terraform

This directory provides code to install the demo on an AWS instance running minimesos. This is primarily intended to help with testing the weave demo on Mesos.

## Prerequisites
- Terraform

## Quick start

```
export TF_VAR_aws_key_name=<AWS-SSH-KEY-NAME> ; export TF_VAR_private_key_file=path/to/ssh/pem ; export TF_VAR_access_key=<AWS-ACCESS-KEY> ; export TF_VAR_secret_key=<AWS-SECRET-KEY> 
terraform apply
```


## Debugging

To ssh into the instance, export the variables returned by terraform, then: `ssh -i $KEY ubuntu@$IP`
