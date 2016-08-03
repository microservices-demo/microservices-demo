#!/bin/sh
if [ "$NAMESERVER" == "" ]; then
	export NAMESERVER=`cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}' | tr '\n' ' '`
fi

echo "Nameserver is: $NAMESERVER"

echo "Copying nginx config"
envsubst '$NAMESERVER' < nginx.conf.template > /etc/nginx.conf

echo "Using nginx config:"
echo "-------------------"
cat /etc/nginx.conf
echo "-------------------"

echo "Starting nginx"
nginx -c /etc/nginx.conf -g "daemon off;"
