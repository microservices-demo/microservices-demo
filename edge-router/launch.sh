#!/usr/bin/env sh
set -x

DOMAIN="${1}"
SCRIPT_NAME=`basename "$0"`
SCRIPT_DIR=`dirname "$0"`

if [ -z "$DOMAIN" ]; then
    echo "No domain passed, assuming no domain."
else
    echo "Setting domain to $DOMAIN"
    sed 's/.*proxy_pass.*/      proxy_pass      http:\/\/front-end.'$DOMAIN':8079;/' /etc/nginx/nginx.conf
fi

nginx -g "daemon off;"
