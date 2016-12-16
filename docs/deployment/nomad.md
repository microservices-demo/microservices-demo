---
layout: default
deployDoc: true
---

<<<<<<< HEAD
## Nomad

Work in progress. Please see [PR 470](https://github.com/microservices-demo/microservices-demo/pull/470) to follow the progress on this work.
=======
## Sock Shop on Nomad

This demo demonstrates running the Sock Shop on Nomad.

### Pre-Requirements
  * [Vagrant](https://vagrantup.com) `~> 1.8.1`
  * [VirtualBox](https://www.virtualbox.org/) `~> 5.0.22`

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

### Starting the application
To start the application you will need to ssh into the `node1` box and run the respective Nomad jobs:
<!-- deploy-doc require-env AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION -->

<!-- deploy-doc-hidden pre-install

    apt-get update
    apt-get install -yq rsync python-pip python-dev build-essential
    pip install awscli

    mkdir -p ~/.ssh/
    aws ec2 create-key-pair -\-key-name microservices-demo-nomad -\-query 'KeyMaterial' -\-output text > ~/.ssh/nomad.pem
    curl -o /root/vagrant.deb -sSL https://releases.hashicorp.com/vagrant/1.9.1/vagrant_1.9.1_x86_64.deb
    dpkg -i /root/vagrant.deb
    vagrant plugin install vagrant-aws

-->

    vpc_id=$(aws ec2 create-vpc -\-cidr-block 192.168.59.0/28 | jq -r '.Vpc.VpcId' )
    internet_gateway_id=$(aws ec2 create-internet-gateway | jq -r '.InternetGateway.InternetGatewayId')
    route_table_id=$(aws ec2 describe-route-tables -\-filter "Name=vpc-id,Values=$vpc_id" | jq -r ".RouteTables[].RouteTableId")
    aws ec2 attach-internet-gateway -\-internet-gateway-id $internet_gateway_id -\-vpc-id $vpc_id
    aws ec2 create-route -\-gateway-id $internet_gateway_id -\-destination-cidr-block 0.0.0.0/0 -\-route-table-id $route_table_id

    subnet_id=$(aws ec2 create-subnet -\-vpc-id $vpc_id -\-cidr-block 192.168.59.0/28 -\-availability-zone eu-west-1c | jq -r '.Subnet.SubnetId')
    security_group_id=$(aws ec2 create-security-group -\-group-name nomad-deploy-doc -\-description "Security Group for nomad deploy doc" -\-vpc-id $vpc_id | jq -r '.GroupId' )
    aws ec2 authorize-security-group-ingress -\-group-id $security_group_id -\-protocol tcp -\-port 22 -\-cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress -\-group-id $security_group_id -\-protocol tcp -\-port 80 -\-cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress -\-group-id $security_group_id -\-protocol tcp -\-port 8301 -\-cidr 0.0.0.0/0

    aws ec2 delete-subnet -\-subnet-id $subnet_id
    aws ec2 delete-security-group -\-group-id nomad-deploy-doc -\-group-id $security_group_id
    aws ec2 delete-route-table -\-route-table-id $route_table_id
    aws ec2 delete-internet-gateway -\-internet-gateway-id $internet_gateway_id
    aws ec2 delete-vpc -\-vpc-id $vpc_id

<!-- deploy-doc-hidden create-infrastructure

    cd deploy/nomad
    export VAGRANT_DEFAULT_PROVIDER=aws
    SSH_USERNAME=ec2-user vagrant up -\-provider=aws
    vagrant ssh node1 -c "nomad run netman.nomad"

-->

<!-- deploy-doc-hidden run-tests

    cd deploy/nomad
    i=0
    STATUS=1
    while [ $i -lt 5 ] || [ $STATUS -ne 0 ]; do
        vagrant ssh node1 -c "nomad run weavedemo.nomad"
        vagrant ssh node1 -c "nomad status weavedemo"
        vagrant ssh node1 -c "eval \$(weave env); docker create -\-name healthcheck -v \$PWD/healthcheck.rb:/healthcheck.rb andrius/alpine-ruby ./healthcheck.rb -s orders,cart,payment,user,catalogue,shipping,queue-master"
        vagrant ssh node1 -c "docker network connect backoffice healthcheck; docker network connect internal healthcheck; docker network connect external healthcheck; docker network connect secure healthcheck"

        sleep 180
        echo "sleeping 3mins..."
        vagrant ssh node1 -c "docker start -a healthcheck"
        STATUS=$?

        vagrant ssh node1 -c "docker rm -f healthcheck"
        i=$(($i+1))
    done
-->

<!-- deploy-doc-hidden destroy-infrastructure

    cd deploy/nomad
    vagrant destroy -\-force
    aws ec2 delete-key-pair -\-key-name microservices-demo-nomad

-->

```
$ vagrant ssh node1
$ nomad run netman.nomad
==> Monitoring evaluation "858414a3"
    Evaluation triggered by job "netman"
    Allocation "0e3a6a5a" modified: node "9b8300f6", group "main"
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "858414a3" finished with status "complete"
$ nomad run weavedemo.nomad
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
Let's take the Allocation ID of the **frontend** task group and ask Nomad about its status:
```
$ nomad alloc-status 5c1ebc22
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
07/01/16 18:06:03 CEST  Started     Task started by client
07/01/16 18:05:25 CEST  Restarting  Task restarting in 26.343413077s
07/01/16 18:05:25 CEST  Terminated  Exit Code: 1, Exit Message: "Docker container exited with non-zero exit code: 1"
07/01/16 18:05:24 CEST  Started     Task started by client
07/01/16 18:04:37 CEST  Restarting  Task restarting in 26.58623629s
07/01/16 18:04:37 CEST  Terminated  Exit Code: 1, Exit Message: "Docker container exited with non-zero exit code: 1"
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
allocated for it, ports 80 (HTTTP) and 443 (HTTPS) have been bound to the ip **192.168.59.102**. This is the IP that you
can use on your browser to access the application.
>>>>>>> Fixed cataloguedb, added vagrant-aws, added deploy docs
