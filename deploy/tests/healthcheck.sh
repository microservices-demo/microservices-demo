#!/usr/bin/env bash +x
#
# Check Health of each service
######################################
DOMAIN="$@"

HOSTS="localhost localhost/catalogue localhost/cart localhost/orders localhost/user"
GREEN=`tput setaf 2`
RED=`tput setaf 1`
RESET=`tput sgr0`

# FRONTEND/EDGE-ROUTER
for host in ${HOSTS}; do
 status="$(curl --cookie "logged_in=true" --write-out %{http_code} --silent --output /dev/null $host)"
 if [[ $status =~ 2.* ]]; then
 	echo "Service: $host is ${GREEN}[OK]${RESET}"
 else
 	echo "Service: $host failed with status: ${RED}$status${RESET}"
 fi
done

#CATALOGUE

#CART

#ORDERS

#USER
