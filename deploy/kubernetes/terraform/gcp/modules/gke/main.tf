terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.0.0"
    }
  }
}

provider "google" {
  project = "dsp-sock-shop-juan"
  region  = "us-central1"
  zone    = "us-central1-c"
}

data "google_client_config" "default" {}
resource "google_service_account" "default" {
  account_id   = "${terraform.workspace}-sa-sock-shop-id"
  display_name = "${terraform.workspace} Service Account. Sock Shop"
}

resource "google_container_cluster" "primary" {
  name     = "${terraform.workspace}-gke-sock-shop"
  location = "us-central1"

  node_pool {
    initial_node_count = var.node_count
    node_config {
      image_type = "COS_CONTAINERD"
      # gcloud machine types: https://cloud.google.com/compute/docs/machine-types
      machine_type = "e2-standard-2"

      # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
      service_account = google_service_account.default.email
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
      metadata = {
        disable-legacy-endpoints = "true"
      }
    }
  }
}