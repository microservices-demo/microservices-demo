#!/usr/bin/env bash

create_remote_context() {
    dc=$(pwd)
    cd ../../testing
    terraform apply
    eval $(terraform show | grep export)
    scp -r $SSH_OPTS -i $KEY $(cd ..; pwd) ubuntu@$INSTANCE:~
    cd $dc
}

destroy_remote_context() {
    dc=$(pwd)
    cd ../../testing
    terraform destroy
    cd $dc
}
