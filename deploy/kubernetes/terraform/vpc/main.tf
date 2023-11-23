provider "google" {
project = var.project_id
region = var.region
}

#Dev environment configuration
resource "google_compute_network" "amatic-dev-vpc" {
name = "amatic-dev-vpc"
auto_create_subnetworks = false

routing_mode = "GLOBAL"

}

resource "google_compute_subnetwork" "amatic_dev_public_subnet" {
name = "amatic-dev-public-subnet"
ip_cidr_range = var.dev_public_subnet_cidr_block

region = var.region
network = google_compute_network.amatic-dev-vpc.self_link
private_ip_google_access = false
}

resource "google_compute_subnetwork" "amatic_dev_private_subnet" {
name = "amatic-dev-private-subnet"
ip_cidr_range = var.dev_private_subnet_cidr_block

region = var.region
network = google_compute_network.amatic-dev-vpc.self_link
private_ip_google_access = true
}

#End of dev environment configuration

#Staging environment configuration
resource "google_compute_network" "amatic-stage-vpc" {
name = "amatic-stage-vpc"
auto_create_subnetworks = false

routing_mode = "GLOBAL"

}

resource "google_compute_subnetwork" "amatic_stage_public_subnet" {
name = "amatic-stage-public-subnet"
ip_cidr_range = var.stage_public_subnet_cidr_block

region = var.region
network = google_compute_network.amatic-stage-vpc.self_link
private_ip_google_access = false
}

resource "google_compute_subnetwork" "amatic_stage_private_subnet" {
name = "amatic-stage-private-subnet"
ip_cidr_range = var.stage_private_subnet_cidr_block

region = var.region
network = google_compute_network.amatic-stage-vpc.self_link
private_ip_google_access = true
}

#End of staging environment configuration

#Production environment configuration

resource "google_compute_network" "amatic-prod-vpc" {
name = "amatic-prod-vpc"
auto_create_subnetworks = false

routing_mode = "GLOBAL"

}

resource "google_compute_subnetwork" "amatic_prod_public_subnet" {
name = "amatic-prod-public-subnet"
ip_cidr_range = var.prod_public_subnet_cidr_block

region = var.region
network = google_compute_network.amatic-prod-vpc.self_link
private_ip_google_access = false
}

resource "google_compute_subnetwork" "amatic_prod_private_subnet" {
name = "amatic-prod-private-subnet"
ip_cidr_range = var.prod_private_subnet_cidr_block

region = var.region
network = google_compute_network.amatic-prod-vpc.self_link
private_ip_google_access = true
}

#End of production environment configuration
