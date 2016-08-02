# Pipline POC

This branch represents a quick and dirty pipeline POC.

* DO NOT MERGE THIS BRANCH *

## Reasons for doing this

There are very few tools that both provide pipeline functionality and are flexible to allow us to run our various tests in containers. Jenkins comes the closest, but is overly complex, difficult to script (apparently there's an API now?), static, hard to check into version control and generally not very devops friendly.

I suggested that all I need is the requirements below and some people thought it would be complicated. This aims to show that you can quickly knock something up in bash, in the attempt to squash that fear.

This isn't meant to be used for real and little care has been taken to get it working reliably. This took 4 hours.

## My requirements
- A pipeline
- Helpers to create a suitible environment for larger tests.

## Setup
The pipeline has been intenionally simplified to this:

```
----------------------------------------------------------------
Local: 

|Build|-->|Test|-->|Unit|-->|Component|-->|Push|    |Deploy|
--------------------------------------------|------------|------
Remote:                                     |            |
                                            |            |
                                       |Application|-->|User|
----------------------------------------------------------------
```

If any of the stages fail, it will quit and produce an exit value > 0.

## Implementation
To get going I scripted everything in bash. See [the pipeline script](./pipeline.sh). It's a bit hacky, but I think it's pretty simple to understand. Basically we're sequentially running each testing step, and theres a helper to help me create a testing environment.
 
Other than the general hackiness, the main drawback is the amount of time it takes to provision the AWS EC2 instance. This turns tests that can be run in a matter of seconds (excluding build/pull time) into 10 minutes.

I wouldn't recommend you try this, but if you must, export:

```
eval $(docker-machine env <NAME>)
export TF_VAR_access_key=<AWS_ACCESS_KEY_ID> # e.g. ABADNBVDBVNBVFUQEO6Q
export TF_VAR_secret_key=<AWS_SECRET_ACCESS_KEY> # e.g. L7ffJdcdSGhsbhsfJDBfd74Ta1YDnYhZ68xtj/lv
export TF_VAR_private_key_file=<private ssh key file> # e.g. key.pem
export TF_VAR_aws_key_name=<AWS SSH KEY NAME> # e.g. key
export PATH=$PATH:../../testing
```

Then run:
```
./pipeline.sh
```

## The result

These are the logs produced, trimmed for brevity:

```
Phils-MBP-7:catalogue phil-mac$ ./pipeline.sh
Running tests for "unit"
Ran 1 test in 1.958s
UNIT-YEAH

Running tests for "component"
Ran 1 test in 2.229s
COMPONENT-YEAH
BUILD-YEAH

Pretending to push
PUSH-YEAH

...
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
Outputs:
  # Instance = 
export INSTANCE=ec2-52-209-182-106.eu-west-1.compute.amazonaws.com
  # SSH key  = 
export KEY=/Users/phil-mac/.ssh/keys/AWS/cs-phil.pem
  ZDummy     = 
Dummy
...
Running tests for "container"
Ran 2 tests in 1.256s
CONTAINER-YEAH

Running tests for "application"
Ran 1 test in 3.253s
APPLICATION-YEAH
User test Stub
USER-YEAH

Do you really want to destroy?
  Terraform will delete all your managed infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: no

Destroy cancelled.

DEPLOYING THIS TO STAGING
```
