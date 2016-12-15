---
layout: default
deployDoc: false
deploymentScriptDir: "ecs-cli"
---

## Deployment with AWS ECS cli

### Goal

This page describes how to install Sock Shop via the [AWS ECS cli](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI.html).

### Installation

First make sure you have an [AWS](http://aws.amazon.com) account. Then install the `ecs-cli` tool.

<!-- deploy-doc-start pre-install -->

    sudo curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest
    sudo chmod +x /usr/local/bin/ecs-cli

<!-- deploy-doc-end -->

Now you can deploy Sock Shop via `ecs-cli` using the existing Docker Compose file.

<!-- deploy-doc-start create-infrastructure -->

    ecs-cli compose up
    
<!-- deploy-doc-end -->

This may take a few minutes to complete. Once it's done, find out the IP address of the frontend and run the load-test against it

<!-- deploy-doc-start run-tests -->

    TODO Find out frontend IP address and save this in a file
    docker run weaveworksdemos/load-test -d 60 -h `cat deploy/aws-ecs/ecs-endpoint` -c 10 -r 100

<!-- deploy-doc-end -->

### Cleanup

To tear down the containers and their associated AWS objects, run the cleanup script:

<!-- deploy-doc-start destroy-infrastructure -->

    ecs-cli down

<!-- deploy-doc-end -->
