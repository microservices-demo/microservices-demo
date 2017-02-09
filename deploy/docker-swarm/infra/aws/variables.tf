variable "aws_region" {
  default = "eu-central-1"
}

variable "num_nodes" {
  description = "Number of nodes besides master"
  default = "2"
}

variable "private_key_name" {
    description = "Name of private_key"
    default = "docker-swarm"
}

variable "private_key_path" {
  description = "Path to file containing private key"
  default     = "~/.ssh/docker-swarm.pem"
}

variable "instance_type" {
  description = "AWS Instance size"
  default     = "t2.micro"
}
