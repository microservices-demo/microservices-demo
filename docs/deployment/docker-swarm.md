---
layout: default
deployDoc: true
---

## Sock Shop via Docker Swarm

Please refer to the [new Docker Swarm introduction](http://container-solutions.com/hail-new-docker-swarm/)

### Blockers

Currently, new Docker Swarm does not support running containers in privileged mode.
Maybe it will be allowed in the future.
Please refer to the issue [1030](https://github.com/docker/swarmkit/issues/1030#issuecomment-232299819).
This prevents running Weave Scope in a normal way, since it needs privileged mode.
A work around exists documented [here](https://github.com/weaveworks/scope-global-swarm-service)

Running global plugins is not supported either.

### Pre-requisities

* [Docker v1.12.3+](https://www.docker.com/products/overview)
* [Docker Compose](https://docs.docker.com/compose/install/)
* *Optional* [Vagrant](https://www.vagrantup.com/downloads.html)
* *Optional* [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
* *Optional* [Packer](https://www.packer.io/downloads.html)
* *Optional* [Terraform](https://www.terraform.io/downloads.html)

```
git clone https://github.com/microservices-demo/microservices-demo
cd microservices-demo
```

<!-- deploy-doc-start pre-install -->

    curl -sSL https://get.docker.com/ | sh
    apt-get install -yq curl jq python-pip unzip build-essential python-dev

    curl https://releases.hashicorp.com/packer/0.12.0/packer_0.12.0_linux_amd64.zip -o /root/packer.zip
    unzip /root/packer.zip -d /usr/bin

    curl https://releases.hashicorp.com/terraform/0.7.11/terraform_0.7.11_linux_amd64.zip -o /root/terraform.zip
    unzip /root/terraform.zip -d /usr/bin

    pip install awscli

<!-- deploy-doc-end -->

## Docker Swarm (Single-Node)

* Put your docker into the swarm mode
* Pull the containers using docker-compose
* Create a Distribution Application Bundle using docker-compose
* Deploy the dab file

~~~~
    cd microservices-demo/deploy/docker-swarm/
    docker swarm init
    docker-compose pull
    docker-compose bundle
    docker deploy dockerswarm
~~~~

* Navigate to <a href="http://localhost:30000" target="_blank">http://localhost:30000</a> to verify that the demo works.

### Run tests

There is a seperate load-test available to simulate user traffic to the application. For more information see [Load Test](#loadtest). 
This will send some traffic to the application, which will form the connection graph that you can view in Scope or Weave Cloud. 

Feel free to run it by issuing the following command:

    docker run --rm --net host weaveworksdemos/load-test -d 60 -h localhost:30000 -c 3 -r 10

### Cleaning up

    docker stack rm dockerswarm


## Docker Swarm (Multi-Node)

<!-- deploy-doc require-env AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION -->

Begin by setting the appropriate AWS environment variables.
```
export AWS_ACCESS_KEY_ID=[YOURACCESSKEYID]
export AWS_SECRET_ACCESS_KEY=[YOURSECRETACCESSKEY]
export AWS_DEFAULT_REGION=[YOURDEFAULTREGION]
```

<!-- deploy-doc-hidden pre-install

    mkdir -p ~/.ssh/
    aws ec2 describe-key-pairs -\-key-name docker-swarm &>/dev/null
    if [ $? -eq 0 ]; then aws ec2 delete-key-pair -\-key-name docker-swarm; fi

    cat > /root/boot.sh <<EOF
#!/usr/bin/env bash
docker service create -\-constraint='node.role == manager' -\-network=dockerswarm_default -\-name healthcheck andrius/alpine-ruby sleep 1200
sleep 30
ID=\$(docker ps | grep healthcheck | awk '{print \$1}')
docker cp /home/ubuntu/healthcheck.rb \$ID:/healthcheck.rb
EOF

    cat > /root/test.sh <<EOF
#!/usr/bin/env bash
ID=\$(docker ps | grep healthcheck | awk '{print \$1}')
docker exec \$ID apk -\-no-cache add ruby-json
docker exec \$ID ruby /healthcheck.rb -s user,catalogue,cart,shipping,payment,orders -d 300
EOF

-->

#### AWS
<!-- deploy-doc-start create-infrastructure -->

    aws ec2 create-key-pair -\-key-name docker-swarm -\-query 'KeyMaterial' -\-output text > ~/.ssh/docker-swarm.pem
    chmod 600 ~/.ssh/docker-swarm.pem

    packer build -only=amazon-ebs deploy/docker-swarm/packer/packer.json
    terraform apply deploy/docker-swarm/infra/aws/

<!-- deploy-doc-end -->

<!-- deploy-doc-hidden create-infrastructure

    master_ip=$(terraform output -json | jq -r '.master_address.value' )
    scp -i ~/.ssh/docker-swarm.pem deploy/healthcheck.rb /root/boot.sh /root/test.sh ubuntu@$master_ip:/home/ubuntu/
    ssh -i ~/.ssh/docker-swarm.pem ubuntu@$master_ip "chmod +x boot.sh; ./boot.sh"

-->

#### gcloud

    export TF_VAR_project_name='project-name'
    export TF_VAR_credentials_file_path="~/.gcloud/accounts.json"
    export TF_VAR_public_key_path="~/.ssh/gcloud_id_rsa.pub"
    export TF_VAR_private_key_path="~/.ssh/gcloud_id_rsa"

    packer build -only=googlecompute deploy/docker-swarm/packer/packer.json
    terraform apply deploy/docker-swarm/infra/gcloud/

#### Local

    export NUM_NODES=2
    packer build -only=virtualbox-iso deploy/docker-swarm/packer/packer.json
    .deploy/docker-swarm/infra/local/swarm.sh up

### Run tests

There is a seperate load-test available to simulate user traffic to the application. For more information see [Load Test](#loadtest).  
This will send some traffic to the application, which will form the connection graph that you can view in Scope or Weave Cloud. 

#### AWS & gcloud

Using any IP from the command: `terraform output`

<!-- deploy-doc-start run-tests -->

    master_ip=$(terraform output -json | jq -r '.master_address.value' )
    docker run --rm weaveworksdemos/load-test -d 60 -h $master_ip:30000 -c 3 -r 10

<!-- deploy-doc-end -->

#### Local

    docker run --rm weaveworksdemos/load-test -d 60 -h 10.0.0.10:30000 -c 3 -r 10

<!-- deploy-doc-hidden run-tests

    master_ip=$(terraform output -json | jq -r '.master_address.value' )
    ssh -i ~/.ssh/docker-swarm.pem ubuntu@$master_ip "chmod +x test.sh; ./test.sh"

    if [ $? -ne 0 ]; then
        exit 1;
    fi

-->

### Cleaning up

#### AWS & Gcloud

<!-- deploy-doc-start destroy-infrastructure -->

    terraform destroy -force deploy/docker-swarm/infra/aws/
    aws ec2 delete-key-pair -\-key-name docker-swarm
    rm ~/.ssh/docker-swarm.pem
    rm terraform.tfstate
    rm terraform.tfstate.backup

<!-- deploy-doc-end -->

#### Local

    ./deploy/docker-swarm/infra/local/swarm.sh down
