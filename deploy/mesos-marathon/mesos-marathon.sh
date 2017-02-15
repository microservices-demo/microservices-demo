#!/usr/bin/env bash

version="1.0.0"

SCRIPT_DIR=`dirname "$0"`
SCRIPT_NAME=`basename "$0"`
USER=ubuntu
MASTERS=($MASTER)
AGENTS=($SLAVE0 $SLAVE1 $SLAVE2)
SSH_OPTS=-oStrictHostKeyChecking=no

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
tag="latest"

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

Starts the weavedemo microservices demo on Mesos using Marathon.

Caveats: This is using a RC version of Mesos, and may not work in the future. This was developed on AWS, so may not work on other services.

 ${bold}Commands:${reset}
  install           Install all required services on the Mesos hosts. Must install before starting.
  uninstall         Removes all installed services
  start             Starts the demo application services. Must already be installed.
  stop              Stops the demo application services

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
    -c|--cpu) shift; cpu=${1} ;;
    -m|--mem) shift; mem=${1} ;;
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
            scp $SSH_OPTS -i $KEY $SCRIPT_DIR/provisionWeave.sh $USER@$HOST:~;
            ssh $SSH_OPTS -i $KEY $USER@$HOST ./provisionWeave.sh;
        done;

        for HOST in ${AGENTS[*]}
        do
            verbose "Provisioning Weave CNI on $HOST"
            scp $SSH_OPTS -i $KEY $SCRIPT_DIR/provisionWeave.sh $USER@$HOST:~;
            ssh $SSH_OPTS -i $KEY $USER@$HOST ./provisionWeave.sh ${MASTERS[0]};
            ssh $SSH_OPTS -i $KEY $USER@$HOST sudo service mesos-slave restart
        done;

        # Wait for Agents to come back online
        info "Wating for agents to come back online"
        sleep 15
    else
        info "Skipping weave provisioning. Already running."
    fi
}

do_uninstall() {
    info "Stopping Weave"
    for HOST in ${MASTERS[*]}
    do
        if [ -n "$(ssh $SSH_OPTS -i $KEY $USER@$HOST which weave)" ]; then
            verbose "Stopping Weave CNI on $HOST"
            ssh $SSH_OPTS -i $KEY $USER@$HOST rm -f provisionWeave.sh
            ssh $SS_OPTS -i $KEY $USER@$HOST sudo weave stop
            ssh $SSH_OPTS -i $KEY $USER@$HOST sudo rm -f /usr/local/bin/weave
        else
            verbose "Not running on $HOST"
        fi
    done;

    for HOST in ${AGENTS[*]}
    do
        if [ -n "$(ssh $SSH_OPTS -i $KEY $USER@$HOST which weave)" ]; then
            verbose "Stopping Weave CNI on $HOST"
            ssh $SSH_OPTS -i $KEY $USER@$HOST rm -f provisionWeave.sh
            ssh $SSH_OPTS -i $KEY $USER@$HOST sudo weave stop
            ssh $SSH_OPTS -i $KEY $USER@$HOST sudo rm -f /usr/local/bin/weave
            ssh $SSH_OPTS -i $KEY $USER@$HOST sudo service mesos-slave restart
        else
            verbose "Not running on $HOST"
        fi
    done;
}

do_start() {
    info "Starting services"
    curl -XPOST -H 'Content-Type:application/json' -d @marathon.json ${MASTERS[0]}:8080/v2/groups
}

do_stop() {
    info "Stopping services"
    curl -XDELETE ${MASTERS[0]}:8080/v2/groups/weave-demo\?force=true
}

do_status() {
    curl ${MASTERS[0]}:8080/v2/groups/weave-demo\?force=true
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
