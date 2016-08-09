#!/usr/bin/env bash
#
# Check Health of each service
######################################

HOSTS="localhost edge-router catalogue/health accounts cart orders shipping/shipping queue-master payment/health login/health"

for host in ${HOSTS}; do
 status="$(curl --write-out %{http_code} --silent --output /dev/null $host)"
 if [ "$status" == "200" ]; then
 	echo "Service: $host is OK"
 else
 	echo "Service: $host failed with status: $status"
 fi
done