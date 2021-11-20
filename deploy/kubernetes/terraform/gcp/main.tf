module "gke-cluster" {
  source     = "./modules/gke"
  node_count = 1
}

# module "sock-shop-k8s" {
#   source                 = "./modules/k8s/global"
#   endpoint               = module.gke-cluster.kubernetes_cluster_endpoint
#   cluster_ca_certificate = module.gke-cluster.kubernetes_cluster_cluster_ca_certificate
#   access_token           = module.gke-cluster.kubernetes_cluster_cluster_access_token
# }