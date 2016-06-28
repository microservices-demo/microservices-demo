#!/usr/bin/env bash

ARGS="$@"
COMMAND="${1}"
ADDRESS="${2}"
SCRIPT_NAME=`basename "$0"`
SCRIPT_DIR=`dirname "$0"`

if [ -z "$1" ]; then
    echo "Must pass master IP"
    exit 1
fi

do_provision() {
    sudo mkdir -p /etc/mesos-dns
    echo '{
      "zk": "zk://'$ADDRESS':2181/mesos",
      "domain": "weave.local",
      "port": 53,
      "resolvers": ["8.8.8.8"],
      "httpport": 8123,
      "externalon": true
    }' | sudo tee /etc/mesos-dns/config.json

    sudo sed -i '1s/^/nameserver 127.0.0.1\n /' /etc/resolv.conf
}

do_launch() {
    curl -X POST -H "Content-type: application/json" $ADDRESS:8080/v2/apps -d '{ "id": "mesos-dns", "user": "root", "cpus": 0.1, "mem": 256, "uris": [ "https://github.com/mesosphere/mesos-dns/releases/download/v0.5.2/mesos-dns-v0.5.2-linux-amd64" ], "cmd": "mv mesos-dns-v* mesos-dns ; chmod +x mesos-dns ; ./mesos-dns -v=2 -config=/etc/mesos-dns/config.json", "instances": 3, "constraints": [["hostname", "UNIQUE"]] }'
}

do_usage() {
    echo "Usage: $SCRIPT_DIR/$SCRIPT_NAME [provision|launch] [MASTER_IP]"
}

case "$COMMAND" in
  launch)
    do_launch
    ;;
  provision)
    do_provision
    ;;
  *)
    do_usage
    ;;
esac