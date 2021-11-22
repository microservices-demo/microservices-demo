#!/usr/bin/env bash
certs=/etc/docker/certs.d/192.168.1.10:8443
sudo rm -rf /registry-image
sudo rm -rf /etc/docker/certs
sudo rm -rf $certs

docker rm -f registry
docker rmi registry:2
