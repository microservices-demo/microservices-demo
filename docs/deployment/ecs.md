---
layout: default
deployDoc: true
deploymentScriptDir: "aws-ecs"
---

## Deployment on Amazon EC/2 Container Service

<!-- deploy-doc require-env AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION -->

<!-- deploy-doc-hidden pre-install

    mkdir -p ~/.ssh/
    curl -sSL https://get.docker.com/ | sh
    apt-get install -yq curl jq python-pip unzip build-essential python-dev
    pip install awscli

-->

### Goal

This directory contains the necessary tools to install an instance of the microservice demo application on [AWS ECS](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html).

### Installation

To deploy, you will need an [Amazon Web Services (AWS)](http://aws.amazon.com) account.

#### Using CloudFormation

[![](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/new?templateURL=https:%2F%2Fs3.amazonaws.com%2Fweaveworks-cfn-public%2Fmicroservices-demo%2Fmicroservices-demo.json)

By clicking "Launch Stack" button above, you will get redirected to AWS CloudFormation console. You will be asked to set cluster size (***`Scale`***) and instance type (***`EcsInstanceType`***).

### Using CLI

To use CLI, you also need to have the [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html) set up and configured.

Other required packages are:
[jq](https://stedolan.github.io/jq/)
[docker](https://docs.docker.com/engine/getstarted/step_one/)


<!-- deploy-doc-start create-infrastructure -->

    cd deploy/aws-ecs/
    ./msdemo-cli build

<!-- deploy-doc-end -->


This may take a few minutes to complete. Once it's done, it will print the URL for the demo frontend, as well as the URL for the Weave Scope instance that can be used to visualize the containers and their connections.

To ensure that the application is running properly, you could perform some load testing on it:

<!-- deploy-doc-start run-tests -->

    cd deploy/aws-ecs/
    ./msdemo-cli loadtest

<!-- deploy-doc-end -->

<!-- deploy-doc-hidden run-tests

    pem=microservices-demo-key
    chmod 600 -R ~/.ssh/
    instance=$(aws ec2 describe-instances -\-filter "Name=key-name,Values=microservices-demo-key" "Name=instance-state-name,Values=running" | jq -r ".Reservations[0].Instances[0].PublicIpAddress")

    cat >> /root/healthcheck.sh <<-EOF
#!/usr/bin/env bash
eval \$(weave env)
docker build -t healthcheck -f Dockerfile-healthcheck .
docker run -\-rm -t healthcheck -s user,catalogue,cart,shipping,payment,orders,queue-master -d 180 -r 5
EOF

    scp -i ~/.ssh/$pem.pem -o "StrictHostKeyChecking no" /root/healthcheck.sh deploy/healthcheck.rb deploy/Dockerfile-healthcheck ec2-user@$instance:/home/ec2-user/
    ssh -i ~/.ssh/$pem.pem ec2-user@$instance "chmod +x healthcheck.sh; ./healthcheck.sh"

    if [ $? -ne 0 ]; then
        exit 1;
    fi
-->

### Opentracing

Zipkin is part of the deployment and has been written into some of the services.  While the system is up you can view the traces.
To get the endpoint for Zipkin you can run 

./msdemo dns

Currently orders provide the most comprehensive traces.

#### Cleanup

To tear down the containers and their associated AWS objects, run the cleanup script:

<!-- deploy-doc-start destroy-infrastructure -->

    cd deploy/aws-ecs/
    ./msdemo-cli destroy

<!-- deploy-doc-end -->

#### ms-demo Commands

##### build
Builds the deployment using cloud formation

##### destroy
Destroys the deployment

##### status
Get status of deployment, will throw error if deployment was already destroyed

##### dns
Get DNS endpoint

##### loadtest
Run loadtest
