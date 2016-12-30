#!/usr/bin/env bash

echo "Terminating load balancers..."
aws elb delete-load-balancer --load-balancer-name md-k8s-elb-sock-shop &>/dev/null

instances=$(aws ec2 describe-instances --filter "Name=tag:Name,Values=md-k8s-master,md-k8s-node" "Name=instance-state-name,Values=pending,running" | jq -r '.Reservations[].Instances[].InstanceId')
echo 'Terminating instances...'
aws ec2 terminate-instances --instance-ids $instances &>/dev/null

if [ "$instances" != "" ]; then
    echo 'Waiting for instances to terminate...'
    aws ec2 wait instance-terminated --instance-ids $instances &>/dev/null
fi

echo 'Terminating security group...'
aws ec2 delete-security-group --group-name md-k8s-security-group 

echo 'Terminating key...'
aws ec2 delete-key-pair --key-name microservices-demo-flux &>/dev/null
