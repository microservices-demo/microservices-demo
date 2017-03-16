variable "aws_amis" {
  description = "The AMI to use for setting up the instances."
  default = {
    # Ubuntu Xenial 16.04 LTS
    "eu-west-1" = "ami-844e0bf7"
  }
}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "bastion_security_group" {
  description = "The id of the security group where the bastion host resides."
}

variable "instance_user" {
  description = "The user account to use on the instances to run the scripts."
  default     = "ubuntu"
}

variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "master_instance_type" {
  description = "The instance type to use for the Kubernetes master."
  default     = "m3.large"
}

variable "node_instance_type" {
  description = "The instance type to use for the Kubernetes nodes."
  default     = "m4.xlarge"
}

variable "nodecount" {
  description = "The number of nodes in the cluster."
  default     = "4"
}

variable "private_key_file" {
  description = "The private key for connection to the instances as the user. Corresponds to the key_name variable."
}

variable "weave_cloud_token" {
  description = "Token from Weave Cloud"
}
