#!/bin/sh -v
KEYFILE="/home/ubuntu/.ssh/kube_aws_rsa"
MASTERIP=$1

# run init on master
ssh -o StrictHostKeyChecking=no -i $KEYFILE ubuntu@$MASTERIP sudo kubeadm init > kubeadm-init-$MASTERIP.log
ssh -i $KEYFILE ubuntu@$MASTERIP sudo cp /etc/kubernetes/admin.conf ~/config
ssh -i $KEYFILE ubuntu@$MASTERIP sudo chown ubuntu: ~/config
scp -i $KEYFILE ubuntu@$MASTERIP:~/config ~/.kube/

grep -e --token kubeadm-init-$MASTERIP.log > join.cmd

exit 0

