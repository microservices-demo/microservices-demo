# weaveDemo
Demo microservices application for Weave.


# Installing
## Local
```
./scripts/install.sh launch
./build.sh
eval $(docker-machine env --swarm swarm-master)
docker-compose up -d
```

# Uninstalling
This will remove all docker-machines.
```
./scripts/install.sh destroy
```
