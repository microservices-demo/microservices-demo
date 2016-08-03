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
* VirtualBox

or 

* Docker For Mac (limited to a single node)


# How-to using Docker For Mac

* Put your docker into the swarm mode
```
docker swarm init
```

* Execute the services startup script
```
./start-swarmkit-services.sh
```

Navigate to http://localhost:30000 to verify that the demo works.

* To remove the running services execute
```
./start-swarmkit-services.sh cleanup
```

# How-to using Vagrant and VirtualBox


Navigate to the vagrant directory and launch vagrant boxes using up.sh
```
./up.sh
```

SSH into the master node ```vagrant ssh```

Launch docker swarm manager
```
docker swarm init --secret "" --listen-addr 192.168.11.10:2377
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

This will spawn all the services composing weave-socks app and expose the application on 192.168.11.10:3000
Since the front-end is run in ```--mode global``` it will be available on all nodes.
