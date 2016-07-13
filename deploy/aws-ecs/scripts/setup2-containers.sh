#!/bin/bash

set -euo pipefail

# Task definitions
echo -n "Registering ECS Task Definitions..."
for td in task-definitions/*.json
do
    aws ecs register-task-definition --cli-input-json file://$td > /dev/null
done
echo "done"

# Services
echo -n "Creating ECS Services for task definitions..."
for td in task-definitions/*.json
do
    td_name=$(jq .family $td | tr -d '"')

    # To see what's wrong with a service:
    # aws ecs describe-services --cluster weave-ecs-demo-cluster --services weavedemo-cart-db-service |jq '.services[0].events'|grep 'was unable'

    aws ecs create-service \
        --cluster weave-ecs-demo-cluster \
        --service-name ${td_name}-service \
        --task-definition $td_name \
        --desired-count 1 >/dev/null
done
echo "done"

# Wait for tasks to start running
echo -n "Waiting for tasks to start running .. "
count=$(echo task-definitions/*.json |wc -w)
while [ "$(aws ecs describe-clusters --clusters weave-ecs-demo-cluster --query 'clusters[0].runningTasksCount')" -ne $count ]
do
    echo "Not done yet..."
    sleep 2
done
echo "done"
