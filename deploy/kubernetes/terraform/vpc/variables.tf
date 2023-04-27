variable "region" {
  default = "eu-central-1"
}

variable "availability_zone" {
  default = "eu-central-1a"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnetwork_cidr_block" {
  default = "10.0.1.0/24"
}
variable "private_subnetwork_cidr_block" {
  default = "10.0.2.0/24"
}

variable "route_table_cidr_block" {
  default = "0.0.0.0/0"
}

