#!/usr/bin/env bash

version="1.0.0"

SCRIPT_DIR=`dirname "$0"`
SCRIPT_NAME=`basename "$0"`
USER=ubuntu
MASTERS=($MASTER)
AGENTS=($SLAVE0 $SLAVE1 $SLAVE2)
SSH_OPTS=-oStrictHostKeyChecking=no
SERVICES=("carts-db" "orders-db" "user-db" "shipping" "orders" "catalogue" "catalogue-db" "carts" "payment" "user" "front-end" "rabbitmq")


############## Begin Utilities ###################
function trapCleanup() {
  # trapCleanup Function
  # -----------------------------------
  # Any actions that should be taken if the script is prematurely
  # exited.  Always call this function at the top of your script.
  # -----------------------------------
  echo ""
  die "Exit trapped."
}

function safeExit() {
  # safeExit
  # -----------------------------------
  # Non destructive exit for when script exits naturally.
  # Usage: Add this function at the end of every script.
  # -----------------------------------
  # Delete temp files, if any
  if [ -d "${tmpDir}" ] ; then
    rm -r "${tmpDir}"
  fi
  trap - INT TERM EXIT
  exit
}

# Set Flags
# -----------------------------------
# Flags which can be overridden by user input.
# Default values are below
# -----------------------------------
quiet=false
printLog=false
verbose=false
force=false
strict=false
debug=false
args=()
cpu=0.3
mem=1024

# Logging
# -----------------------------------
# Log is only used when the '-l' flag is set.
#
# To never save a logfile change variable to '/dev/null'
# Save to Desktop use: $HOME/Desktop/${scriptBasename}.log
# Save to standard user log location use: $HOME/Library/Logs/${scriptBasename}.log
# -----------------------------------
logFile="${HOME}/${scriptBasename}.log"


# Options and Usage
# -----------------------------------
# Print usage
do_usage() {
  echo "$(basename $0) [OPTION]... [COMMAND]

Starts the weavedemo project on Apache Mesos using CNI. It expects that you have populated the Masters and Agents in this script. See https://github.com/philwinder/mesos-terraform for help with installing Mesos on AWS.

Caveats: This is using a RC version of Mesos, and may not work in the future. This was developed on AWS, so may not work on other services.

 ${bold}Commands:${reset}
  install           Install all required services on the Mesos hosts. Must install before starting.
  uninstall         Removes all installed services
  start             Starts the demo application services. Must already be installed.
  stop              Stops the demo application services

 ${bold}Options:${reset}
  --force           Skip all user interaction.  Implied 'Yes' to all actions.
  -c, --cpu         Individual task CPUs
  -m, --mem         Individual task Mem
  -q, --quiet       Quiet (no output)
  -l, --log         Print log to file
  -s, --strict      Exit script with null variables.  i.e 'set -o nounset'
  -v, --verbose     Output more information. (Items echoed to 'verbose')
  -d, --debug       Runs script in BASH debug mode (set -x)
  -h, --help        Display this help and exit
      --version     Output version information and exit
"
}

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;

    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Print help if no arguments were passed.
# Uncomment to force arguments when invoking the script
# -------------------------------------
# [[ $# -eq 0 ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) do_usage >&2; safeExit ;;
    --version) echo "$(basename $0) ${version}"; safeExit ;;
    -c|--cpu) shift; cpu=${1} ;;
    -m|--mem) shift; mem=${1} ;;
    -v|--verbose) verbose=true ;;
    -l|--log) printLog=true ;;
    -q|--quiet) quiet=true ;;
    -s|--strict) strict=true;;
    -d|--debug) debug=true;;
    --force) force=true ;;
    --endopts) shift; break ;;
    *) die "invalid option: '$1'." ;;
  esac
  shift
done

# Store the remaining part as arguments.
args+=("$@")


# Logging and Colors
# -----------------------------------------------------
# Here we set the colors for our script feedback.
# Example usage: success "sometext"
#------------------------------------------------------

# Set Colors
bold=$(tput bold)
reset=$(tput sgr0)
purple=$(tput setaf 171)
red=$(tput setaf 1)
green=$(tput setaf 76)
tan=$(tput setaf 3)
blue=$(tput setaf 38)
underline=$(tput sgr 0 1)

