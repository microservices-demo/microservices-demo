#!/usr/bin/env bash

expose_container() {
    CONTAINER_IP=$(sudo docker inspect $(sudo docker ps | grep $1 | awk '{print $1}') | jq '.[0]. NetworkSettings.IPAddress' | tr -d \");
    sudo iptables -t nat -A DOCKER -p tcp --dport $2 -j DNAT --to-destination ${CONTAINER_IP}:$2
}

sudo apt-get update

sudo apt-get install -y curl git jq

# Install docker
curl -sSL https://get.docker.com/ | sh

# Install minimesos
curl -sSL https://minimesos.org/install | sh
sudo cp ~/.minimesos/bin/minimesos /usr/local/bin/minimesos

# Install weave
sudo curl -L git.io/weave -o /usr/local/bin/weave
sudo chmod +x /usr/local/bin/weave

# Clone repo to get deployment scripts
git clone https://github.com/microservices-demo/microservices-demo.git
cd microservices-demo

cd deploy/minimesos-marathon
./minimesos-marathon.sh start

# Expose marathon and mesos. NOT FOR PRODUCTION!
expose_container marathon 8080
expose_container mesos-master 5050
