#!/usr/bin/env bash
set -x

ARGS="$@"
COMMAND="${1}"
SCRIPT_NAME=`basename "$0"`
SCRIPT_DIR=`dirname "$0"`

USER=ubuntu
HOSTS=($MASTER $SLAVE0 $SLAVE1 $SLAVE2)

#
#for HOST in $HOSTS
#do
#    scp -i $KEY $SCRIPT_DIR/provisionWeaveCNI.sh $USER@$HOST:~;
#    ssh -i $KEY $USER@$HOST ./provisionWeaveCNI.sh;
#done;

#for HOST in ${HOSTS[*]}
#do
#    scp -i $KEY $SCRIPT_DIR/provisionMesosDns.sh $USER@$HOST:~;
#    ssh -i $KEY $USER@$HOST ./provisionMesosDns.sh provision $MASTER;
#done;
#
#ssh -i $KEY $USER@${HOSTS[1]} ./provisionMesosDns.sh launch $MASTER;



ssh -i $KEY $USER@$MASTER sudo mesos-execute --command='--logging.level.works.weave=DEBUG' --docker_image=weaveworksdemos/catalogue --master=$MASTER:5050 --name=catalogue --networks=weave --no-shell &
ssh -i $KEY $USER@$MASTER sudo mesos-execute --command='--logging.level.works.weave=DEBUG' --docker_image=weaveworksdemos/front-end --master=$MASTER:5050 --name=front-end --networks=weave --no-shell &
ssh -i $KEY $USER@$MASTER sudo mesos-execute --command='--logging.level.works.weave=DEBUG' --docker_image=weaveworksdemos/edge-router --master=$MASTER:5050 --name=edge-router --networks=weave --no-shell &