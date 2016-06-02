#!/bin/sh
#
# Run locust load test
#
#####################################################################
ARGS="$@"
HOST="${1}"
SCRIPT_NAME=`basename "$0"`

do_usage() {
    cat >&2 <<EOF
Usage:
  ${SCRIPT_NAME} [ host ] OPTIONS
Description:
  Runs load test against specified host
EOF
  exit 1
}

if [[ $# -eq 0 ]]; then
  do_usage
fi

echo "Running load test against" $HOST
locust --host=http://$HOST -f locustTest.py --clients=2 --hatch-rate=1 --num-request=10 --no-web
echo "done"