function _alert() {
  if [ "${1}" = "error" ]; then local color="${bold}${red}"; fi
  if [ "${1}" = "warning" ]; then local color="${red}"; fi
  if [ "${1}" = "success" ]; then local color="${green}"; fi
  if [ "${1}" = "debug" ]; then local color="${purple}"; fi
  if [ "${1}" = "header" ]; then local color="${bold}""${tan}"; fi
  if [ "${1}" = "input" ]; then local color="${bold}"; fi
  if [ "${1}" = "info" ] || [ "${1}" = "notice" ]; then local color=""; fi
  # Don't use colors on pipes or non-recognized terminals
  if [[ "${TERM}" != "xterm"* ]] || [ -t 1 ]; then color=""; reset=""; fi

  # Print to console when script is not 'quiet'
  if ${quiet}; then return; else
   echo "$(date +"%r") ${color}$(printf "[%7s]" "${1}") ${_message}${reset}";
  fi

  # Print to Logfile
  if ${printLog} && [ "${1}" != "input" ]; then
    color=""; reset="" # Don't use colors in logs
    echo "$(date +"%m-%d-%Y %r") $(printf "[%7s]" "${1}") ${_message}" >> "${logFile}";
  fi
}

function die ()       { local _message="${*} Exiting."; echo "$(_alert error)"; safeExit;}
function error ()     { local _message="${*}"; echo "$(_alert error)"; }
function warning ()   { local _message="${*}"; echo "$(_alert warning)"; }
function notice ()    { local _message="${*}"; echo "$(_alert notice)"; }
function info ()      { local _message="${*}"; echo "$(_alert info)"; }
function debug ()     { local _message="${*}"; echo "$(_alert debug)"; }
function success ()   { local _message="${*}"; echo "$(_alert success)"; }
function input()      { local _message="${*}"; echo -n "$(_alert input)"; }
function header()     { local _message="== ${*} ==  "; echo "$(_alert header)"; }
function verbose()    { if ${verbose}; then debug "$@"; fi }

# Trap bad exits with your cleanup function
trap trapCleanup EXIT INT TERM

# Set IFS to preferred implementation
IFS=$' \n\t'

# Exit on error. Append '||true' when you run the script if you expect an error.
set -o errexit

# Run in debug mode, if set
if ${debug}; then set -x ; fi

