#!/usr/bin/env bash

version="1.0.0"
SCRIPT_DIR=`dirname "$0"`
SCRIPT_NAME=`basename "$0"`
IMAGES=("weaveworksdemos/shipping" "weaveworksdemos/orders" "weaveworksdemos/catalogue" "weaveworksdemos/user" "weaveworksdemos/carts" "weaveworksdemos/payment" "weaveworksdemos/catalogue-db" "weaveworksdemos/user-db" "weaveworksdemos/front-end" "weaveworksdemos/edge-router")
MARATHON_FILE=../mesos-marathon/marathon.json
if [[ "$OSTYPE" == "darwin"* ]]; then
    DOCKER_CMD=docker
    WEAVE_CMD=weave
    MINIMESOS_CMD=minimesos
else
    DOCKER_CMD="sudo docker"
    WEAVE_CMD="sudo weave"
    MINIMESOS_CMD="sudo minimesos"
fi

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

Starts the weavedemo microservices application on minimesos.

Requirements: Docker/Docker for mac, weave and minimesos must be installed.

 ${bold}Commands:${reset}
  start             Starts weave, minimesos and the demo application
  stop              Stops weave, minimesos and the demo application

 ${bold}Options:${reset}
  --force           Skip all user interaction.  Implied 'Yes' to all actions.
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
    -t|--tag) shift; tag=${1} ;;
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

do_dependencies() {
    if [ -z "$(which curl)" ]; then
        die "curl not installed. Please install."
    fi
    if [ -z "$(which weave)" ]; then
        die "weave not installed. Please install."
    fi
    if [ -z "$(which minimesos)" ]; then
        die "minimesos not installed. Please install."
    fi
}

status_code() {
    if [ -z $1 ] ; then
        die "No URL. Please pass URL to status_code method."
    fi
    curl -o /dev/null --silent --head --write-out '%{http_code}\n' $1
}

minimesos_info() {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        $MINIMESOS_CMD info | grep export
    else
        $MINIMESOS_CMD info | sed -e 's/172.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}/localhost/g' | grep export
    fi
}

zookeeper_info() {
    $MINIMESOS_CMD info | grep MINIMESOS_ZOOKEEPER | grep export
}

routable() {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
            ping -c1 -W1 $1 >/dev/null 2>&1 ; echo $?
    elif [[ "$OSTYPE" == "darwin"* ]]; then
            ping -c1 -W100 $1 >/dev/null 2>&1 ; echo $?
    else
            ping -c1 $1 >/dev/null 2>&1 ; echo $?
    fi
}

aws_instance() {
    curl -sq http://instance-data >/dev/null ; echo $?
}

############## End Helpers ###################

############## Start Commands ###################

do_start() {
    if [[ -n $($DOCKER_CMD ps | grep -E 'weaveproxy|minimesos|weaveworksdemo') ]] ; then
        die "Some services are already running. Please run 'stop' first"
    fi

    info "Pre-pulling containers. This may take a while..."
    $DOCKER_CMD pull mesosphere/marathon:v1.3.5 >/dev/null
    $DOCKER_CMD pull mongo >/dev/null
    $DOCKER_CMD pull rabbitmq:3.6.8 >/dev/null
    for SERVICE in ${IMAGES[*]} ; do
        verbose "Pulling $SERVICE"
        $DOCKER_CMD pull $SERVICE >/dev/null
    done;

    info "Starting weave"
    $WEAVE_CMD launch

    info "Starting minimesos"
    $MINIMESOS_CMD init || true
    $MINIMESOS_CMD up

    eval $(minimesos_info)
    eval $(zookeeper_info)
    if [[ $(status_code $MINIMESOS_MASTER) == "200" ]] ; then
        success "Minimesos is running"
    else
        die "Minimesos does not appear to be running or is inaccessible. Try running 'route' before running this if you're on OSX."
    fi

    info "Killing unnecessary processes"
    $DOCKER_CMD rm -f $($DOCKER_CMD ps | grep registrator | awk '{print $1}')
    $DOCKER_CMD rm -f $($DOCKER_CMD ps | grep consul | awk '{print $1}')

    verbose "Killing old mesos-agent"
    ID=$($DOCKER_CMD ps | grep mesos-agent | awk '{print $1}')
    OLD_NAME=$($DOCKER_CMD inspect --format '{{ .Name}}' $ID | tr -d /)
    $DOCKER_CMD rm -f $ID

    verbose "Starting new weave-enabled mesos-agent"
    $DOCKER_CMD run \
        -d \
        --name=$OLD_NAME \
        -v=/var/run/weave/weave.sock:/var/run/weave/weave.sock \
        -v=/sys/fs/cgroup:/sys/fs/cgroup \
        containersol/mesos-agent:1.0.0-0.1.0 \
            --master=$MINIMESOS_ZOOKEEPER \
            --containerizers=docker,mesos \
            --resources="ports(*):[80-80, 31000-32000];cpus(*):12;mem(*):20960" \
            --docker_socket=/var/run/weave/weave.sock \
            --work_dir=/var/lib/mesos/agent

    info "Wait for Zookeeper, Mesos and Marathon to cluster."

    while [[ $(status_code $MINIMESOS_MARATHON) != "302" ]] ; do
        info "Wating for Marathon to respond ok"
        sleep 1;
    done

    info "Starting services"
    curl -q -XPOST -H 'Content-Type:application/json' -d @$MARATHON_FILE $MINIMESOS_MARATHON/v2/groups

    if [ $(aws_instance) == 0 ] ; then
        UI=$(curl -q http://instance-data/latest/meta-data/public-ipv4)
    elif [[ "$OSTYPE" == "linux-gnu" ]]; then
        UI=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' | head -n 1)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        UI=localhost
    else
        UI=$(hostname --ip-address)
    fi

    success "Finished. Shortly, you will find the UI on $UI and scope on $UI:4040"
}

do_stop() {
    if [[ -n $($DOCKER_CMD ps | grep marathon) ]] ; then
        eval $(minimesos_info)
        if [ $(routable $MINIMESOS_MARATHON_IP) ] ; then
            info "Stopping services"
            curl -XDELETE $MINIMESOS_MARATHON/v2/groups/weave-demo\?force=true
        else
            die "Marathon is running, but not routable. Try running 'route'"
        fi
    fi

    info "Stopping minimesos"
    $MINIMESOS_CMD destroy

    info "Stopping weave"
    $WEAVE_CMD stop
}

do_status() {
    curl $MINIMESOS_MARATHON/v2/groups/weave-demo\?force=true
}

############## End Commands ###################

do_dependencies
COMMAND="${args}"
case "$COMMAND" in
  start)
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
