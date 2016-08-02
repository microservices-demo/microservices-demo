#!/usr/bin/env bash

SCRIPT_DIR=`dirname "$0"`

if [[ "$OSTYPE" == "darwin"* ]]; then
    DOCKER_CMD=docker
else
    DOCKER_CMD="sudo docker"
fi

echo "Building test container"
$DOCKER_CMD build -t test-container $SCRIPT_DIR > /dev/null

echo "Running tests for \"$@\""
exit_status=0
for dir in $@ ; do
    FILES=$(find ./testing/$dir -iname "*.py")
    for f in $FILES ; do
        echo "Testing $f"
        CODE_DIR=$(pwd)
        echo $CODE_DIR
        $DOCKER_CMD run --rm --name $dir-test -v /var/run/docker.sock:/var/run/docker.sock -v $CODE_DIR:$CODE_DIR -w $CODE_DIR test-container sh -c "export PYTHONPATH=\$PYTHONPATH:`pwd`/testing ; python $f"
        exit_status=$(echo $?)
        if [[ $exit_status -gt 0 ]] ; then
            exit $exit_status
        fi
    done
done
