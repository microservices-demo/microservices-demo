variable "project_id"{
  default = "gd-gcp-gridu-devops-t1-t2"
}

variable "region" {
  default = "europe-west2"
}

variable "availability_zone" {
  default = "europe-west2-a"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "dev_public_subnet_cidr_block" {
  default = "10.0.1.0/24"
}
variable "dev_private_subnet_cidr_block" {
  default = "10.0.2.0/24"
}

variable "stage_public_subnet_cidr_block" {
  default = "10.0.3.0/24"
}
variable "stage_private_subnet_cidr_block" {
  default = "10.0.4.0/24"
}

variable "prod_public_subnet_cidr_block" {
  default = "10.0.5.0/24"
}
variable "prod_private_subnet_cidr_block" {
  default = "10.0.6.0/24"
}