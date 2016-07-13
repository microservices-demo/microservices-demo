# Run weave-socks demo on the new Docker Swarm

Please refer to the [new Docker Swarm introduction](http://container-solutions.com/hail-new-docker-swarm/)

# Blockers

Currently, new Docker Swarm does not support running containers in privileged mode. 
Maybe it will be allowed in the future.
Please refer to the issue [1030](https://github.com/docker/swarmkit/issues/1030#issuecomment-232299819).
This prevents from running Weave Scope, since it needs privileged mode.

Running global plugins is not supported either.

# Overview

This setup includes 3 nodes for Docker Swarm.
master1 - is the Docker Swarm manager node
node1 and node2 - worker nodes

# Pre-requisities

* Vagrant


# How-to

Launch vagrant boxes using up.sh
```
./up.sh
```

SSH into the master node ```vagrant ssh```

Launch docker swarm manager
```
docker swarm init --listen-addr 192.168.11.10:2377
```

SSH into node1 and join the swarm
```
docker swarm join --listen-addr 192.168.11.11:2377 192.168.11.10:2377
```

SSH into node2 and join the swarm
```
docker swarm join --listen-addr 192.168.11.12:2377 192.168.11.10:2377
```

If everything succeeded, we should have a docker swarm cluster of 3 nodes.

Now, on the master1 node execute the following script:
```
/vagrant/start-swarmkit-services.sh
```

This will spawn all the services composing weave-socks app and expose the application on port 3000
