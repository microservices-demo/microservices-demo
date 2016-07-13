#!/bin/bash

# Auto Scaling Group
echo -n "Deleting Auto Scaling Group (weave-ecs-demo-group) .. "
# Save Auto Scaling Group instances to wait for them to terminate
INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names weave-ecs-demo-group --query 'AutoScalingGroups[0].Instances[*].InstanceId' --output text)
aws autoscaling delete-auto-scaling-group --force-delete --auto-scaling-group-name weave-ecs-demo-group
echo "done"

# Wait for instances to terminate
echo -n "Waiting for instances to terminate (this may take a few minutes) .. "
STATE="foo"
while [ -n "$STATE" -a "$STATE" != "terminated terminated terminated" ]; do
    STATE=$(aws ec2 describe-instances --instance-ids ${INSTANCE_IDS} --query 'Reservations[0].Instances[*].State.Name' --output text)
    # Remove spacing
    STATE=$(echo $STATE)
    sleep 2
done
echo "done"

# Launch configuration
echo -n "Deleting Launch Configuration (weave-ecs-launch-configuration) .. "
aws autoscaling delete-launch-configuration --launch-configuration-name weave-ecs-launch-configuration
echo "done"

# IAM role
echo -n "Deleting weave-ecs-role IAM role (weave-ecs-role) .. "
aws iam remove-role-from-instance-profile --instance-profile-name weave-ecs-instance-profile --role-name weave-ecs-role
aws iam delete-instance-profile --instance-profile-name weave-ecs-instance-profile
aws iam delete-role-policy --role-name weave-ecs-role --policy-name weave-ecs-policy
aws iam delete-role --role-name weave-ecs-role
echo "done"


# Key pair
echo -n "Deleting Key Pair (weave-ecs-demo-key, deleting file weave-ecs-demo-key.pem) .. "
aws ec2 delete-key-pair --key-name weave-ecs-demo-key
rm -f weave-ecs-demo-key.pem
echo "done"

# Security group
echo -n "Deleting Security Group (weave-ecs-demo) .. "
GROUP_ID=$(aws ec2 describe-security-groups --query 'SecurityGroups[?GroupName==`weave-ecs-demo`].GroupId' --output text)
aws ec2 delete-security-group --group-id "$GROUP_ID"
echo "done"

# Internet Gateway
echo -n "Deleting Internet gateway .. "
VPC_ID=$(aws ec2 describe-tags --filters Name=resource-type,Values=vpc,Name=tag:Name,Values=weave-ecs-demo-vpc --query 'Tags[0].ResourceId' --output text)
GW_ID=$(aws ec2 describe-tags --filters Name=resource-type,Values=internet-gateway,Name=tag:Name,Values=weave-ecs-demo --query 'Tags[0].ResourceId' --output text)
aws ec2 detach-internet-gateway --internet-gateway-id $GW_ID --vpc-id $VPC_ID
aws ec2 delete-internet-gateway --internet-gateway-id $GW_ID
echo "done"

# Subnet
echo -n "Deleting Subnet (weave-ecs-demo-subnet) .. "
SUBNET_ID=$(aws ec2 describe-tags --filters Name=resource-type,Values=subnet,Name=tag:Name,Values=weave-ecs-demo-subnet --query 'Tags[0].ResourceId' --output text)
aws ec2 delete-subnet --subnet-id $SUBNET_ID
echo "done"

# VPC
echo -n "Deleting VPC (weave-ecs-demo-vpc) .. "
aws ec2 delete-vpc --vpc-id $VPC_ID
echo "done"

# Cluster
echo -n "Deleting ECS cluster (weave-ecs-demo-cluster) .. "
aws ecs delete-cluster --cluster weave-ecs-demo-cluster > /dev/null
echo "done"
