# Deploy to Mesos using CNI

These scripts will install the microservices demo on Apache Mesos using the CNI plugin.

*For testing only* Because CNI support is so new, it is not supported in Marathon and some features are missing from Weave. The containers are not orchestrated, so if they crash, they will not be restarted.

## Caveates
- Tested with Mesos 1.0.0
- These scripts start containers using mesos-execute. Not marathon (due to lack of marathon support). Hence, they are not orchestrated. If they crash, they will not be restarted.
- Sometimes Docker hub can respond with 500's. It might take few tries to get it running.
- Mesos only supports CNI from version 1.0.0+
- Mesos only supports CNI on the Mesos containerizer
- Weave DNS does not work with Weave CNI
- This was developed on AWS. May not work on other services.

Please this blog post about the new [mesos unified containerizer](http://winderresearch.com/2016/07/02/Overview-of-Mesos-New-Unified-Containerizer/) for more information.

## Prerequisites
- A working Mesos cluster (here is an example of [how to install mesos on AWS using terraform](https://github.com/philwinder/mesos-terraform))
- [jq](https://stedolan.github.io/jq/)
- curl

## Quick start

```
./mesos-cni.sh install
./mesos-cni.sh start
```

## Usage

```
mesos-cni.sh [OPTION]... [COMMAND]

Starts the weavedemo project on Apache Mesos using CNI. It expects that you have populated the Masters and Agents in this script. See https://github.com/philwinder/mesos-terraform for help with installing Mesos on AWS.

Caveats: This is using a RC version of Mesos, and may not work in the future. This was developed on AWS, so may not work on other services.

 Commands:
  install           Install all required services on the Mesos hosts. Must install before starting.
  uninstall         Removes all installed services
  start             Starts the demo application services. Must already be installed.
  stop              Stops the demo application services

 Options:
  --force           Skip all user interaction.  Implied 'Yes' to all actions.
  -c, --cpu         Individual task CPUs
  -m, --mem         Individual task Mem
  -t, --tag         Sets the tag of the docker images
  -q, --quiet       Quiet (no output)
  -l, --log         Print log to file
  -s, --strict      Exit script with null variables.  i.e 'set -o nounset'
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -d, --debug       Runs script in BASH debug mode (set -x)
  -h, --help        Display this help and exit
      --version     Output version information and exit
```

## Debugging

Because this deployment is highly scripted, there may be future comparability issues. There are some things you can do to help debug the issue.

1. Use the --verbose option. It provides more info.
2. If the task is staging, everything might be ok. It might just be downloading the images.
3. Use the --debug option. It uses `set -x` to record the actual commands.
4. If the failure is during the application startup, log into the master, then look at the log files in the home directory.
5. If the failure is within the application itself, check the Mesos stdout and stderr logs.
