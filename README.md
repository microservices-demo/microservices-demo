# weaveDemo
Demo microservices application for Weave.


# Installing
## Local
```
cd scripts
./install.sh
cd ..
./build.sh
eval $(docker-machine env --swarm swarm-master)
docker-compose up -d
```

# Uninstalling
This will remove all docker-machines.
```
./scripts/install.sh destroy
```
