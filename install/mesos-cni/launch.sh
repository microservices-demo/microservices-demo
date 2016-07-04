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

# Wait for DNS to come online
sleep 30


# Provision Edge router first, so that it is always on all machines.
curl -X POST -H "Content-type: application/json" $MASTER:8080/v2/apps -d '{
  "id": "edge-router",
  "cmd": "while ! ping -c1 front-end.mesos-executeinstance.weave.local &>/dev/null; do : echo .; done ; sed -i \"s/.*proxy_pass.*/      proxy_pass      http:\\/\\/front-end.mesos-executeinstance.weave.local:8079;/\" /etc/nginx/nginx.conf ; nginx -g \"daemon off;\"",
  "cpus": 0.2,
  "mem": 512,
  "disk": 0,
  "instances": 3,
  "constraints": [["hostname", "UNIQUE"]],
  "container": {
    "docker": {
      "image": "weaveworksdemos/edge-router:",
      "network": "HOST",
      "parameters": [],
      "privileged": true
    },
    "type": "DOCKER",
    "volumes": []
  },
  "portDefinitions": [
    {
      "port": 80,
      "protocol": "tcp",
      "name": "80"
    }
  ],
  "env": {},
  "labels": {}
}'

# Usage: launch_service name command image shell
launch_service() {
    ssh	$SSH_OPTS	-i	$KEY	$USER@${MASTERS[0]}	'nohup	sudo	mesos-execute	--networks=weave    --env={\"LC_ALL\":\"C\"}	'$4'	--resources=cpus:0.4\;mem:1024	--name='$1'	--command="'$2'"	--docker_image='$3'	--master='$MASTER':5050	</dev/null	>'$1'.log	2>&1	&'
}

TAG="9ec2008170d626d8361e701bb1a63ea195901c3a"

launch_service accounts-db  "echo ok"                                       mongo                               --no-shell
launch_service cart-db      "echo ok"                                       mongo                               --no-shell
launch_service orders-db    "echo ok"                                       mongo                               --no-shell

sleep 60 # Wait for db's to pull start and enter the DNS.

launch_service front-end    "npm start -- --domain=mesos-executeinstance.weave.local"   weaveworksdemos/front-end:$TAG --shell
launch_service catalogue    "echo ok"                                       weaveworksdemos/catalogue:$TAG      --no-shell
launch_service accounts     "java -Djava.security.egd=file:/dev/urandom -jar ./app.jar --port=80 --domain=mesos-executeinstance.weave.local"    weaveworksdemos/accounts:$TAG       --shell
launch_service cart         "java -Djava.security.egd=file:/dev/urandom -jar ./app.jar --port=80 --domain=mesos-executeinstance.weave.local"    weaveworksdemos/cart:$TAG           --shell
launch_service orders       "java -Djava.security.egd=file:/dev/urandom -jar ./app.jar --port=80 --domain=mesos-executeinstance.weave.local"    weaveworksdemos/orders:$TAG         --shell
launch_service shipping     "java -Djava.security.egd=file:/dev/urandom -jar ./app.jar --port=80 --domain=mesos-executeinstance.weave.local"    weaveworksdemos/shipping:$TAG       --shell
launch_service queue-master "echo ok"                                       weaveworksdemos/queue-master:$TAG   --no-shell
launch_service payment      "echo ok"                                       weaveworksdemos/payment:$TAG        --no-shell
launch_service login        "echo ok"                                       weaveworksdemos/login:$TAG          --no-shell



# NC example to verify web services will work
#ssh -i $KEY ubuntu@$MASTER 'nohup sudo mesos-execute --command="ifconfig; dig catalogue.mesos-executeinstance.weave.local ; curl http://catalogue.mesos-executeinstance.weave.local/catalogue ; cat /etc/resolv.conf" --docker_image=amouat/network-utils      --master='$MASTER':5050 --name=dns-check    --networks=weave --resources=cpus:0.1 --shell </dev/null >port-check.log 2>&1 &'
#ssh -i $KEY ubuntu@$MASTER 'nohup sudo mesos-execute --command="ifconfig; nc -k -l 0.0.0.0 1080" --docker_image=amouat/network-utils      --master='$MASTER':5050 --name=port-check    --networks=weave --resources=cpus:0.1 --shell </dev/null >port-check.log 2>&1 &'
#ssh -i $KEY ubuntu@$MASTER 'nohup sudo mesos-execute --command="ifconfig; python app.py" --docker_image=training/webapp      --master='$MASTER':5050 --name=webapp    --networks=weave --resources=cpus:0.1 --shell </dev/null >port-check.log 2>&1 &'
