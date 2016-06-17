[![Build Status](https://travis-ci.org/weaveworks/weaveDemo.svg?branch=master)](https://travis-ci.org/weaveworks/weaveDemo)

# weaveDemo
Demo microservices application for Weave.


# Installing
There are two options to run this demo. 1) Run on a single VM or host, 2) Run inside a Docker Swarm. The first option is best for beginners and swarm can introduce some complexity.

## Prerequisites
Docker Toolbox, which includes docker-machine and docker-compose. I will assume that you have cloned this repo with:
```
git clone https://github.com/ContainerSolutions/weaveDemo.git
cd weaveDemo
```

## Non-swarm mode, local virtual machine
Note that this pulls all images from docker-hub. Because of the variety of microservices, this will take a while.
```
docker-machine create default -d virtualbox
eval $(docker-machine env default)
docker-compose pull
docker-compose up -d
```

## Non-swarm mode, remote host
Setup the remote machines with docker, swarm, weave net and scope. Then:
```
docker-compose pull
docker-compose up -d
```

## Docker Swarm (not recommended for newbies)
You have two options. Allow docker compose to pull all the latest images from docker hub, or build the images with a script.

### Local Demo mode
```
./scripts/install.sh launch
eval $(docker-machine env --swarm swarm-master)
docker-compose pull
docker-compose up -d
```

### Remote Demo Mode (AWS)
Make sure the AWS CLI is installed and configured with your credentials, and you have a VPC in which to deploy the instances.
```
export AWS_VPC_ID=vpc-aaaaaa"
export AWS_DEFAULT_REGION=us-west-2"
export AWS_INSTANCE_TYPE=m4.xlarge"
export AWS_INSTANCE_ZONE=a"

#export AWS_INSTANCE_ZONE=region-zone (defaults to a)
#export AWS_INSTANCE_TYPE=instance-type (defaults to t2.medium)
./scripts/install.sh launch-aws
eval $(docker-machine env --swarm swarm-master)
docker-compose pull
docker-compose up -d
```

### Remote Demo Mode
Setup the remote machines with docker, swarm, weave net and scope. Then:
```
docker-compose pull
docker-compose up -d
```

### Dev mode
```
./scripts/install.sh launch
./build.sh
eval $(docker-machine env --swarm swarm-master)
docker-compose up -d
```
Swarm up's are unstable. Pulling and building the project in stages seems to be more stable.

### Dev mode proxy

If you wish to communicate with the cluster using the hostnames from your local machine, you will need to start a proxy. To start a proxy, use the following command (assumes you have eval'ed with `eval $(docker-machine env --swarm swarm-master)`):

```
docker $(docker-machine config swarm-master) run -p 8888:8888 -d --name=proxy --hostname=proxy.weave.local paintedfox/tinyproxy; docker network connect weavedemo_external proxy ; docker network connect weavedemo_internal proxy ; docker network connect weavedemo_secure proxy ; docker network connect weavedemo_backoffice proxy
```

# Uninstalling
This will remove all docker-machines.
## Swarm
```
./scripts/install.sh destroy
```

## Non-swarm
```
docker-compose down
```
