variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "static-go-app"
}

variable "cluster_version" {
  type = string
  # pick a supported version for your region
  default = "1.32"
}
