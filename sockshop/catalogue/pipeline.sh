#!/usr/bin/env bash

TRAVIS_COMMIT=TEST
module=${PWD##*/}
REPO=weaveworksdemo/${module}
SSH_OPTS=-oStrictHostKeyChecking=no

. remote-context.sh

short_ssh() {
    ssh $SSH_OPTS -i $KEY ubuntu@$INSTANCE $1
}

#### RUN IN LOCAL CONTEXT (e.g. Travis build)

# Unit test
# ===============================================
test.sh unit && echo UNIT-YEAH || exit 1

# Component test
# ===============================================
test.sh component && echo COMPONENT-YEAH || exit 1

# Build
# ===============================================
build.sh "$REPO:$TRAVIS_COMMIT" && echo BUILD-YEAH || exit 1

# Push
# ===============================================
push.sh "$REPO:$TRAVIS_COMMIT" && echo PUSH-YEAH || exit 1 # Unable to push manually at the moment


#### RUN IN REMOTE CONTEXT
create_remote_context

short_ssh "git clone https://github.com/weaveworks/microservices-demo.git;
    cd microservices-demo;
    git checkout $TRAVIS_COMMIT;"

# Container test
# ===============================================
short_ssh "cd microservices-demo/sockshop/$module;
    export PATH=\$PATH:\$PWD/../../testing;
    test.sh container" && echo CONTAINER-YEAH || exit 1

## Application test
# ===============================================
short_ssh "cd microservices-demo/sockshop/$module;
    export PATH=\$PATH:\$PWD/../../testing;
    test.sh application" && echo APPLICATION-YEAH || exit 1

## Application test
# ===============================================
echo "User test Stub" && echo USER-YEAH || exit 1

destroy_remote_context

#### DEPLOY TO STAGING

echo "DEPLOYING THIS TO STAGING"
