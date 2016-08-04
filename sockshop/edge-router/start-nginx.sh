#!/bin/sh
if [ "$NAMESERVER" == "" ] ; then
	export NAMESERVER=`cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}' | tr '\n' ' '`
fi

echo "Nameserver is: $NAMESERVER"

if [ "$SERVICE" == "" ] ; then
    export SERVICE=front-end:8079
fi

echo "Service to proxy is: $SERVICE"

echo "Copying nginx config"
MYVARS='$NAMESERVER:$SERVICE'
envsubst "$MYVARS" < nginx.conf.template > /etc/nginx.conf

echo "Using nginx config:"
echo "-------------------"
cat /etc/nginx.conf
echo "-------------------"

echo "Starting nginx"
nginx -c /etc/nginx.conf -g "daemon off;"
