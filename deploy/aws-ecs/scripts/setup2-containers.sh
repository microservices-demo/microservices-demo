#!/bin/bash

set -euo pipefail

# Task definition
echo -n "Registering ECS Task Definition (weave-ecs-demo-task) .. "
aws ecs register-task-definition --family weave-ecs-demo-task --container-definitions "$(cat data/weave-ecs-demo-containers.json)" > /dev/null
echo "done"

# Service
echo -n "Creating ECS Service with 3 tasks (weave-ecs-demo-service) .. "
aws ecs create-service --cluster weave-ecs-demo-cluster --service-name  weave-ecs-demo-service --task-definition weave-ecs-demo-task --desired-count 3 > /dev/null
echo "done"

# Wait for tasks to start running
echo -n "Waiting for tasks to start running .. "
while [ "$(aws ecs describe-clusters --clusters weave-ecs-demo-cluster --query 'clusters[0].runningTasksCount')" != 3 ]; do
    sleep 2
done
echo "done"
