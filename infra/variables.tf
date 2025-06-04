variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "cidr_block" {
  type    = string
  default = "10.10.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "go-app-static-eks"
}

variable "tags" {
  type = map(string)
  default = {
    terraform  = "true"
    kubernetes = "go-app-static"
  }
  description = "Tags to apply to all resources"
}

variable "cluster_name" {
  type    = string
  default = "go-app-static"

}

variable "eks_version" {
  type        = string
  default     = "1.32"
  description = "EKS version"
}
