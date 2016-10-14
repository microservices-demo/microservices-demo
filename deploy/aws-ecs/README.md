# Setup and Installation on AWS ECS

## Goal

This directory contains the necessary tools to install an instance of the microservice demo application on [AWS ECS](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html).

## Installation

To deploy, you will need an [Amazon Web Services (AWS)](http://aws.amazon.com) account.

### Using CloudFormation

[![](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/new?templateURL=https:%2F%2Fs3.amazonaws.com%2Fweaveworks-cfn-public%2Fmicroservices-demo%2Fmicroservices-demo.json)

By clicking "Launch Stack" button above, you will get redirected to AWS CloudFormation console. You will be asked to set cluster size (***`Scale`***) and instance type (***`EcsInstanceType`***).

As this app is fairly large, you should set ***`Scale`*** to 4 and select `m3.xlarge` for ***`EcsInstanceType`***.

### Using CLI

To use CLI, you also need to have the [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html) set up and configured.

#### Setup

To deploy and start the demo, run the setup script to deploy to ECS:

    ./setup.sh

This may take a few minutes to complete. Once it's done, it will print the URL for the demo frontend, as well as the URL for the Weave Scope instance that can be used to visualize the containers and their connections.

#### Cleanup

To tear down the containers and their associated AWS objects, run the cleanup script:

    ./cleanup.sh


#### Background

This flow is based on the Weaveworks guide ["The Fastest Path to Docker on ECS: Microservice Deployment on Amazon EC2 Container Service with Weave Net"](https://www.weave.works/guides/service-discovery-and-load-balancing-with-weave-on-amazon-ecs-2/). The guide is accompanied by a sample project with installation scripts, found at [github.com/weaveworks/guides/aws-ecs](https://github.com/weaveworks/guides/tree/master/aws-ecs).

The `setup.sh` and `cleanup.sh` scripts were taken from that repository and modified for the microservice demo application.
This involved several steps, as detailed below.

#### AWS ECS Task Definitions

[AWS ECS](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html) expects to be provided with a set of [task definitions](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_defintions.html), which describe how the various containers should be scheduled. Each task definition may include several container definitions (up to 10), which is meant to be used for scheduling tightly coupled containers. Our containers are loosely coupled by design (and we have more than 10 in any case), so we create a separate task definition for each container.

To create those task definitions, the Docker Compose file at [docker-swarm/docker-compose.yml](../docker-swarm/docker-compose.yml) was used as a starting point. It was converted to the ECS format with the [container-transform](https://github.com/micahhausler/container-transform) tool. Afterwards, a few manual adaptations were made to add the missing `memory` setting for each container, and to split the container definitions into [separate JSON files](task-definitions), one for every ECS task definition.

#### Adapting the Scripts

The `setup.sh` and `cleanup.sh` from the reference repository set up everything necessary to deploy a pair of containers with a single task definition. They were modified to create a task definition for each container, along with an [ECS Service](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html) scaled to a single instance of each container.