# Exit on empty variable
if ${strict}; then set -o nounset ; fi

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`, for example.
set -o pipefail

############## End Utilities ###################

############## Start Helpers ###################

# Usage: launch_service name command image shell
launch_service() {
    info "Starting $1"
    STATUS=STARTING
    while [  "$STATUS" != "TASK_RUNNING" ]; do
        if [ -z "$STATUS" ] ; then
            verbose "Retrying $1"
        fi
        ssh	$SSH_OPTS -i $KEY $USER@${MASTERS[0]} 'nohup sudo mesos-execute --networks=weave --env="{\"LC_ALL\":\"C\"'$5'}" '$4' --resources=cpus:'$cpu'\;mem:'$mem' --name='$1' --command="'$2'" --docker_image='$3' --master='${MASTERS[0]}':5050 </dev/null >'$1'.log 2>&1 &'
        sleep 1 # Give it a second to register in mesos
        wait_task_running $1
        STATUS=$(task_status $1)
    done
}

task_status() {
    echo $(curl -s ${MASTERS[*]}:5050/state.json | jq '.frameworks[] | select(.tasks[].name == "'$1'").tasks[].state' | tail -n 1 | tr -d "\"")
}

wait_task_running() {
    COUNTER=0
    STATUS=$(task_status $1)
    verbose "Wating for $1"
    while [ "$STATUS" != "TASK_RUNNING" ] && [ -n "$STATUS" ]; do
     let COUNTER=COUNTER+1
     sleep 1
     if [ $COUNTER -gt 60 ] ; then
        warning "This is taking too long. Consider Ctrl-C'ing"
     fi
     STATUS=$(task_status $1)
     verbose "Status is '$STATUS'"
    done
}

get_id() {
    ID=$(curl -s ${MASTERS[0]}:5050/state.json | jq '.frameworks[] | select(.tasks[].name == "'$1'") | select(.tasks[].state == "TASK_RUNNING") | .id' | tail -n 1 | tr -d "\"")
    echo $ID
}

do_dependencies() {
    if [ -z "$(which curl)" ]; then
        die "curl not installed. Please install."
    fi
    if [ -z "$(which jq)" ]; then
        die "JQ not installed. Please install."
    fi
}

do_init_check() {
    WEAVE_CONNECTIONS=$(ssh $SSH_OPTS -i $KEY $USER@${AGENTS[0]} 'weave status connections | wc -l')
    EXPECTED=${#AGENTS[@]}
    if [ "$WEAVE_CONNECTIONS" -ne "$EXPECTED" ]; then
        die "Weave hasn't formed a cluster. There should be $EXPECTED hosts, but there are $WEAVE_CONNECTIONS. Have you installed? Look at the help."
    fi
}

############## End Helpers ###################

############## Start Commands ###################

do_install() {
    WEAVE_CONNECTIONS=$(ssh $SSH_OPTS -i $KEY $USER@${AGENTS[0]} 'weave status connections | wc -l')
    if [ $WEAVE_CONNECTIONS -lt 3 ]; then
        info "Installing Weave"
        # Provision Weave CNI
        for HOST in ${MASTERS[*]}
        do
            verbose "Provisioning Weave CNI on $HOST"
            scp $SSH_OPTS -i $KEY $SCRIPT_DIR/provisionWeaveCNI.sh $USER@$HOST:~;
            ssh $SSH_OPTS -i $KEY $USER@$HOST ./provisionWeaveCNI.sh;
        done;

        for HOST in ${AGENTS[*]}
        do
            verbose "Provisioning Weave CNI on $HOST"
            scp $SSH_OPTS -i $KEY $SCRIPT_DIR/provisionWeaveCNI.sh $USER@$HOST:~;
            ssh $SSH_OPTS -i $KEY $USER@$HOST ./provisionWeaveCNI.sh ${MASTERS[0]};
            ssh $SSH_OPTS -i $KEY $USER@$HOST sudo service mesos-slave restart
        done;

        # Wait for Agents to come back online
        info "Wating for agents to come back online"
        sleep 30
    else
        info "Skipping weave provisioning. Already running."
    fi

    if [ -n "$(curl -s -X GET -H "Content-type: application/json" $MASTER:8080/v2/apps/mesos-dns | grep "does not exist")" ]; then
        info "Installing mesos-dns"
        # Provision Mesos DNS
        for HOST in ${AGENTS[*]}
        do
            verbose "Provisioning Mesos DNS on $HOST"
            scp $SSH_OPTS -i $KEY $SCRIPT_DIR/provisionMesosDns.sh $USER@$HOST:~;
            ssh $SSH_OPTS -i $KEY $USER@$HOST ./provisionMesosDns.sh provision ${MASTERS[0]};
        done;

        ssh $SSH_OPTS -i $KEY $USER@${AGENTS[0]} ./provisionMesosDns.sh launch ${MASTERS[0]};

        # Wait for DNS to come online
        wait_task_running "mesos-dns"
    else
        info "Skipping DNS provisioning. Already running."
    fi
}

do_uninstall() {
    info "Stopping Weave"
    for HOST in ${MASTERS[*]}
    do
        if [ -n "$(ssh $SSH_OPTS -i $KEY $USER@$HOST which weave)" ]; then
            verbose "Stopping Weave CNI on $HOST"
            ssh $SSH_OPTS -i $KEY $USER@$HOST rm -f provisionWeaveCNI.sh
            ssh $SSH_OPTS -i $KEY $USER@$HOST sudo weave stop
            ssh $SSH_OPTS -i $KEY $USER@$HOST sudo weave reset --force
            ssh $SSH_OPTS -i $KEY $USER@$HOST sudo rm -f /usr/local/bin/weave
        else
            verbose "Not running on $HOST"
        fi
    done;

    for HOST in ${AGENTS[*]}
    do
        if [ -n "$(ssh $SSH_OPTS -i $KEY $USER@$HOST which weave)" ]; then
            verbose "Stopping Weave CNI on $HOST"
            ssh $SSH_OPTS -i $KEY $USER@$HOST rm -f provisionWeaveCNI.sh
            ssh $SSH_OPTS -i $KEY $USER@$HOST sudo weave stop
            ssh $SSH_OPTS -i $KEY $USER@$HOST sudo rm -f /usr/local/bin/weave
            ssh $SSH_OPTS -i $KEY $USER@$HOST sudo service mesos-slave restart
        else
            verbose "Not running on $HOST"
        fi
    done;

    info "Stopping mesos-dns"
    STATUS=$(task_status "mesos-dns")
    if [ -n "$STATUS" ] ; then
        ssh $SSH_OPTS -i $KEY $USER@${AGENTS[0]} ./provisionMesosDns.sh stop ${MASTERS[0]};
    else
        verbose "Mesos DNS not running on cluster"
    fi

    for HOST in ${AGENTS[*]}
    do
        EXISTS=$(ssh $SSH_OPTS -i $KEY $USER@$HOST "test -e provisionMesosDns.sh && echo 1 || echo 0")
        if [ $EXISTS -eq 1 ]; then
            verbose "Stopping Mesos DNS on $HOST"
            ssh $SSH_OPTS -i $KEY $USER@$HOST rm -f provisionMesosDns.sh
        else
            verbose "Not running on $HOST"
        fi
    done;
}

do_start() {
    info "Starting services"
    verbose "Starting edge-router"
    # Provision Edge router first, so that it is always on all machines.
    curl -s -X POST -H "Content-type: application/json" ${MASTERS[0]}:8080/v2/apps -d '{
      "id": "edge-router",
      "cmd": "while ! ping -c1 front-end.mesos-executeinstance.weave.local &>/dev/null; do : sleep 5; echo .; done ; sleep 10 ; echo \"Starting traefik\" ; sed -i \"s/front-end/front-end.mesos-executeinstance.weave.local/g\" /etc/traefik/traefik.toml ; traefik",
      "cpus": 0.2,
      "mem": 512,
      "disk": 0,
      "instances": 3,
      "constraints": [["hostname", "UNIQUE"]],
      "container": {
        "docker": {
          "image": "weaveworksdemos/edge-router",
          "network": "HOST",
          "parameters": [],
          "privileged": true
        },
        "type": "DOCKER",
        "volumes": []
      },
      "portDefinitions": [
        {
          "port": 80,
          "protocol": "tcp",
          "name": "80"
        }
      ],
      "env": {},
      "labels": {}
    }'

    wait_task_running "edge-router"

    launch_service carts-db      "echo ok"                                       mongo                               --no-shell
    launch_service orders-db    "echo ok"                                       mongo                               --no-shell
    launch_service catalogue-db "echo ok"                                       weaveworksdemos/catalogue-db        --no-shell ", \\\"MYSQL_ALLOW_EMPTY_PASSWORD\\\": \\\"true\\\", \\\"MYSQL_DATABASE\\\": \\\"socksdb\\\""
    launch_service user-db      "echo ok"                                       weaveworksdemos/user-db             --no-shell
    launch_service rabbitmq     "echo ok"                                       rabbitmq:3.6.8                          --no-shell

    launch_service shipping     "java -Xms64m -Xmx128m -XX:PermSize=32m -XX:MaxPermSize=64m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -jar ./app.jar --port=80 --spring.rabbitmq.host=rabbitmq.mesos-executeinstance.weave.local"                     weaveworksdemos/shipping    --shell
    launch_service orders       "java -Xms64m -Xmx128m -XX:PermSize=32m -XX:MaxPermSize=64m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -jar ./app.jar --port=80 --db=orders-db.mesos-executeinstance.weave.local --domain=mesos-executeinstance.weave.local --logging.level.works.weave=DEBUG"    weaveworksdemos/orders   --shell
    launch_service catalogue    "./app -port=80 -DSN=catalogue_user:default_password@tcp\(catalogue-db.mesos-executeinstance.weave.local:3306\)/socksdb"                                    weaveworksdemos/catalogue   --shell
    launch_service carts        "java -Xms64m -Xmx128m -XX:PermSize=32m -XX:MaxPermSize=64m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -jar ./app.jar --port=80 --db=carts-db.mesos-executeinstance.weave.local --logging.level.works.weave=DEBUG"      weaveworksdemos/carts       --shell
    launch_service payment      "echo ok"                                                                                                                                                   weaveworksdemos/payment     --no-shell
    launch_service front-end    "npm start -- --domain=mesos-executeinstance.weave.local"                                                                                                   weaveworksdemos/front-end   --shell
    launch_service user         "./user -port=80 -link-domain=user.mesos-executeinstance.weave.local -mongo-host=user-db.mesos-executeinstance.weave.local:27017"                           weaveworksdemos/user        --shell
}

do_stop() {
    info "Stopping services"
    id=$(get_id "edge-router")
    if [ -n "$id" ] ; then
        verbose "Stopping edge router"
        curl -X DELETE -H "Content-type: application/json" ${MASTERS[0]}:8080/v2/apps/edge-router
    fi
    for SERVICE in ${SERVICES[*]} ; do
        id=$(get_id $SERVICE)
        if [ -n "$id" ] ; then
            verbose "Stopping $SERVICE"
            curl -XPOST http://${MASTERS[0]}:5050/master/teardown -d "frameworkId=$id"
        fi
    done;
}

do_status() {
    REPORT="Service\tStatus\n-------\t------\n"
    SORT_SERVICES=$(printf '%s\n' "${SERVICES[@]}" | sort)
    for SERVICE in ${SORT_SERVICES[*]} ; do
        STATUS=$(task_status $SERVICE)
        if [ -z $STATUS ] ; then
            STATUS="NOT_RUNNING"
        fi
        REPORT+="$SERVICE\t$STATUS\n"
    done;
    echo $REPORT | column -t
}

############## End Commands ###################

do_dependencies
COMMAND="${args}"
case "$COMMAND" in
  install)
    do_install
    ;;
  uninstall)
    do_stop
    do_uninstall
    ;;
  start)
    do_init_check
    do_start
    ;;
  stop)
    do_stop
    ;;
  status)
    do_status
    ;;
  *)
    do_usage
    ;;
esac

# Exit cleanly
safeExit
