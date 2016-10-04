# Deploy Socks Shop with Marathon using IP per task 

This folder contains a Marathon file with the Socks Shop apps configured as a group and uses Marathon's [IP-per-task](https://mesosphere.github.io/marathon/docs/ip-per-task.html) feature. IP-per-task functionality
is powered by the Weave Net CNI plugin.

## Requirements

| Component     | Version       | Notes   |
|---------------|---------------|---------|
| Apache Mesos  | 1.0.1         | Configure the Weave Net CNI plugin. See http://mesos.apache.org/documentation/latest/cni/ |
| Marathon      | 1.3.0         | None        |
| Docker        | 1.11.2        | Version 1.12.1 does not work in conjunction with Mesos 1.0.1. See 'caveats' below |
| Weave Net     | 1.7.0         | See `provisionMesosDns.sh` script. Weave Net DNS does not work with CNI so run with `--no-dns` |
| Mesos DNS     | 0.5.2         | See `provisionWeaveCNI.sh` script |
| Local machine |               | Install `curl` to deploy to Marathon |
  
## How to create a Mesos cluster

| Cloud | Provisioning tools | Tested |
| ------|----------------| ------ |
| AWS | [https://github.com/philwinder/mesos-terraform](https://github.com/philwinder/mesos-terraform) | Yes |
| GCE | [https://github.com/containersolutions/terraform-mesos](https://github.com/containersolutions/terraform-mesos) | No |

## How to deploy Socks Shop

Deploy the Socks Shop via Marathon's _groups_ endpoint

```
$ curl -XPOST -H "Content-Type: application/json" http://marathon.example.com:8080/v2/groups -d@marathon.json
```

## Bugs

* Cataloguedb does not start and can block other applications from getting resources
* Tasks are stuck in staging sometimes

## Caveats

* Because of https://issues.apache.org/jira/browse/MESOS-6002 and https://issues.apache.org/jira/browse/MESOS-6215 you have to use Docker 1.11.12 instead of Docker 1.12.1
* Marathon IP-per-task using CNI requires Marathon 1.3.0
* Mesos DNS has to be used because Weave DNS does not work in conjunction with Weave CNI.
* This setup was tested on AWS. May not work on other clouds.
