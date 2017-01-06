#!/bin/sh -v

fluxctl set-config --file=flux.conf
for svc in cart-db cart catalogue catalogue-db front-end orders-db orders payment queue-master rabbitmq shipping user-db user; do
    fluxctl automate --service=sock-shop/$svc
done
