# Deploy to Mesos using CNI

These scripts will install the microservices demo on Apache Mesos using Marathon.

## Caveates
- This is using a prerelease version of Mesos 1.0.0
- This was developed on AWS. May not work on other services.

## Prerequisites
- A working Mesos cluster (here is an example of [how to install mesos on AWS using terraform](https://github.com/philwinder/mesos-terraform))
- curl

## Quick start

```
./mesos-marathon.sh install
./mesos-marathon.sh start
```

## Usage

```
Starts the weavedemo microservices demo on Mesos using Marathon.

Caveats: This is using a RC version of Mesos, and may not work in the future. This was developed on AWS, so may not work on other services.

 Commands:
  install           Install all required services on the Mesos hosts. Must install before starting.
  uninstall         Removes all installed services
  start             Starts the demo application services. Must already be installed.
  stop              Stops the demo application services

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
