variable "name" {
  type        = string
  description = "Application name. It will be use for the deployment, service and labels"
}

variable "image" {
  type = string
}

variable "namespace" {
  type = string
}

variable "port" {
  type    = number
  default = 80
}

variable "env" {
  type    = list(map(string))
  default = []
}

variable "capabilities_add" {
  type    = list(string)
  default = []
}

variable "run_as_non_root" {
  type    = bool
  default = true
}

variable "cpu" {
  type    = list(string)
  default = []
}

variable "memory" {
  type    = list(string)
  default = []
}