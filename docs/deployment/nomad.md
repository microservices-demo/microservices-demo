---
layout: default
deployDoc: true
---
<!-- deploy-doc require-env AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION -->

## Sock Shop on Nomad


### Goal
The goal of this demo is to demonstrate running the Sock Shop on [Nomad](https://www.nomadproject.io/) while 
using [Weave Net](https://www.weave.works/products/weave-net/) to provide secure networking, 
and [Weave Scope](https://www.weave.works/products/weave-scope/) to monitor the deployment.

### Dependencies
  * [Vagrant](https://vagrantup.com) `~> 1.8.1`
  * [VirtualBox](https://www.virtualbox.org/) `~> 5.0.22`

<!-- deploy-doc-hidden pre-install

    curl -sSL https://get.docker.com/ | sh
    apt-get install -yq rsync python-pip python-dev build-essential jq
    pip install awscli

    mkdir -p ~/.ssh/
    aws ec2 create-key-pair -\-key-name microservices-demo-nomad -\-query 'KeyMaterial' -\-output text > ~/.ssh/nomad.pem
    curl -o /root/vagrant.deb -sSL https://releases.hashicorp.com/vagrant/1.9.1/vagrant_1.9.1_x86_64.deb
    dpkg -i /root/vagrant.deb
    vagrant plugin install vagrant-aws

-->

### Weave Cloud
There are two options available here.

  * A local instance of Weave Scope which is already configured to run and become availabe on port 4040. 
  * Create a account at [cloud.weave.works](https://cloud.weave.works) and using the provided token set the environment variable `export SCOPE_TOKEN=<token>`

### Getting Started
_This example sets up a Nomad cluster with one server and three nodes. Make sure you have at least 6272MB of RAM available._

The easiest way to get started is to simply run

```
$ vagrant up
```

This will:

  * Bring up the Vagrant boxes
  * Install all the dependencies
  * Setup the Nomad cluster

**Disclaimer**: _If this is the first time that you are running this, it may take a while pulling all the Vagrant images, installing
                 packages and what not, so please be patient. The output is quite verbose, so at all points you shoulld know what is
                 going on and what went wrong if anything fails._

<!-- deploy-doc-hidden create-infrastructure

    AWS_VPC_ID=$(aws ec2 create-vpc -\-cidr-block 192.168.59.0/24 | jq -r '.Vpc.VpcId' )
    AWS_INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway | jq -r '.InternetGateway.InternetGatewayId')
    AWS_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables -\-filter "Name=vpc-id,Values=$AWS_VPC_ID" | jq -r ".RouteTables[].RouteTableId")
    aws ec2 attach-internet-gateway -\-internet-gateway-id $AWS_INTERNET_GATEWAY_ID -\-vpc-id $AWS_VPC_ID
    aws ec2 create-route -\-gateway-id $AWS_INTERNET_GATEWAY_ID -\-destination-cidr-block 0.0.0.0/0 -\-route-table-id $AWS_ROUTE_TABLE_ID

    export AWS_SUBNET_ID=$(aws ec2 create-subnet -\-vpc-id $AWS_VPC_ID -\-cidr-block 192.168.59.0/24 -\-availability-zone eu-west-1c | jq -r '.Subnet.SubnetId')
    export AWS_SECURITY_GROUP_ID=$(aws ec2 create-security-group -\-group-name nomad-deploy-doc -\-description "Security Group for nomad deploy doc" -\-vpc-id $AWS_VPC_ID | jq -r '.GroupId' )
    aws ec2 authorize-security-group-ingress -\-group-id $AWS_SECURITY_GROUP_ID -\-protocol tcp -\-port 22 -\-cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress -\-group-id $AWS_SECURITY_GROUP_ID -\-protocol tcp -\-port 80 -\-cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress -\-group-id $AWS_SECURITY_GROUP_ID -\-protocol all -\-source-group $AWS_SECURITY_GROUP_ID

    cat > ~/.bash_profile <<-EOF
export AWS_VPC_ID=$AWS_VPC_ID
export AWS_INTERNET_GATEWAY_ID=$AWS_INTERNET_GATEWAY_ID
export AWS_ROUTE_TABLE_ID=$AWS_ROUTE_TABLE_ID
export AWS_SUBNET_ID=$AWS_SUBNET_ID
export AWS_SECURITY_GROUP_ID=$AWS_SECURITY_GROUP_ID
export VAGRANT_DEFAULT_PROVIDER=aws
export NUM_NODES=3
EOF

    . ~/.bash_profile

    cd deploy/nomad
    VAGRANT_DEFAULT_PROVIDER=aws vagrant up -\-provider=aws
    vagrant ssh node1 -c "nomad run netman.nomad"

-->

##### Run with Fluentd + ELK based logging

Although this step is option, if you want to run the application using a more advanced logging setup based on Fluentd + ELK stack, 
you can do so by running the following Nomad jobs:

```
root@local:/# vagrant ssh node1
ubuntu@node1:/# nomad run logging-elk.nomad
ubuntu@node1:/# nomad run logging-fluentd.nomad
```

Once both jobs finish starting you can view the Kibana interface by opening page http://192.168.59.102:5601.

### Starting the application
To start the application you will need to ssh into the `node1` box and run the respective Nomad jobs:

```
root@local:/# vagrant ssh node1
ubuntu@node1:/# nomad run netman.nomad
ubuntu@node1:/# nomad run weavedemo.nomad
```

The output from the following commands should be similar to what's displayed below:

```
ubuntu@node1:/#  nomad run netman.nomad
==> Monitoring evaluation "858414a3"
    Evaluation triggered by job "netman"
    Allocation "0e3a6a5a" modified: node "9b8300f6", group "main"
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "858414a3" finished with status "complete"
```
```
ubuntu@node1:/# nomad run weavedemo.nomad
==> Monitoring evaluation "0ad17a84"
    Evaluation triggered by job "weavedemo"
    Allocation "5c1ebc22" modified: node "9b8300f6", group "frontend"
    Allocation "8a7f7f52" modified: node "9b8300f6", group "payment"
    Allocation "f3a76ce1" modified: node "9b8300f6", group "accounts"
    Allocation "d5fac4c8" modified: node "9b8300f6", group "login"
    Allocation "d6526050" modified: node "9b8300f6", group "orders"
    Allocation "efeddd3e" modified: node "9b8300f6", group "shipping"
    Allocation "45368041" modified: node "9b8300f6", group "queue-master"
    Allocation "5d519978" modified: node "9b8300f6", group "cart"
    Allocation "732f4f54" modified: node "9b8300f6", group "catalogue"
    Allocation "75fbee96" modified: node "9b8300f6", group "rabbitmq"
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "0ad17a84" finished with status "complete"
```

### Locating The Endpoint
Taking the Allocation ID of the **frontend** task group above we can ask Nomad about its status:

```
ubuntu@node1:/# nomad alloc-status 5c1ebc22
ID            = 5c1ebc22
Eval ID       = c318487e
Name          = weavedemo.frontend[0]
Node ID       = 9b8300f6
Job ID        = weavedemo
Client Status = running

Task "edgerouter" is "running"
Task Resources
CPU    Memory          Disk     IOPS  Addresses
0/100  9.8 MiB/32 MiB  300 MiB  0     http: 192.168.59.102:80
                                      https: 192.168.59.102:443

Recent Events:
Time                    Type        Description
07/01/16 18:04:36 CEST  Started     Task started by client
07/01/16 18:02:54 CEST  Received    Task received by client

Task "front-end" is "running"
Task Resources
CPU    Memory          Disk     IOPS  Addresses
0/100  61 MiB/128 MiB  300 MiB  0

Recent Events:
Time                    Type      Description
07/01/16 18:05:54 CEST  Started   Task started by client
07/01/16 18:02:54 CEST  Received  Task received by client
```

If you look carefully, you will notice that the **edgerouter** task is **running** and among the resources that have been
allocated for it, ports 80 (HTTTP) and 443 (HTTPS) have been bound to the IP **192.168.59.102**. Visiting this IP should 
yield a running sock shop, while visiting this IP on port 4040 should show the Weave Scope dashboard unless configured to
use Weave Coud, then visit cloud.weave.works to check.

### Run tests

There is a separate load-test available to simulate user traffic to the application. For more information see [Load Test](#loadtest).
This will send some traffic to the application, which will form the connection graph that you can view in Scope or Weave Cloud.

```
docker run --rm weaveworksdemos/load-test -d 300 -h 192.168.59.102 -c 3 -r 10
```

<!-- deploy-doc-hidden run-tests
    . ~/.bash_profile

    cd deploy/nomad
    vagrant ssh node1 -c "nomad run weavedemo.nomad"
    public_dns=$(aws ec2 describe-instances -\-filter "Name=tag:Name,Values=nomad-node" "Name=instance-state-name,Values=running" | jq -r ".Reservations[].Instances[0].PublicIpAddress" | head -n1)
    docker run -\-rm weaveworksdemos/load-test -d 300 -h $public_dns -c 3 -r 10

    vagrant ssh node1 -c "docker build -t healthcheck -f Dockerfile-healthcheck ."
    vagrant ssh node1 -c "eval \$(weave env); nomad run weavedemo.nomad; docker create -\-name healthcheck healthcheck -s orders,cart,payment,user,catalogue,shipping,queue-master -d 60 -r 5"
    vagrant ssh node1 -c "docker network connect backoffice healthcheck; \
        docker network connect internal healthcheck; \
        docker network connect external healthcheck; \
        docker network connect secure healthcheck;"
    vagrant ssh node1 -c "docker start -a healthcheck"
    if [ $? -ne 0 ]; then
        vagrant ssh node1 -c "docker rm -f healthcheck"
        exit 1
    fi
    vagrant ssh node1 -c "docker rm -f healthcheck"
-->

### Cleaning Up

```
vagrant destroy -f
```
<!-- deploy-doc-hidden destroy-infrastructure
    . ~/.bash_profile

    cd deploy/nomad
    vagrant destroy -\-force
    aws ec2 wait instance-terminated -\-filter "Name=key-name,Values=microservices-demo-nomad"
    aws ec2 delete-key-pair -\-key-name microservices-demo-nomad
    aws ec2 delete-subnet -\-subnet-id $AWS_SUBNET_ID
    aws ec2 delete-security-group -\-group-id nomad-deploy-doc -\-group-id $AWS_SECURITY_GROUP_ID
    aws ec2 detach-internet-gateway -\-internet-gateway-id $AWS_INTERNET_GATEWAY_ID -\-vpc-id $AWS_VPC_ID
    aws ec2 delete-internet-gateway -\-internet-gateway-id $AWS_INTERNET_GATEWAY_ID
    aws ec2 delete-vpc -\-vpc-id $AWS_VPC_ID

-->
