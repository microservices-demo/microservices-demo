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

# Delete services
echo -n "Deleting ECS Services..."
for td in task-definitions/*.json
do
    td_name=$(jq .family $td | tr -d '"')
    aws ecs update-service --cluster weave-ecs-demo-cluster --service ${td_name}-service --desired-count 0 >/dev/null
    aws ecs delete-service --cluster weave-ecs-demo-cluster --service ${td_name}-service >/dev/null
done
echo "done"

# Delete task definitions
echo -n "De-registering ECS Task Definitions..."
for td in task-definitions/*.json
do
    td_name=$(jq .family $td | tr -d '"')
    revision=$(aws ecs describe-task-definition --task-definition $td_name --query 'taskDefinition.revision' --output text)
    while [ $revision -ge 1 ]
    do
        aws ecs deregister-task-definition --task-definition "${td_name}:${revision}" > /dev/null
        revision=$(expr $revision - 1)
        if [ $revision -eq 0 ]; then break; fi
    done
done
echo "done"
