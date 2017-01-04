---
layout: default
deployDoc: false
deploymentScriptDir: "ecs-cli"
---

## Deployment with AWS ECS cli

### Goal

This page describes how to install Sock Shop via the AWS ECS cli.

### Pre-requisites

* [AWS Account](https://aws.amazon.com/)
* [ECS permission for the AWS account](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/IAMPolicyExamples.html)
* [ecs-cli](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html)
* *Optional* [awscli](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)

### Installation

First make sure you have an [AWS](http://aws.amazon.com) account. Then install the `ecs-cli` tool. Depending on what platform you might need to change the
link to reflect your own platform.

<!-- deploy-doc require-env AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_REGION -->
<!-- deploy-doc-start pre-install -->

    sudo curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest
    sudo chmod +x /usr/local/bin/ecs-cli
    ecs-cli configure sockshop-ecs-cli

<!-- deploy-doc-end -->

Before doing the deploy please make sure that the correct permissions ECS permissions are set on your AWS account and that you
have the following environment variables exported : AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION.

#### Create AWS key

If you don't have a SSH key pair created yet, you can create one:

<!-- deploy-doc-start create-infrastructure -->

aws ec2 create-key-pair --key-name demo-sockshop-ecs --query 'KeyMaterial' --output text > ~/.ssh/demo-sockshop-ecs.pem
chmod 600 ~/.ssh/demo-sockshop-ecs.pem

<!-- deploy-doc-end -->

### Deploy Sock Shop

Now you can deploy Sock Shop via `ecs-cli` using the existing Docker Compose file.

<!-- deploy-doc-start create-infrastructure -->

    ecs-cli up --capability-iam --keypair demo-sockshop-ecs
    curl https://raw.githubusercontent.com/microservices-demo/microservices-demo/master/deploy/docker-compose/docker-compose.yml
    ecs-cli compose --file backend.yml up
    ecs-cli compose --file frontend.yml up
    
<!-- deploy-doc-end -->

This may take a few minutes to complete. Once it's done, find out the IP address of the frontend and run the load-test against it

<!-- deploy-doc-start run-tests -->

    TODO Find out frontend IP address and save this in a file
    docker run weaveworksdemos/load-test -d 60 -h `cat deploy/aws-ecs/ecs-endpoint` -c 10 -r 100

<!-- deploy-doc-end -->

### Cleanup

To tear down the containers and their associated AWS objects, run the cleanup script:

<!-- deploy-doc-start destroy-infrastructure -->

    ecs-cli down --force
    aws ec2 delete-key-pair -\-key-name demo-sockshop-ecs
    rm ~/.ssh/demo-sockshop-ecs.pem

<!-- deploy-doc-end -->
