terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.6.1"
    }
  }
}

provider "kubernetes" {
  host                   = "https://${var.endpoint}"
  token                  = var.access_token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

resource "kubernetes_namespace" "sock_shop" {
  metadata {
    name = "sock-shop"
  }
}

# module "app-carts" {
#   source    = "../app"
#   name      = "carts"
#   image     = "weaveworksdemos/carts:0.4.8"
#   namespace = kubernetes_namespace.sock_shop.metadata.0.name
#   env = [
#     {
#       name  = "JAVA_OPTS"
#       value = "-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false"
#     }
#   ]
#   capabilities_add = ["NET_BIND_SERVICE"]
#   cpu              = ["100m", "300m"]
#   memory           = ["200Mi", "500Mi"]
# }

# module "carts-db" {
#   source           = "../app"
#   name             = "carts-db"
#   image            = "mongo:5.0.3"
#   namespace        = kubernetes_namespace.sock_shop.metadata.0.name
#   port             = 27017
#   capabilities_add = ["CHOWN", "SETGID", "SETUID"]
#   run_as_non_root  = false
#   cpu              = ["100m", "300m"]
#   memory           = ["200Mi", "500Mi"]
# }