#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Warn: No Master IP passed. Assuming this is master"
fi

sudo curl -sL git.io/weave -o /usr/local/bin/weave
sudo chmod a+x /usr/local/bin/weave
sudo mkdir -p /opt/cni/bin
sudo mkdir -p /etc/cni/net.d
sudo weave reset --force # Precautionary
sudo weave setup
sudo weave launch --no-dns $1
sudo weave expose

# Make dirs if they don't exist
sudo mkdir -p /opt/cni/bin
sudo mkdir -p /etc/cni/net.d

# Add location of binary and conf directories for CNI.
echo '/opt/cni/bin' | sudo tee /etc/mesos-slave/network_cni_plugins_dir
echo '/etc/cni/net.d' | sudo tee /etc/mesos-slave/network_cni_config_dir

# WORKAROUND TO FIX WEAVE BUG: https://github.com/weaveworks/weave/issues/2394

echo '#!/bin/sh
docker run --rm --privileged --net=host -v /var/run/docker.sock:/var/run/docker.sock --pid=host -i \
 -e CNI_VERSION -e CNI_COMMAND -e CNI_CONTAINERID -e CNI_NETNS \
 -e CNI_IFNAME -e CNI_ARGS -e CNI_PATH -v /etc/cni:/etc/cni -v /opt/cni:/opt/cni \
 -v /run/mesos/isolators/network/cni:/run/mesos/isolators/network/cni \
 weaveworks/plugin:1.6.0  --cni-net' | sudo tee /opt/cni/bin/weave-net

