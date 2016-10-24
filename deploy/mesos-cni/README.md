<!-- deploy-test require-env TF_VAR_access_key TF_VAR_secret_key -->

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
    sudo pip install awscli --ignore-installed six
    echo "Installing prerequisites...(TODO)"
<!-- deploy-test-end -->

## Create the infrastructure

Run Terraform to create the Mesos cluster

<!-- deploy-test-start create-infrastructure -->
    echo "Creating infrastructure...(TODO)"
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
    echo "Cleaning up infrastructure...(TODO)"
<!-- deploy-test-end -->