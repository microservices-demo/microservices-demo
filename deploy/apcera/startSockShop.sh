# Starts all the Sock Shop apps

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

echo "Starting Sock Shop apps in namespace: ${NAMESPACE}"

# If any of the apps have trouble connecting to other apps or
# databases, you could increase the sleep times below or add more of them.
# echoing of logs is suppressed here, but they can be viewed in the Apcera Web Console
# or with the apc app logs command
echo starting catalogue-db
apc app start catalogue-db --silent &
echo starting user-db
apc app start user-db --silent &
echo starting orders-db
apc app start orders-db --silent &
echo starting carts-db
apc app start carts-db --silent &
echo starting rabbitmq
apc app start rabbitmq --silent &
echo starting zipkin
apc app start zipkin --silent &
sleep 15
echo starting catalogue
apc app start catalogue --silent &
echo starting payment
apc app start payment --silent &
echo starting shipping
apc app start shipping --silent &
echo starting user
apc app start user --silent &
echo starting carts
apc app start carts --silent &
echo starting orders
apc app start orders --silent &
echo starting queue-master
apc app start queue-master --silent &
sleep 10
echo starting front-end
apc app start front-end --silent
sleep 10
echo starting user-sim
apc app start user-sim --silent

# List the apps to verify they are all started
apc app list
