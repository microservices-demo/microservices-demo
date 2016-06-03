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

if [ $# -eq 0 ]; then
  if [ -n "${TARGET_HOST:+1}" ]; then
	HOST=$TARGET_HOST
  else
	do_usage
  fi
fi

if [ -n "${LOCUST_FILE:+1}" ]; then
	echo "Locust file: " $LOCUST_FILE
else
	LOCUST_FILE="locustfile.py" 
	echo "Default Locust file: " $LOCUST_FILE
fi

echo "Running load test against" $HOST
locust --host=http://$HOST -f $LOCUST_FILE --clients=2 --hatch-rate=1 --num-request=10 --no-web
echo "done"
