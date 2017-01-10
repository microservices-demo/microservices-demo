#!/bin/bash

set -euo pipefail

SCOPE_TOKEN=${1:-}
STORE_DNS_NAME_HERE=${STORE_DNS_NAME_HERE:-}

# Find the container instance where the frontend is running
frontend_task=$(aws ecs list-tasks --cluster weave-ecs-demo-cluster --service-name weavedemo-edge-router-service  --query 'taskArns[0]' --output text)
container_inst=$(aws ecs describe-tasks --cluster weave-ecs-demo-cluster --tasks $frontend_task --query 'tasks[0].containerInstanceArn' --output text)
instance_id=$(aws ecs describe-container-instances --cluster weave-ecs-demo-cluster --container-instances $container_inst --query 'containerInstances[0].ec2InstanceId'  --output text)
dns_name=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[*].PublicDnsName' --output text)

# Print information for the user

echo "Setup is ready!"
echo
echo "Open your browser and go to this URL to view the demo:"
echo "  http://$dns_name/"
echo
if [ -z $SCOPE_TOKEN ]; then
    echo "To view the Weave Scope for the demo, go to this URL:"
    echo "  http://${dns_name}:4040/"
else
    echo "To view the Weave Scope for the demo, go to cloud.weave.works"
fi

# And store it in a file, if requested.
if [ "x$STORE_DNS_NAME_HERE" != "x" ]; then
  echo "$dns_name" > $STORE_DNS_NAME_HERE
fi
