declare -a arr=("master1" "node1" "node2")

## now loop through the above array
for i in "${arr[@]}"
do
 cd $i
 vagrant up
 vagrant provision
 cd ..
done
