#!/bin/bash

# Check that we have everything we need

if [ -z "$(which aws)" ]; then
    echo "error: Cannot find AWS-CLI, please make sure it's installed"
    exit 1
fi

REGION=$(aws configure list 2> /dev/null | grep region | awk '{ print $2 }')
if [ -z "$REGION" ]; then
    echo "error: Region not set, please make sure to run 'aws configure'"
    exit 1
fi

if [ -n "$(aws ecs describe-clusters --clusters weave-ecs-demo-cluster --query 'failures' --output text)" ]; then
    echo "error: ECS cluster weave-ecs-demo-cluster doesn't exist, nothing to clean up"
    exit 1
fi

# Delete service
echo -n "Deleting ECS Service (weave-ecs-demo-service) .. "
aws ecs update-service --cluster weave-ecs-demo-cluster --service  weave-ecs-demo-service --desired-count 0 > /dev/null
aws ecs delete-service --cluster weave-ecs-demo-cluster --service  weave-ecs-demo-service > /dev/null
echo "done"

# Task definition
echo -n "De-registering ECS Task Definition (weave-ecs-demo-task) .. "
REVISION=$(aws ecs describe-task-definition --task-definition weave-ecs-demo-task --query 'taskDefinition.revision' --output text)
aws ecs deregister-task-definition --task-definition "weave-ecs-demo-task:${REVISION}" > /dev/null
echo "done"
