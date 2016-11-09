# Container-based microservices with AWS, Weave and Shippable

In this scenario, you'll set up and run the containerized Socks Shop
eCommerce application, with fully automated deployments, in 30
minutes or less.

Your sample application will feature:
  * **Amazon ECS** for container orchestration
  * **Amazon ECR** for container registry
  * **Weave Scope** for service discovery and container visualization
  * **Shippable** for automated CI/CD

This page provides the instructions necessary to:
* Provision a Weave-enabled Amazon ECS cluster using Cloud Formations
* Deploy all components of the Sock Shop microservices demo application created
by Weave.works and Container Solutions, except the 'front-end' component
* Configure a CI/CD pipeline to manage deployment of the 'front-end' component
using Shippable

For additional information on the Sock Shop microservices demo application created
by Weave.works and Container Solutions, see [the full description]
(https://microservices-demo.github.io/).

### Getting Started

To run the demonstration, you'll set up the following:
1. Fork and clone the two repos you'll need:
  * [deploy-pipeline](https://github.com/ecs-weave-shippable-demo/deploy-pipeline)
  * [front-end component](https://github.com/ecs-weave-shippable-demo/front-end)

2. Provision a Weave-enabled Amazon ECS cluster in your AWS account

3. Configure an automated CI/CD pipeline to deploy the 'front-end' component

##### Fork and clone the repos

1. Go to the GitHub repo for  [microservices-demo](https://github.com/microservices-demo/microservices-demo)

2. Fork it (click 'Fork' in the top right corner) to your personal GitHub account ([create an account](https://github.com/join?source=header-home)
if you don't have one).

3. Clone your fork locally on your machine
  * Click the green "Clone or download" button
  * Copy the URL for your forked repo that appears
  * Go to your local machine and open a command line
  * Execute `git clone {your_forked_url}` at the command line

4. Repeat steps 1-3 for the [front-end](https://github.com/ecs-weave-shippable-demo/front-end) component

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
  * DeployExampleApp: Yes
  * EcsInstanceType: t2.small
  * KeyName: choose an existing key pair or leave blank to create a new one
  * Scale: 4
  * WeaveCloudServiceToken: leave blank

7. Leave all form fields on the 'Options' page as-is and select 'Next'

8. Click the 'I acknowledge ...' box at bottom and select 'Create'

CloudFormation will now create the entire stack necessary to run your eCommerce
demo app on Amazon ECS. This could several minutes to complete and it will
provision compute on AWS.

##### Configure an automated CI/CD pipeline

Your Weave-enabled cluster is now running 15 out of the 16 services of the Socks
Shop application. We'll use Shippable to set up an automated CI/CD pipeline to
deploy the `front-end` service.

1. Create a Shippable account (if you don't already have one)
  * Go to www.shippable.com
  * Log in using your GitHub account

2. Enable the `front-end` repo for CI in Shippable
  * Select your Subscription from the drop-down menu in upper left
  * Select 'Enable project' in left-hand nav
  * Find the 'front-end' repo in the list and select 'Enable'

3. Create the `front-end` CD pipeline
  * In the microservices-demo repo, you'll need to update the `shippable.resource.yml`
  configuration file with values from your AWS environment:
    * Resource `img-front-end`
      * Replace the Amazon ECR registry URL with the URL for your Container registry,
      e.g. replace the AWS account ID in this URL with your account ID and the
      region, if necessary - '288971733297.dkr.ecr.us-east-1.amazonaws.com/front-end'
      * You can copy/paste this URL by selecting 'View Push Commands' on this page
    * Resource `alb-front-end-test`
      * Replace the value for 'SourceName' to be the ARN for your Target Group named 'frontendTESTTG'
    * Resource `alb-front-end-prod`
      * Replace the value for 'SourceName' to be the ARN for your Target Group named 'frontendPRODTG'
    * If you're running in your cluster in a region other than 'us-east-1':
      * Resource `cluster-demo-ecs`
        * Replace the value for 'Region' to be the AWS region where you're
        running your cluster
  * Select the 'Pipelines' tab, 'Resources' view, and 'Add Resource' button
  (far right)
  * In the Subscription Integrations dropdown: choose 'Add integration' and complete the fields, as follows:
    * Name: name your integration 'github'
    * Account Integrations: select 'github' from the list
    * Projects Permissions: leave as 'All projects'
    * select 'Save'
  * Select Project dropdown: choose 'microservices-demo' project
  * Select Branch dropdown: choose 'master'
  * Select 'Save'
  * Select 'SPOG' view and verify that your pipeline has been loaded

4. Configure an integration between Shippable and Amazon ECR
  * Navigate to 'Account Settings' via the gear icon in the upper right
  * Select 'Integrations' tab
  * Select 'Add Integration'
    * Select 'Amazon ECR' from the list and complete the fields, as follows:
      * Integration Name: name your integration 'shippable-ecr'
      * Aws_access_key_id: Login to your AWS Management Console and navigate to the IAM user that contains [shippableDemoUser](https://console.aws.amazon.com/iam/home#users) and
      select 'Create Access Key'
      * Copy/paste the Aws_access_key_id and Aws_secret_access_key into the
      Shippable fields (also, keep these values for use in step 5)
      * Select 'Save'
  * Now, assign your Account Integration for use by your Subscription
    * Select your Subscription from the dropdown menu in upper left (three lines)
    * Select 'Settings' tab, 'Integrations' tab, and 'Add Integration'
    * Complete the fields with the following values:
      * Name: shippable-ecr
      * Account Integrations: select 'shippable-ecr' from the list
      * Project Permissions: leave 'All projects' selected
      * Select 'Save'

5. Configure an integration between Shippable and Amazon ECS
  * Navigate to 'Account Settings' via the gear icon in upper right
  * Select 'Integrations' tab
  * Select 'Add Integration'
    * Select 'AWS' from the list
    * Name your integration 'shippable-aws'
    * Copy/paste the Aws_access_key_id and Aws_secret_access_key into the
    Shippable fields (use the same values from step 4 above)
    * Select 'Save'
  * Now, assign your Account Integration for use by your Subscription
    * Select your Subscription from the dropdown menu in upper left (three lines)
    * Select 'Settings' tab, 'Integrations' tab, and 'Add Integration'
    * Complete the fields with the following values:
      * Name: shippable-aws
      * Account Integrations: select 'shippable-aws' from the list
      * Project Permissions: leave 'All projects' selected
      * Select 'Save'

5. Link CI to your Pipeline via an Event Trigger
  * Navigate to 'Account Settings' via the gear icon in upper right
  * Select 'Integrations' tab
  * Select 'Add Integration'
    * Select 'Event Trigger' from list
    * Name your integration 'trigger-img-front-end'
    * Select 'Save'
  * Now, assign your Account Integration for use by your Subscription
    * Select your Subscription from the dropdown menu in upper left
    * Select 'Settings' tab, 'Integrations' tab, and 'Add Integration'
    * Complete the fields with the following values:
      * Name: trigger-img-front-end
      * Account Integrations: select 'trigger-img-front-end' from the list
      * Project Permissions: leave 'All projects' selected
      * Select 'Save'

6. Run CI and trigger deployment of the 'front-end' service to the Test environment
  * Select the 'CI' tab
  * Select the 'Build' button for the 'front-end' project
  * View the CI console as your CI run executes
  * Navigate to the 'Pipelines' tab and see your Pipeline execute
    * You'll see the CI job run and push a new image to Amazon ECR
    * Then a new Manifest job will run to update with the newest image tag
    * Then a Deploy job will run to deploy to Amazon ECS
  * View your application running in your browser at (enter ALB address and port 8080)

7. Deploy to the Prod environment
  * Right-click the 'ecs-deploy-prod' job and select 'Run'
  * A Deploy job will run and deploy a Prod instance of 'front-end' to Amazon ECS
  * View your application running in your browser at (enter ALB address (port 80))

8. Make a change to your front-end service and auto-deploy to Test environment
  * In your editor, open the `public/css/style.blue.css` file in the `front-end` repo
  * Comment out line 1273, and un-comment line 1274 (this will change the color
    of the active tab on the home page from blue to green)
  * Commit your changes to GitHub
  * View the automated CI/CD flow in Pipeline view in Shippable, which will result
  in the code change being deployed to your Test environment
  * In your browser, navigate again to your Test environment (on port 8080) and
  confirm that the change was deployed successfully

9. Explore!
  * Navigate to http://{your ALB DNS}:4040 to view the Weave visualization of
  your containerized application
  * Navigate to https://console.aws.amazon.com/ecs/home#/clusters/ecs-weave-shippable-demo/services and explore the different elements of your cluster in Amazon ECS
  * Navigate to your Amazon ECR repository to view your newly created Docker images
    * Select 'Repositories' in the left-hand nav from your cluster page
  * Explore additional elements of your Shippable Pipelines:
    * Select the 'Jobs' view in the Pipelines tab and click on the Latest version
    number for the `ecs-deploy-test-front-end` job.
    * For the most recent version, select 'More' and 'Trace' to see details of the
    elements included in this latest deployment to the Test environment
    * Expand the `man-front-end` Resource Name

10. When finished exploring, return to the AWS Management Console - CloudFormation
page, select the 'ecs-weave-shippable-demo' stack, select 'Actions' and 'Delete
Stack' to remove all resources related to this demo.
