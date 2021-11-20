# Create GKE - infrastructure
terraform workspace show
terraform init
terraform apply

# Google cloud connect to kubectl
gcloud auth login
gcloud container clusters get-credentials --zone us-central1 --project dsp-sock-shop-juan $(terraform workspace show)-gke-sock-shop

# rename cluster
kubectx gke-$(terraform workspace show)=gke_dsp-sock-shop-juan_us-central1_$(terraform workspace show)-gke-sock-shop

# Install service mesh and operators
istioctl install
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/addons/kiali.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/addons/jaeger.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/addons/extras/zipkin.yaml

# Install microservices
kubectl apply -f ../../manifests/.

# Apply load test
kubectl apply -f ../../manifests-loadtest/.