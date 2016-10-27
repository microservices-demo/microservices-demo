---
layout: default
---
## Creating the staging environment

The staging environment is intended to be a replica of the production environment, where we are able to test new commits without harming production.

The intention is to build and deploy every master commit for each service to the staging environment. Therefore each master branch should always be in a working state, since other services may depend on it.

### Also see

 - [Current staging urls](./testing.md#application-urls)
 - [Creating ssh keys for deployment](./ssh-keys-for-deployment-on-travis.md)

### Cluster information

The cluster is a Kubernetes-based one. It roughly mimics the k8s deploy.
  
### Installing the cluster

#### Bastion

First, create a bastion host to create and manage the cluster. This machine will be used by the CI pipelines in order to deploy containers.

I would recommend a standard 14.04 Ubuntu instance, with few resources (e.g. t2.micro with Amazon Linux AMI). Make sure you save the ssh key as others may need it to access the cluster.

**All subsequent steps are installed from the bastion. Do not run on your own laptop. It will take all teh timez.**
#### Cluster install method

Make sure that you have set the AWS credentials before proceeding.
Next, use the k8s AWS instructions to create a cluster http://kubernetes.io/docs/getting-started-guides/aws/. Note that this script will fail (last tested on 1. September 2016, see https://github.com/kubernetes/kubernetes/issues/30495 for more information) but it will download all the necessary files into a kubernetes folder.
Recent reports suggest using https://github.com/kubernetes/kops instead of the above script. 

If you encounter the following error
```
./cluster/../cluster/../cluster/aws/../../cluster/common.sh: line 528: KUBE_MANIFESTS_TAR_URL: unbound variable
```
go to the kubernetes/cluster folder, type `sudo nano common.sh` and edit the method `build-kube-env` like this: 

```
# $1: if 'true', we're building a master yaml, else a node
function build-kube-env {
  local master=$1
  local file=$2
  KUBE_MANIFESTS_TAR_URL="${SERVER_BINARY_TAR_URL/server-linux-amd64/manifests}"
  MASTER_OS_DISTRIBUTION="${KUBE_MASTER_OS_DISTRIBUTION}"
  NODE_OS_DISTRIBUTION="${KUBE_NODE_OS_DISTRIBUTION}"
  local server_binary_tar_url=$SERVER_BINARY_TAR_URL
  local salt_tar_url=$SALT_TAR_URL
  local kube_manifests_tar_url=$KUBE_MANIFESTS_TAR_URL
  if [[ "${master}" == "true" && "${MASTER_OS_DISTRIBUTION}" == "coreos" ]] || \
     [[ "${master}" == "false" && "${NODE_OS_DISTRIBUTION}" == "coreos" ]] ; then
    # TODO: Support fallback .tar.gz settings on CoreOS
    server_binary_tar_url=$(split_csv "${SERVER_BINARY_TAR_URL}")
    salt_tar_url=$(split_csv "${SALT_TAR_URL}")
    kube_manifests_tar_url=$(split_csv "${KUBE_MANIFESTS_TAR_URL}")
  fi

  build-runtime-config
  gen-uid

  rm -f ${file}
  ...
```

Then export the following options for the install scripts:

```
export INSTANCE_PREFIX=microservices-demo-staging AWS_S3_BUCKET=microservices-demo-staging-kubernetes-artifacts AWS_S3_REGION=eu-west-1 KUBE_AWS_ZONE=eu-west-1c NODE_SIZE=m3.medium MASTER_SIZE=m3.medium NUM_NODES=4
```

Note that these might not all work. E.g. I don't think the install prefix works, even though it should.
Also note that the deploying might fail if you change the region because of some VPC setting.

Now run the installer again. It will take a while, because a minion takes about 10 minutes to launch kubernetes.

```
export KUBERNETES_PROVIDER=aws; export KUBERNETES_SKIP_DOWNLOAD=true; curl -sS https://get.k8s.io | bash
```

### Verification

You should be able to ssh into the bastion, then ssh into a node, if you need to.
`ssh -i $HOME/.ssh/kube_aws_rsa admin@$IP`

Next, you should symlink the kubectl binary for global access. Other scripts will rely on this.

```
sudo ln -s $HOME/kubernetes/platforms/linux/amd64/kubectl /usr/local/bin/kubectl
```

And print the cluster information to get some IP addresses.

```
kubectl cluster-info
```

Check that the UI is running by going to the kubernetes-dashboard url and login with the credentials from ~/.kube/config

### Installing weave

Installation of weave is mandatory for correct operation of the application. If you don't, it will not be able to communicate with pods on a different host.

#### On the MASTER

Note that the expose is mandatory. If you don't, K8s won't be able to communicate with the pods.

Note that the dir creation is mandatory. If you don't, weave won't install the cni plugins.

```
sudo curl -L git.io/weave -o /usr/local/bin/weave ; sudo chmod +x /usr/local/bin/weave ; sudo mkdir -p /opt/cni/bin ; sudo mkdir -p /etc/cni/net.d ; sudo weave setup ; sudo weave launch ; sudo weave expose
```

#### On each MINION

Note that the minions all connect to the master, the seed, in order to form a cluster.

Note that the master IP MUST be the internal ip address. The one usually starting with 172. The public IP will not work.

```
sudo curl -L git.io/weave -o /usr/local/bin/weave ; sudo chmod +x /usr/local/bin/weave ; sudo mkdir -p /opt/cni/bin ; sudo mkdir -p /etc/cni/net.d ; sudo weave setup ; sudo weave launch $MASTER_INTERNAL_IP; sudo weave expose
```

Append the cni options to the kubelet service systemd file.

```
sudo nano /etc/sysconfig/kubelet
```

And ensure that the the last line looks like:

```
DAEMON_ARGS="$DAEMON_ARGS ... --babysit-daemons=true --network-plugin=cni --network-plugin-dir=/etc/cni/net.d  "
```
Alternatively, use this regex command:
```
sudo perl -pi -e 's/--babysit-daemons=true +\"/--babysit-daemons=true --network-plugin=cni --network-plugin-dir=\/etc\/cni\/net.d\"/g' /etc/sysconfig/kubelet
```

Due to [this bug](https://github.com/kubernetes/kubernetes/issues/30681), we also need to install the cni plugins:

```
wget https://github.com/containernetworking/cni/releases/download/v0.3.0/cni-v0.3.0.tgz && sudo tar xvf cni-v0.3.0.tgz -C /opt/cni/bin/
```

Finally, we need to restart k8s to use cni. This will kill and restart all applications, system and user. Make sure this is ok first.

```
sudo service kubelet restart
```

If the kubernetes dashboard is not accessible anymore, type
`kubectl describe pods --namespace kube-system kubernetes-dashboard` on the bastion. If there's an error message similar to the one below, restart all your minion EC2 instances.
```
Error syncing pod, skipping: failed to "SetupNetwork" for "catalogue-db-3749174200-f4wkt_default" with SetupNetworkError: "Failed to setup network for pod \"catalogue-db-3749174200-f4wkt_default(44ab7ad4-7022-11e6-aaa7-0ad1a2d3c31d)\" using network plugins \"cni\": could not find \".\" plugin; Skipping pod" 
```

Once all minions have restarted, go to the gui or command line to verify that all system services have restarted successfully. If any services are 0/1 running, or whatever, please debug (see below for a list of commands).

### Installation of application

On the bastion host, clone the microservices-demo repo with
`git clone https://github.com/microservices-demo/microservices-demo.git`
Then start the application.

```
kubectl create -f microservices-demo/deploy/kubernetes/definitions/wholeWeaveDemo.yaml
```

Add the deploy script to the bastion's home directory, for the CI pipelines (if used):

```
cp microservices-demo/deploy/deploy.sh ~
```

You should now be able to connect to the microservices-demo. The frontend url can be found by using the following command on the bastion host:
`kubectl describe service front-end | grep Ingress`

### Installation of scope

Scope wasn't a standard part of the installation. So I created the following specification:

```
ubuntu@ip-172-31-43-18:~$ cat ./microservices-demo/deploy/kubernetes/definitions/scope.yaml
apiVersion: v1
kind: List
items:
  - metadata:
      labels:
        app: weavescope
        weavescope-component: weavescope-app
      name: weavescope-app
    apiVersion: v1
    kind: ReplicationController
    spec:
      replicas: 1
      template:
        metadata:
          labels:
            app: weavescope
            weavescope-component: weavescope-app
        spec:
          containers:
            - name: weavescope-app
              image: 'weaveworks/scope:0.17.1'
              args:
                - '--no-probe'
              ports:
                - containerPort: 4040
  - metadata:
      labels:
        app: weavescope
        weavescope-component: weavescope-app
      name: weavescope-app
    apiVersion: v1
    kind: Service
    spec:
      type: LoadBalancer
      ports:
        - name: app
          port: 80
          targetPort: 4040
          protocol: TCP
      selector:
        app: weavescope
        weavescope-component: weavescope-app
  - metadata:
      labels:
        app: weavescope
        weavescope-component: weavescope-probe
      name: weavescope-probe
    apiVersion: extensions/v1beta1
    kind: DaemonSet
    spec:
      template:
        metadata:
          labels:
            app: weavescope
            weavescope-component: weavescope-probe
        spec:
          hostPID: true
          hostNetwork: true
          containers:
            - name: weavescope-probe
              image: 'weaveworks/scope:0.17.1'
              args:
                - '--no-app'
                - '--probe.docker.bridge=docker0'
                - '--probe.docker=true'
                - '--probe.kubernetes=true'
                - '$(WEAVESCOPE_APP_SERVICE_HOST):$(WEAVESCOPE_APP_SERVICE_PORT)'
              securityContext:
                privileged: true
              resources:
                limits:
                  cpu: 50m
              volumeMounts:
                - name: docker-sock
                  mountPath: /var/run/docker.sock
          volumes:
            - name: docker-sock
              hostPath:
                path: /var/run/docker.sock
```

Then create the app with:

```
kubectl create -f scope.yaml --validate=false
```

The --validate false is required due to some scope/k8s bug.

### Getting ip addresses of external routers

```
ubuntu@ip-172-31-43-18:~$ kubectl describe service front-end | grep Ingress
LoadBalancer Ingress:  	a855a68aa690f11e69a2f0a688e86a8f-329787406.eu-west-1.elb.amazonaws.com
ubuntu@ip-172-31-43-18:~$ kubectl describe service weavescope-app | grep Ingress
LoadBalancer Ingress:  	a7f8f3738690f11e69a2f0a688e86a8f-654938939.eu-west-1.elb.amazonaws.com
```


### Debugging

Here are a whole host of commands that help with debugging.

```
# Describe all system pods
kubectl describe pods --namespace kube-system

# Why isn't the dashboard running?
kubectl describe pods --namespace kube-system kubernetes-dashboard

# Delete the application
kubectl delete -f ./microservices-demo/deploy/kubernetes/definitions/wholeWeaveDemo.yaml

# View the super secret http auth passwords
kubectl config view

# Launch an app from a remote source
kubectl create -f 'https://cloud.weave.works/launch/k8s/weavescope.yaml' --validate=false
```

I found that it was easiest to view individual pod logs from the gui.

### Final tasks

Please update the [testing documentation](./testing.md) with the new ip addresses.
