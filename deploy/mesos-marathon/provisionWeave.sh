#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Warn: No Master IP passed. Assuming this is master"
fi

sudo curl -sL git.io/weave -o /usr/local/bin/weave
sudo chmod a+x /usr/local/bin/weave
sudo weave launch $1

echo "/var/run/weave/weave.sock" | sudo tee /etc/mesos-slave/docker_socket
