# Deletes all the Sock Shop apps
# Automatically detects correct namespace

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

echo "Deleting Sock Shop apps in namespace: ${NAMESPACE}"

apc app delete user-sim --batch
apc app delete front-end --batch
apc app delete carts --batch
apc app delete carts-db --batch
apc app delete catalogue --batch
apc app delete catalogue-db --batch
apc app delete orders --batch
apc app delete orders-db --batch
apc app delete payment --batch
apc app delete shipping --batch
apc app delete queue-master --batch
apc app delete rabbitmq --batch
apc app delete user --batch
apc app delete user-db --batch
apc app delete zipkin --batch

# List the remaining apps to verify that there are none.
echo "Here are the remaining apps in namespace: ${NAMESPACE}"
apc app list

# Delete the sockshop-network too
echo "Deleting the sockshop network in namespace: ${NAMESPACE}"
apc network delete sockshop-network -- batch
