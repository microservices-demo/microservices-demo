#!/bin/sh -v
KEYFILE="home/ubuntu/.ssh/kube_aws_rsa"
NODEIP=$1

# run init on master
ssh -o StrictHostKeyChecking=no -i $HOME/.ssh/kube_aws_rsa ubuntu@$NODEIP sudo `cat join.cmd` > kubeadm-$NODEIP.log

exit 0
