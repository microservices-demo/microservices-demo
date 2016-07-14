# Deploy to Mesos using minimesos

[minimesos](https://minimesos.org) is an in memory mesos cluster. This script will deploy the demo application to mesos.

## Caveates
- Only tested on OSX.

## Prerequisites
- Docker-machine
- minimesos
- weave
- curl

## Quick start

```
./minimesos-marathon.sh install
./minimesos-marathon.sh start
```

### Mac users

This will add a route between local->VM->application/Mesos. Without this you won't be able to access Mesos from your local machine. You'd have to run another container to gain access.

```
./minimesos-marathon.sh install
./minimesos-marathon.sh route
./minimesos-marathon.sh start
```

## Usage

```
minimesos-marathon.sh [OPTION]... [COMMAND]

Starts the weavedemo microservices application on minimesos.

Requirements: Docker-machine, weave and minimesos must be installed.

Tested on: docker-machine version 0.7.0, build a650a40. Weave 1.6.0. minimesos 0.9.0. Mesos 0.25.

 Commands:
  install           Creates a new docker-machine VM.
  route             Create a route towards the docker-machine
  uninstall         Removes docker-machine VM.
  start             Starts weave, minimesos and the demo application
  stop              Stops weave, minimesos and the demo application

 Options:
  --force           Skip all user interaction.  Implied 'Yes' to all actions.
  -q, --quiet       Quiet (no output)
  -l, --log         Print log to file
  -s, --strict      Exit script with null variables.  i.e 'set -o nounset'
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -d, --debug       Runs script in BASH debug mode (set -x)
  -h, --help        Display this help and exit
      --version     Output version information and exit

```
