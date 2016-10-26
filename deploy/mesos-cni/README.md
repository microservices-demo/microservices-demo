<!-- deploy-test require-env AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION -->

# Deploy to Mesos using CNI

This guide describes how to deploy Sock Shop to a Mesos cluster that has CNI and Weave Net installed. Deployment is done using `mesos-execute` commands.

*For testing only* Because CNI support is so new, it is not supported in Marathon and some features are missing from Weave. The containers are not orchestrated, so if they crash, they will not be restarted.

## Caveates

- Tested with Mesos 1.0.0
- These scripts start containers using mesos-execute. Not marathon (due to lack of marathon support). Hence, they are not orchestrated. If they crash, they will not be restarted.
- Sometimes Docker hub can respond with 500's. It might take few tries to get it running.
- Mesos only supports CNI from version 1.0.0+
- Mesos only supports CNI on the Mesos containerizer
- Weave DNS does not work with Weave CNI
- This was developed on AWS. May not work on other services.

Please this blog post about the new [mesos unified containerizer](http://winderresearch.com/2016/07/02/Overview-of-Mesos-New-Unified-Containerizer/) for more information.

## Install the prerequisites

Provisioning a Mesos cluster requires the following prerequisites

* `git`
* `curl`
* [jq](https://stedolan.github.io/jq/)
* `terraform`
* [Mesos Terraform on AWS](https://github.com/philwinder/mesos-terraform))

<!-- deploy-test-start pre-install -->
    apt-get install uuid-runtime awscli jq curl
<!-- deploy-test-end -->

## Create the infrastructure

Create a key pair on AWS and run Mesos Terraform to create the Mesos cluster.
<!-- deploy-test-start create-infrastructure -->
    export PRIVATE_KEY_NAME=deploy-mesos-cni-$(uuidgen)
    echo $PRIVATE_KEY_NAME > private_key_name.txt
    aws ec2 create-key-pair --key-name $PRIVATE_KEY_NAME > deploy-mesos-cni-key.json
    cat deploy-mesos-cni-key.json | jq -r .KeyMaterial > deploy-mesos-cni-key.pem
    chmod 600 deploy-mesos-cni-key.pem
    
    export TF_VAR_access_key=$AWS_ACCESS_KEY_ID
    export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY
    export TF_VAR_private_key_file=$PWD/deploy-mesos-cni-key.pem
    export TF_VAR_aws_key_name=$PRIVATE_KEY_NAME
    
    curl https://releases.hashicorp.com/terraform/0.7.7/terraform_0.7.7_linux_amd64.zip > terraform.zip
    unzip terraform.zip
    
    git clone https://github.com/frankscholten/mesos-terraform.git
    cd mesos-terraform
    git checkout af8809ae16b1f0163b3e29ef919f1442ee460b2b
   
    ../terraform plan
    ../terraform apply                   
<!-- deploy-test-end -->

## Deploy Sock Shop

Now deploy Sock Shop

<!-- deploy-test-start create-infrastructure -->
    echo "Deploying Sock Shop...(TODO)"
<!-- deploy-test-end -->

## Runing the load test

The load test will simulate a number of users and test the entire Sock Shop application.

<!-- deploy-test-start run-tests -->
    echo "Running load test...(TODO)"
<!-- deploy-test-end -->

## Cleaning up

Destroy the Mesos cluster and Sock Shop

<!-- deploy-test-start destroy-infrastructure -->
    terraform destroy -force

    aws ec2 delete-key-pair --key-name $(cat private_key_name.txt)
<!-- deploy-test-end -->