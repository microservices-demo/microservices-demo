# Stops all the Sock Shop apps

# Set namespace to user's default namespace
apc namespace -d

# append /sockshop to user's default namespace returned by apc namespace
OUT=`apc namespace`
NAMESPACE=`echo $OUT | cut -f3 -d" " | sed "s/'//g"`/sockshop
echo ${NAMESPACE}

# Change NAMESPACE if you don't like the default generated above
# But if you change it here, you'll need to change it in other scripts
#NAMESPACE=

# set actual namespace to $NAMESPACE
apc namespace ${NAMESPACE}

echo "Stopping Sock Shop apps in namespace: ${NAMESPACE}"

apc app stop user-sim
apc app stop front-end
apc app stop orders
apc app stop orders-db
apc app stop carts
apc app stop carts-db
apc app stop catalogue
apc app stop catalogue-db
apc app stop user
apc app stop user-db
apc app stop payment
apc app stop shipping
apc app stop queue-master
apc app stop rabbitmq
apc app stop zipkin

# List the apps to verify they are all stopped
apc app list
