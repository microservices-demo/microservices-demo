---
layout: default
deployDoc: true
---

## Sock Shop via Docker Swarm

Please refer to the [new Docker Swarm introduction](http://container-solutions.com/hail-new-docker-swarm/)

### Pre-requisities

* [Docker v1.12.3+](https://www.docker.com/products/overview) (IMPORTANT: Beta version is required)
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
    docker deploy --bundle-file dockerswarm.dab sockshop
~~~~

* Navigate to <a href="http://localhost:30000" target="_blank">http://localhost:30000</a> to verify that the demo works.

### Run tests

There is a separate load-test available to simulate user traffic to the application. For more information see [Load Test](#loadtest). 
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

-->

#### AWS
<!-- deploy-doc-start create-infrastructure -->

    aws ec2 create-key-pair -\-key-name docker-swarm -\-query 'KeyMaterial' -\-output text > ~/.ssh/docker-swarm.pem
    chmod 600 ~/.ssh/docker-swarm.pem

    packer build -only=amazon-ebs deploy/docker-swarm/packer/packer.json
    terraform apply deploy/docker-swarm/infra/aws/

<!-- deploy-doc-end -->

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

There is a separate load-test available to simulate user traffic to the application. For more information see [Load Test](#loadtest).  
This will send some traffic to the application, which will form the connection graph that you can view in Scope or Weave Cloud. 

#### AWS & gcloud

Using any IP from the command: `terraform output`

<!-- deploy-doc-start run-tests -->

    master_ip=$(terraform output -json | jq -r '.master_address.value' )
    docker run --rm weaveworksdemos/load-test -d 300 -h $master_ip:30000 -c 3 -r 10

<!-- deploy-doc-end -->

#### Local

    docker run --rm weaveworksdemos/load-test -d 60 -h 10.0.0.10:30000 -c 3 -r 10

<!-- deploy-doc-hidden run-tests

    cat > /root/boot.sh <<-EOF
#!/usr/bin/env bash
docker build -t healthcheck -f Dockerfile-healthcheck .
docker service create -\-constraint='node.role == manager' -\-network=dockerswarm_default -\-name healthcheck healthcheck -s user,catalogue,cart,shipping,payment,orders -r 5
sleep 60
ID=\$(docker ps -a | grep healthcheck | awk '{print \$1}' | head -n1)
docker logs -f \$ID
EOF

    master_ip=$(terraform output -json | jq -r '.master_address.value' )
    scp -i ~/.ssh/docker-swarm.pem /root/boot.sh deploy/healthcheck.rb deploy/Dockerfile-healthcheck ubuntu@$master_ip:/home/ubuntu/
    ssh -i ~/.ssh/docker-swarm.pem ubuntu@$master_ip "chmod +x boot.sh; ./boot.sh"

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
