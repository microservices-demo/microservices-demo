Notes...


git clone https://github.com/weaveworks/weaveDemo.git
git checkout kubernetes

cd weaveDemo/kubernetes

sed -i 's/replicas: 2/replicas: 1/g' *

cd ..

kubectl create -f kubernetes/