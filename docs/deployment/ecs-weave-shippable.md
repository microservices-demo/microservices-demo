---
layout: default
---

## Container-based microservices with AWS, Weave and Shippable


### Goal
In this scenario, you'll set up and run the containerized Socks Shop
eCommerce application, with fully automated deployments, in 30
minutes or less.

Your sample application will feature:
  * **Amazon ECS**{: style="color: orange"} for container orchestration
  * **Amazon ECR**{: style="color: orange"} for container registry
  * **Weave Scope**{: style="color: orange"} for service discovery and container visualization
  * **Shippable**{: style="color: orange"} for automated CI/CD

This page provides the instructions necessary to:
  * Provision a Weave-enabled Amazon ECS cluster using Cloud Formations and
  deploy all components of the Sock Shop microservices demo application except
  the <a href="https://github.com/microservices-demo/front-end" style="color: orange">front-end</a>
   component
  * Configure a CI/CD pipeline to manage deployment of the
  <a href="https://github.com/microservices-demo/front-end" style="color: orange">
  front-end</a> service using Shippable

---
### Fork and clone the repos
To get started, you'll need to fork and clone two GitHub repos.

1. Fork the [microservices-demo](https://github.com/microservices-demo/microservices-demo){: style="color: orange"}
GitHub repo to your personal [GitHub account](https://github.com/join?source=header-home){: style="color: orange"}

2. <p>Clone your fork locally on your machine</p>  
  * Click the green `Clone or download` button
  * Copy the URL for your forked repo that appears
  * Open a command line on your local machine and execute the command:
      <pre>$ git clone <i>your_forked_url</i></pre>

{:start="3"}
3. <p>Repeat steps 1-3 for the <a href="https://github.com/microservices-demo/front-end"
style="color: orange">
front-end</a> repo

---
### Provision Amazon ECS cluster
Now, you'll provision a Weave-enabled Amazon ECS cluster and deploy all services
except for the front-end service.

1. Log into [Amazon Management Console](https://console.aws.amazon.com/console/home){: style="color: orange"}

2. Navigate to [CloudFormation](https://console.aws.amazon.com/cloudformation){: style="color: orange"}

3. Select `Create Stack`

4. Under `Choose a template`, select `Choose file` or `Browse`

5. Navigate to the directory where you cloned the <span style="color: orange">
microservices-demo</span> repo
and choose to upload the file `./deploy/aws-ecs/cloudformation.json`

6. <p>Complete the form fields with the following values and select `Next`</p>
  * Stack name: `ecs-weave-shippable-demo`
  * DeployExampleApp: `Yes`
  * EcsInstanceType: `t2.small`
  * KeyName: `choose an existing key pair or leave blank to create a new one`
  * Scale: `4`
  * WeaveCloudServiceToken: `leave blank`

{:start="7"}
7. Leave all form fields on the `Options` page as-is and select `Next`  

8. Click the `'I acknowledge ...'` boxes at bottom and select `Create`

**CloudFormation**{: style="color: orange"} will now create the entire stack
necessary to run your eCommerce demo app on Amazon ECS. This could several
minutes to complete and it will provision compute on AWS.

When your stack creation finishes with 'CREATE_COMPLETE', you'll find values of
AWS resources needed for the CI/CD pipeline setup available on the `Outputs` tab.

---
### Configure an automated CI/CD pipeline

Your Weave-enabled Amazon ECS cluster should now be running 15 out of the 16 services
of the Socks Shop application (you can see this by navigating to EC2 Container Service).
We'll use Shippable to set up an automated CI/CD pipeline to deploy the
<a href="https://github.com/microservices-demo/front-end" style="color: orange">
front-end</a> service.

1. Create a <a href="https://www.shippable.com" style="color: orange">Shippable</a>
account (if you don't already have one) by logging in with your
GitHub credentials

2. <p>Enable the <span style="color: orange">front-end</span> repo for <span style="color: orange">
CI</span> in Shippable</p>
  * Select your Subscription from the drop-down menu (three horizontal lines)
  in upper left
  * Select `Enable project` in left-hand nav
  * Find the `front-end` repo in the list and select `Enable`

{:start="3"}
3. <p>Create the <span style="color: orange">front-end CD pipeline</span></p>
In your local copy of the microservices-demo repo, you'll need to update
the `shippable.resource.yml` configuration file with values from your AWS environment:
    * Resource `img-front-end`
      * Replace the Amazon ECR registry URL with the URL for your Container registry,  e.g. `288971733297.dkr.ecr.us-east-1.amazonaws.com/front-end`
      * You can copy/paste this URL by selecting `View Push Commands` on
      <a href="https://console.aws.amazon.com/ecs/home#/repositories/front-end#images;tagStatus=ALL" style="color: orange">
      this page</a>
    * Resource `alb-front-end-test`
      * Replace the value for `SourceName` to be the ARN for your Target Group named `frontendTESTTG`
    * Resource `alb-front-end-prod`
      * Replace the value for `SourceName` to be the ARN for your Target Group named `frontendPRODTG`

    If you're running in your cluster in a region other than `us-east-1`:
    * Resource `cluster-demo-ecs`
      * Replace the value for `Region` to be the AWS region where you're
        running your cluster

    Now, load your Pipeline configuration files into Shippable:
    * Select the `Pipelines` tab, `Resources` view, and then `Add Resource` button
  (far right)
    * In the Subscription Integrations dropdown: choose `Add integration` and
  complete the fields, as follows:
      * Name: name your integration `github`
      * Account Integrations: select `github` from the list
      * Projects Permissions: leave as `All projects`
      * Select `Save`
    * Select Project dropdown: choose `microservices-demo` project
    * Select Branch dropdown: choose `master`
    * Select `Save`
    * Select `SPOG` view and verify that your pipeline has been loaded

{:start="4"}
4. <p>Configure an integration between <span style="color: orange">Shippable</span>
 and <span style="color: orange">Amazon ECR</span></p>
  * Navigate to `Account Settings` via the gear icon in the upper right
  * Select `Integrations` tab
  * Select `Add Integration`
    * Select `Amazon ECR` from the list and complete the fields, as follows:
      * Integration Name: name your integration `shippable-ecr`
      * Aws_access_key_id: Login to your AWS Management Console and navigate to the IAM user that contains [shippableDemoUser](https://console.aws.amazon.com/iam/home#users) and
      select `Create Access Key`
      * Copy/paste the Aws_access_key_id and Aws_secret_access_key into the
      Shippable fields (also, keep these values for use in step 5)
      * Select `Save`
  * Now, assign your Account Integration for use by your Subscription
    * Select your Subscription from the dropdown menu in upper left (three
      horizontal lines)
    * Select `Settings` tab, `Integrations` tab, and `Add Integration`
    * Complete the fields with the following values:
      * Name: shippable-ecr
      * Account Integrations: select `shippable-ecr` from the list
      * Project Permissions: leave `All projects` selected
      * Select `Save`

{:start="5"}
5. <p>Configure an integration between <span style="color: orange">Shippable</span>
and <span style="color: orange">Amazon ECS</span></p>
  * Navigate to `Account Settings` via the gear icon in upper right
  * Select `Integrations` tab
  * Select `Add Integration`
    * Select `AWS` from the list
    * Name your integration `shippable-aws`
    * Copy/paste the `Aws_access_key_id` and `Aws_secret_access_key` into the
    Shippable fields (use the same values from step 4 above)
    * Select `Save`
  * Now, assign your Account Integration for use by your Subscription
    * Select your Subscription from the dropdown menu in upper left (three lines)
    * Select `Settings` tab, `Integrations` tab, and `Add Integration`
    * Complete the fields with the following values:
      * Name: shippable-aws
      * Account Integrations: select `shippable-aws` from the list
      * Project Permissions: leave `All projects` selected
      * Select `Save`

{:start="6"}
6. <p>Link <span style="color: orange">CI</span> to your <span style="color: orange">
Pipeline</span> via an <span style="color: orange">Event Trigger</span></p>
  * Navigate to `Account Settings` via the gear icon in upper right
  * Navigate to the 'API tokens' tab, create an API Token, and save it (you'll need
  it again shortly)
  * Select `Integrations` tab
  * Select `Add Integration`
    * Select `Event Trigger` from list
    * Name your integration `trigger-img-front-end`
    * Select `Resource` in the `Select Trigger` dropdown
    * Select the `img-front-end` resource you created in your pipeline
    * In Authorization field, enter 'apiToken ' + your API token from above
    * Select `Save`
  * Now, assign your Account Integration for use by your Subscription
    * Select your Subscription from the dropdown menu in upper left
    * Select `Settings` tab, `Integrations` tab, and `Add Integration`
    * Complete the fields with the following values:
      * Name: trigger-img-front-end
      * Account Integrations: select `trigger-img-front-end` from the list
      * Project Permissions: leave `All projects` selected
      * Select `Save`

{:start="7"}
7. <p>Run CI and trigger deployment of the `front-end` service to the
<span style="color: orange">Test environment</span></p>
  * Select the `CI` tab
  * Select the `Build` button for the `front-end` project
  * View the CI console as your CI run executes
  * Navigate to the `Pipelines` tab and see your Pipeline execute
    * You'll see the CI job run and push a new image to Amazon ECR
    * Then a new Manifest job will run to update with the newest image tag
    * Then a Deploy job will run to deploy to Amazon ECS
  * View your application running in your browser at (enter ALB address and port 8080)

{:start="8"}
8. <p>Deploy to the <span style="color: orange">Prod environment</span></p>
  * Right-click the `ecs-deploy-prod` job and select `Run`
  * A Deploy job will run and deploy a Prod instance of `front-end` to Amazon ECS
  * View your application running in your browser at (enter ALB address)

{:start="9"}
9. <p>Make a change to your front-end service and <span style="color: orange">
auto-deploy to Test environment</span></p>
  * In your editor, open the `public/css/style.blue.css` file in the `front-end` repo
  * Comment out line 1273, and un-comment line 1274 (this will change the color
    of the active tab on the home page from blue to green)
  * Commit your changes to GitHub
  * View the automated CI/CD flow in Pipeline view in Shippable, which will result
  in the code change being deployed to your Test environment
  * In your browser, navigate again to your Test environment (on port 8080) and
  confirm that the change was deployed successfully

{:start="10"}
10. <p>Explore!</p>
  * Navigate to http://{your ALB DNS}:4040 to view the Weave visualization of
  your containerized application
  * Navigate to <a href="https://console.aws.amazon.com/ecs/home#/clusters/ecs-weave-shippable-demo/services" style="color: orange">the
  AWS Management Console</a> and explore the different elements of your cluster in Amazon ECS
  * Navigate to your Amazon ECR repository to view your newly created Docker images
    * Select `Repositories` in the left-hand nav from your cluster page
  * Explore additional elements of your Shippable Pipelines:
    * Select the `Jobs` view in the Pipelines tab and click on the Latest version
    number for the `ecs-deploy-test-front-end` job.
    * For the most recent version, select `More` and `Trace` to see details of the
    elements included in this latest deployment to the Test environment
    * Expand the `man-front-end` Resource Name

---
### Delete your CloudFormation stack
When finished exploring, return to the AWS Management Console - CloudFormation
page, select the `ecs-weave-shippable-demo` stack, select `Actions` and `Delete
Stack` to remove all resources related to this demo.
