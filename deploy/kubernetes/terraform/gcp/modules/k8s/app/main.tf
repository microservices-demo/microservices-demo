terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.6.1"
    }
  }
}

resource "kubernetes_deployment" "deploy" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      name = var.name
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        name = var.name
      }
    }
    template {
      metadata {
        labels = {
          name = var.name
        }
      }
      spec {
        container {
          name  = var.name
          image = var.image
          dynamic "env" {
            for_each = var.env
            content {
              name  = env.value["name"]
              value = env.value["value"]
            }
          }
          resources {
            requests = {
              "cpu"    = length(var.cpu) >= 1 ? var.cpu[0] : null
              "memory" = length(var.memory) >= 1 ? var.memory[0] : null
            }
            limits = {
              "cpu"    = length(var.cpu) == 2 ? var.cpu[1] : null
              "memory" = length(var.memory) == 2 ? var.memory[1] : null
            }
          }
          port {
            container_port = var.port
          }
          security_context {
            run_as_non_root = var.run_as_non_root
            run_as_user     = var.run_as_non_root ? "10001" : null
            capabilities {
              drop = ["all"]
              add  = var.capabilities_add
            }
            read_only_root_filesystem = true
          }
          volume_mount {
            mount_path = "/tmp"
            name       = "tmp-volume"
          }
        }
        volume {
          name = "tmp-volume"
          empty_dir {
            medium = "Memory"
          }
        }
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "svc" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = {
      name = var.name
    }
  }
  spec {
    port {
      port        = var.port
      target_port = var.port
    }
    selector = {
      name = var.name
    }
  }
}