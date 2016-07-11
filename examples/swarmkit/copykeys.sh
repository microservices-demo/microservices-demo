
declare -a arr=("master1" "node1" "node2")

## now loop through the above array
for i in "${arr[@]}"
do
  echo "setting up $i"
  cd $i
  echo "pwd `pwd`"
  export SSH_KEY=$(vagrant ssh-config | grep IdentityFile | awk '{print $2}' |  sed "s/\"//g")
  export IP=$(cat Vagrantfile | grep "ip:" | awk '{print $4}' | sed "s/\"//g")
  echo $SSH_KEY
  echo $IP
  ssh-add $SSH_KEY
  ssh-copy-id   vagrant@$IP
  cd ..
done
 
