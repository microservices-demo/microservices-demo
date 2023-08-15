provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc_network" {
  name = "nkuzman-vpc"
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = var.public_subnet
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.name

  private_ip_google_access = false
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = var.private_subnet
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.name

  private_ip_google_access = true
}
