#!/usr/bin/env bash
set -x

ARGS="$@"
COMMAND="${1}"
ADDRESS="${2}"
SCRIPT_NAME=`basename "$0"`
SCRIPT_DIR=`dirname "$0"`
APP_NAME=mesos-dns

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

    IFACE='weave'
    IP=$(ip -4 address show $IFACE | grep 'inet' | sed 's/.*inet \([0-9\.]\+\).*/\1/')

    echo "nameserver $IP" | sudo tee -a /etc/resolvconf/resolv.conf.d/head
    sudo rm /etc/resolv.conf
    sudo ln -s ../run/resolvconf/resolv.conf /etc/resolv.conf
    sudo resolvconf -u

}

do_launch() {
    curl -X POST -H "Content-type: application/json" $ADDRESS:8080/v2/apps?force=true -d '{ "id": "'$APP_NAME'", "user": "root", "cpus": 0.1, "mem": 256, "uris": [ "https://github.com/mesosphere/mesos-dns/releases/download/v0.5.2/mesos-dns-v0.5.2-linux-amd64" ], "cmd": "mv mesos-dns-v* mesos-dns ; chmod +x mesos-dns ; ./mesos-dns -v=2 -config=/etc/mesos-dns/config.json", "instances": 3, "constraints": [["hostname", "UNIQUE"]] }'
}

do_stop() {
    curl -X DELETE -H "Content-type: application/json" $ADDRESS:8080/v2/apps/$APP_NAME
}

do_usage() {
    echo "Usage: $SCRIPT_DIR/$SCRIPT_NAME [provision|launch] [MASTER_IP]"
}

case "$COMMAND" in
  launch)
    do_launch
    ;;
  stop)
    do_stop
    ;;
  provision)
    do_stop
    do_provision
    ;;
  *)
    do_usage
    ;;
esac