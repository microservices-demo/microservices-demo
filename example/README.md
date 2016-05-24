# Prerequisites
Follow instructions to install swarm/weave/scope.

# Running
```
eval "$(docker-machine env --swarm swarm-master)"
./build.sh
docker pull redis
docker-compose up -d
docker-compose scale web=3
curl http://192.168.99.101/
curl http://192.168.99.102/
curl http://192.168.99.103/
```