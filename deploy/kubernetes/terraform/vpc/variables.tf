variable "region" {
  default = "us-west-1"
}

variable "availability_zone" {
  default = "us-west-1b"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnetwork_cidr_block" {
  default = "10.0.0.0/24"
}

variable "route_table_cidr_block" {
  default = "0.0.0.0/0"
}

