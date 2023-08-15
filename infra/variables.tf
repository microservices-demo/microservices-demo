variable "project_id" {
  type        = string
  default     = "gd-gcp-gridu-devops-t1-t2"
  description = "ID of the project"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Region for project"
}

variable "public_subnet" {
  type        = string
  default     = "nkuzman-public-subnet"
  description = "Public subnet"
}

variable "private_subnet" {
  type        = string
  default     = "nkuzman-private-subnet"
  description = "Private subnet"
}