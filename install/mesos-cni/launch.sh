#!/usr/bin/env bash
set -x

ARGS="$@"
COMMAND="${1}"
SCRIPT_NAME=`basename "$0"`
SCRIPT_DIR=`dirname "$0"`

USER=ubuntu
MASTERS=($MASTER)
AGENTS=($SLAVE0 $SLAVE1 $SLAVE2)
SSH_OPTS=-oStrictHostKeyChecking=no

# Provision Weave CNI
for HOST in ${MASTERS[*]}
do
    echo "Provisioning Weave CNI on $HOST"
    scp $SSH_OPTS -i $KEY $SCRIPT_DIR/provisionWeaveCNI.sh $USER@$HOST:~;
    ssh $SSH_OPTS -i $KEY $USER@$HOST ./provisionWeaveCNI.sh;
done;

for HOST in ${AGENTS[*]}
do
    echo "Provisioning Weave CNI on $HOST"
    scp $SSH_OPTS -i $KEY $SCRIPT_DIR/provisionWeaveCNI.sh $USER@$HOST:~;
    ssh $SSH_OPTS -i $KEY $USER@$HOST ./provisionWeaveCNI.sh ${MASTERS[0]};
    ssh $SSH_OPTS -i $KEY $USER@$HOST sudo service mesos-slave restart
done;

# Wait for Agents to come back online
sleep 30


# Provision Mesos DNS
for HOST in ${AGENTS[*]}
do
    echo "Provisioning Mesos DNS on $HOST"
    scp $SSH_OPTS -i $KEY $SCRIPT_DIR/provisionMesosDns.sh $USER@$HOST:~;
    ssh $SSH_OPTS -i $KEY $USER@$HOST ./provisionMesosDns.sh provision ${MASTERS[0]};
done;

ssh $SSH_OPTS -i $KEY $USER@${AGENTS[0]} ./provisionMesosDns.sh launch ${MASTERS[0]};



ssh $SSH_OPTS -i $KEY $USER@$MASTER 'nohup sudo mesos-execute --docker_image=weaveworksdemos/catalogue      --master='$MASTER':5050 --name=catalogue    --networks=weave --resources=cpus:0.1 --no-shell </dev/null >catalogue.log 2>&1 &'
ssh $SSH_OPTS -i $KEY $USER@$MASTER 'nohup sudo mesos-execute --docker_image=weaveworksdemos/front-end      --master='$MASTER':5050 --name=front-end    --networks=weave --resources=cpus:0.1 --no-shell </dev/null >front-end.log 2>&1 &'



# This must start after front-end has been registered in the DNS
#ssh $SSH_OPTS -i $KEY $USER@$MASTER 'nohup sudo mesos-execute --docker_image=weaveworksdemos/edge-router    --master='$MASTER':5050 --name=edge-router  --networks=weave --resources=cpus:0.1 --no-shell </dev/null >edge-router.log 2>&1 &'



#  --command="--logging.level.works.weave=DEBUG"

# NC example to verify web services will work
#ssh -i $KEY ubuntu@$MASTER 'nohup sudo mesos-execute --command="ifconfig; nc -k -l 0.0.0.0 1080" --docker_image=amouat/network-utils      --master='$MASTER':5050 --name=port-check    --networks=weave --resources=cpus:0.1 --shell </dev/null >port-check.log 2>&1 &'
#ssh -i $KEY ubuntu@$MASTER 'nohup sudo mesos-execute --command="ifconfig; python app.py" --docker_image=training/webapp      --master='$MASTER':5050 --name=webapp    --networks=weave --resources=cpus:0.1 --shell </dev/null >port-check.log 2>&1 &'
