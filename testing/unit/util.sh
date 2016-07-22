#!/usr/bin/env bash


test_go() {
    GO_DIR=$1
    SCRIPT_DIR=`dirname "$0"`
    CODE_DIR=$(cd $PWD/$SCRIPT_DIR/../..; pwd)

    cd $CODE_DIR/$GO_DIR

    docker build -t $1-test .

    docker run --rm $1-test go test github.com/weaveworks/weaveDemo/$1
}
