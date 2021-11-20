# Infrastructure as Code with terraform

Create google cloud kubernetes cluster with default node pool

Experimental: Create kubernetes deployment and service with kubernetes provider from terraform (disable)

## Steps

1. Follow this [GCP terraform tutorial](https://learn.hashicorp.com/collections/terraform/gcp-get-started) to install terraform
1. Follow this [Configure gcloud SDK](https://learn.hashicorp.com/tutorials/terraform/gke) to configure `gcloud`
1. Configure gcloud
1. Run `terraform init`
1. Create new workspace `terraform workspace new blue`
1. Run `terraform plan`
1. Run `terraform apply` and then type "yes"
1. Check resources in google cloud in "Kubernetes Cluster"
1. Run `gcloud auth login` to get a token
1. Run `gcloud container clusters get-credentials --zone us-central1 --project dsp-sock-shop-juan $(terraform workspace show)-gke-sock-shop` to authenticate with your cluster. Replace project and zone according to your setup
1. Apply istio config `istioctl install`
1. Install istio operators
- `kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/addons/kiali.yaml`
- `kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/addons/jaeger.yaml`
- `kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/addons/prometheus.yaml`
- `kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/addons/extras/zipkin.yaml`
1. Apply manifests microservices `kubectl apply -f ../../manifests/.`
1. Apply load test manifests `kubectl apply -f ../../manifests-loadtest/.`
1. Last step is detroy the infrastructure with `terraform destroy`

## Istio operators dashboards

- **Kiali**. istioctl dashboard kiali
- **Prometheus**. istioctl dashboard prometheus
- **Grafana**. istioctl dashboard grafana
- **Jaeger**. istioctl dashboard jaeger
- **Zipkin**. istioctl dashboard zipkin

