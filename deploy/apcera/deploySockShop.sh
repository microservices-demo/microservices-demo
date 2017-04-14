# deploys the Sock Shop apps in targeted cluster
# Note that the first time you run this against a cluster could be slower
# than following times since none of the docker layers will be cached

# The code below will set the CLUSTER and NAMESPACE variables for you.
# These are used in the sockshop-docker.json Multi-Resource Manifest file.

# Set namespace to user's default namespace
apc namespace -d

# Run apc target command and parse results to determine current cluster
OUT=`apc target`
CLUSTER=`echo $OUT | cut -f2 -d" " | sed 's/[http[s]*:\/\///' | sed 's/]//' | cut -f1 -d:`

# append /sockshop to user's default namespace returned by apc target
NAMESPACE=`echo $OUT | cut -f9 -d" " | sed 's/"//g'`/sockshop

# echo the variables that were set automatically
echo Setting CLUSTER to $CLUSTER
echo Setting NAMESPACE to $NAMESPACE

# Change NAMESPACE if you don't like the default generated above
# But if you change it here, you'll need to change it in other scripts
# Also, if you are not an admin user, you might need policy modifications
#NAMESPACE=

# set actual namespace to the targeted namespace
apc namespace ${NAMESPACE}

# This command loads all the Docker images from the sockshop-docker.json manifest file
apc manifest deploy sockshop-docker.json -- --NAMESPACE ${NAMESPACE} --CLUSTER ${CLUSTER}

# Add affinity tags to the main services to keep them with their databases
apc app attract carts --to carts-db --hard  --batch --restart --silent
apc app attract catalogue --to catalogue-db --hard  --batch --restart --silent
apc app attract orders --to orders-db --hard  --batch --restart --silent
apc app attract user --to user-db --hard  --batch --restart --silent

# Start the apps
./startSockShop.sh
