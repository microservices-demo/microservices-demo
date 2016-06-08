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

TARGET_HOST=localhost
CLIENTS=2
REQUESTS=10

while getopts ":h:c:r:" o; do
  case "${o}" in
    h)
        TARGET_HOST=${OPTARG}
        echo $TARGET_HOST
        ;;
    c)
        CLIENTS=${OPTARG:-2}
        echo $c
        ;;
    r)
        REQUESTS=${OPTARG:-10}
        echo $r
        ;;
    *)
        do_usage
        ;;
  esac
done

if [ -n "${LOCUST_FILE:+1}" ]; then
	echo "Locust file: " $LOCUST_FILE
else
	LOCUST_FILE="locustfile.py" 
	echo "Default Locust file: " $LOCUST_FILE
fi

echo "Running load test against $TARGET_HOST. Spawning $C clients and $R total requets."
locust --host=http://$TARGET_HOST -f $LOCUST_FILE --clients=$CLIENTS --hatch-rate=1 --num-request=$REQUESTS --no-web
echo "done"
