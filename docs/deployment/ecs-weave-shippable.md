# Container-based microservices with AWS, Weave and Shippable

In this scenario, you'll set up and run your own microservices-based,
containerized eCommerce application, with fully automated deployments, in 30
minutes or less.

Your sample application will feature:
  * **Amazon ECS** for container orchestration
  * **Amazon ECR** for container registry
  * **Weave Scope** for service discovery and container visualization
  * **Shippable** for automated CI/CD

This repository contains the source code necessary to:
* Provision a Weave-enabled Amazon ECS cluster using Cloud Formations
* Deploy all components of the Sock Shop microservices demo application created
by Weave.works and Container Solutions, except the 'front-end' component
* Configure a CI/CD pipeline to manage deployment of the 'front-end' component
using Shippable

For additional information on the Sock Shop microservices demo application created
by Weave.works and Container Solutions, see [their demo site on GitHub]
(https://microservices-demo.github.io/).

### Getting Started

To run the demonstration, you'll set up the following:
1. Fork and clone the two repos you'll need:
  * [deploy-pipeline](https://github.com/ecs-weave-shippable-demo/deploy-pipeline)
  * [front-end component](https://github.com/ecs-weave-shippable-demo/front-end)
2. Provision a Weave-enabled Amazon ECS cluster in your AWS account
3. Configure an automated CI/CD pipeline to deploy the 'front-end' component

##### Fork and clone the repos

1. Navigate to [deploy-pipeline](https://github.com/ecs-weave-shippable-demo/deploy-pipeline)
2. Fork it (click 'Fork' in the top right corner) to your personal GitHub account ([create an account](https://github.com/join?source=header-home)
if you don't have one).
3. Clone your fork locally on your machine
  * Click the green "Clone or download" button
  * Copy the URL for your forked repo that appears
  * Go to your local machine and open a command line
  * Execute `git clone {your_forked_url}` at the command line
4. Repeat steps 1-3 for [front-end component](https://github.com/ecs-weave-shippable-demo/front-end)

##### Provision a Weave-enabled Amazon ECS cluster

1. [Log into Amazon Management Console](https://console.aws.amazon.com/console/home)
  * If you do not have an AWS account, create one first
2. Navigate to CloudFormation(https://console.aws.amazon.com/cloudformation)
3. Select 'Create Stack'
4. Under 'Choose a template', select 'Choose file'
5. Navigate to the directory where you cloned the [deploy-pipeline](https://github.com/ecs-weave-shippable-demo/deploy-pipeline) repo
and choose to upload the file '/deploy/aws-ecs/cloudformation.json'
6. Complete the following form fields and select 'Next'
  * Stack name: ecs-weave-shippable-demo
  * DeployExampleApp: No
  * EcsInstanceType: t2.small
  * KeyName: choose an existing key pair or leave blank to create a new one
  * Scale: 4
  * WeaveCloudServiceToken: leave blank
7. Leave all form fields on the 'Options' page as-is and select 'Next'
8. Click the 'I acknowledge ...' box at bottom and select 'Create'

CloudFormation will now create the entire stack necessary to run your eCommerce
demo app on Amazon ECS. This will take several minutes to complete and it will
provision compute on AWS. To offset any charges you may incur, please redeem the
Promo Code provided to you:
  * In the AWS Management Console, select your name in upper right
  * Select 'Billing and Cost Management'
  * Select 'Credit' in the left-hand nav
  * Fill out all form fields to redeem your credit


###
