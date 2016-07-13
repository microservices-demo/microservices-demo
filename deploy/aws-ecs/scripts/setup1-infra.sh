#!/bin/bash

# Load the latest WEAVE AMIs
WEAVE_ECS_AMIS=( $(curl -L -s https://raw.githubusercontent.com/weaveworks/integrations/master/aws/ecs/README.md | sed -n -e 's/^| *\([^| ]*\) *| *\(ami-[^| ]*\) *|$/\1:\2/p' ) )

SCOPE_AAS_PROBE_TOKEN="$1"

function usage(){
    echo "usage: $(basename $0) [scope-aas-probe-token]"
    echo "  where [scope-aas-probe-token] is an optional Scope as a Service probe token."
    echo "  When provided, the Scope probes in your ECS instances will report to your app"
    echo "  at http://scope.weave.works/"
}

# Mimic associative arrays using ":" to compose keys and values,
# to make them work in bash v3
function key(){
    echo  ${1%%:*}
}

function value(){
    echo  ${1#*:}
}

# Access is O(N) but .. we are mimicking maps with arrays
function get(){
    KEY=$1
    shift
    for I in $@; do
	if [ $(key $I) = "$KEY" ]; then
	    echo $(value $I)
	    return
	fi
    done
}

REGIONS=""
for I in ${WEAVE_ECS_AMIS[@]}; do
    REGIONS="$REGIONS $(key $I)"
done

# Check that we have everything we need

if [ \( "$#" -gt 1 \) -o  \( "$1" = "--help" \) ]; then
    usage
    exit 1
fi

if [ -z "$(which aws)" ]; then
    echo "error: Cannot find AWS-CLI, please make sure it's installed"
    exit 1
fi

REGION=$(aws configure list 2> /dev/null | grep region | awk '{ print $2 }')
if [ -z "$REGION" ]; then
    echo "error: Region not set, please make sure to run 'aws configure'"
    exit 1
fi

AMI="$(get $REGION ${WEAVE_ECS_AMIS[@]})"
if [ -z "$AMI" ]; then
    echo "error: AWS-CLI is using '$REGION', which doesn't offer ECS yet, please set it to one from: ${REGIONS}"
    exit 1
fi

# Check that setup wasn't already run
CLUSTER_STATUS=$(aws ecs describe-clusters --clusters weave-ecs-demo-cluster --query 'clusters[0].status' --output text)
if [ "$CLUSTER_STATUS" != "None" -a "$CLUSTER_STATUS" != "INACTIVE" ]; then
    echo "error: ECS cluster weave-ecs-demo-cluster is active, run cleanup.sh first"
    exit 1
fi    


set -euo pipefail

# Cluster
echo -n "Creating ECS cluster (weave-ecs-demo-cluster) .. "
aws ecs create-cluster --cluster-name weave-ecs-demo-cluster > /dev/null
echo "done"

# VPC
echo -n "Creating VPC (weave-ecs-demo-vpc) .. "
VPC_ID=$(aws ec2 create-vpc --cidr-block 172.31.0.0/28 --query 'Vpc.VpcId' --output text)
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames
# tag it for later deletion
aws ec2 create-tags --resources $VPC_ID --tag Key=Name,Value=weave-ecs-demo-vpc
echo "done"

# Subnet
echo -n "Creating Subnet (weave-ecs-demo-subnet) .. "
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 172.31.0.0/28 --query 'Subnet.SubnetId' --output text)
# tag it for later deletion
aws ec2 create-tags --resources $SUBNET_ID --tag Key=Name,Value=weave-ecs-demo-subnet
echo "done"

# Internet Gateway
echo -n "Creating Internet Gateway (weave-ecs-demo) .. "
GW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
# tag it for later deletion
aws ec2 create-tags --resources $GW_ID --tag Key=Name,Value=weave-ecs-demo
aws ec2 attach-internet-gateway --internet-gateway-id $GW_ID --vpc-id $VPC_ID
TABLE_ID=$(aws ec2 describe-route-tables --query 'RouteTables[?VpcId==`'$VPC_ID'`].RouteTableId' --output text)
aws ec2 create-route --route-table-id $TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $GW_ID > /dev/null
echo "done"

# Security group
echo -n "Creating Security Group (weave-ecs-demo) .. "
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name weave-ecs-demo --vpc-id $VPC_ID --description 'Weave ECS Demo' --query 'GroupId' --output text)
# Wait for the group to get associated with the VPC
sleep 5
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 4040 --cidr 0.0.0.0/0
# Weave
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 6783 --source-group $SECURITY_GROUP_ID
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol udp --port 6783 --source-group $SECURITY_GROUP_ID
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol udp --port 6784 --source-group $SECURITY_GROUP_ID
# Scope
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 4040 --source-group $SECURITY_GROUP_ID
echo "done"

# Key pair
echo -n "Creating Key Pair (weave-ecs-demo, file weave-ecs-demo-key.pem) .. "
aws ec2 create-key-pair --key-name weave-ecs-demo-key --query 'KeyMaterial' --output text > weave-ecs-demo-key.pem
chmod 600 weave-ecs-demo-key.pem
echo "done"

# IAM role
echo -n "Creating IAM role (weave-ecs-role) .. "
aws iam create-role --role-name weave-ecs-role --assume-role-policy-document file://data/weave-ecs-role.json > /dev/null
aws iam put-role-policy --role-name weave-ecs-role --policy-name weave-ecs-policy --policy-document file://data/weave-ecs-policy.json
aws iam create-instance-profile --instance-profile-name weave-ecs-instance-profile > /dev/null
# Wait for the instance profile to be ready, otherwise we get an error when trying to use it
while ! aws iam get-instance-profile --instance-profile-name weave-ecs-instance-profile  2>&1 > /dev/null; do
    sleep 2
done
aws iam add-role-to-instance-profile --instance-profile-name weave-ecs-instance-profile --role-name weave-ecs-role
echo "done"

# Launch configuration
echo -n "Creating Launch Configuration (weave-ecs-launch-configuration) .. "
# Wait for the role to be ready, otherwise we get:
# A client error (ValidationError) occurred when calling the CreateLaunchConfiguration operation: You are not authorized to perform this operation.
# Unfortunately even if you can list the profile, "aws autoscaling create-launch-configuration" barks about it not existing so lets sleep instead
# while [ "$(aws iam list-instance-profiles-for-role --role-name weave-ecs-role --query 'InstanceProfiles[?InstanceProfileName==`weave-ecs-instance-profile`].InstanceProfileName' --output text 2>/dev/null || true)" !=  weave-ecs-instance-profile ]; do
#    sleep 2
# done
sleep 15

TMP_USER_DATA_FILE=$(mktemp /tmp/weave-ecs-demo-user-data-XXXX)
trap 'rm $TMP_USER_DATA_FILE' EXIT
cp data/set-ecs-cluster-name.sh $TMP_USER_DATA_FILE
if [ -n "$SCOPE_AAS_PROBE_TOKEN" ]; then
    echo "echo SERVICE_TOKEN=$SCOPE_AAS_PROBE_TOKEN >> /etc/weave/scope.config" >> $TMP_USER_DATA_FILE
fi
aws autoscaling create-launch-configuration --image-id $AMI --launch-configuration-name weave-ecs-launch-configuration --key-name weave-ecs-demo-key --security-groups $SECURITY_GROUP_ID --instance-type t2.small --user-data file://$TMP_USER_DATA_FILE  --iam-instance-profile weave-ecs-instance-profile --associate-public-ip-address --instance-monitoring Enabled=false
echo "done"

# Auto Scaling Group
scale=3
echo -n "Creating Auto Scaling Group (weave-ecs-demo-group) with $scale instances .. "
aws autoscaling create-auto-scaling-group --auto-scaling-group-name weave-ecs-demo-group --launch-configuration-name weave-ecs-launch-configuration --min-size $scale --max-size $scale --desired-capacity $scale --vpc-zone-identifier $SUBNET_ID

# Useful to test peer-discovery using the weave:peerGroupName tag instead of Autoscaling-group-membership.
#aws autoscaling create-or-update-tags --tags "ResourceId=weave-ecs-demo-group,ResourceType=auto-scaling-group,Key=weave:peerGroupName,Value=test,PropagateAtLaunch=true"
echo "done"

# Wait for instances to join the cluster
echo -n "Waiting for instances to join the cluster (this may take a few minutes) .. "
while [ "$(aws ecs describe-clusters --clusters weave-ecs-demo-cluster --query 'clusters[0].registeredContainerInstancesCount' --output text)" != $scale ]; do
    sleep 2
done
echo "done"
