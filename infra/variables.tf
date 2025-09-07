variable "tags" {
  type = map(string)
  default = {
    Project     = "static-go-app"
    Environment = "dev"
    Owner       = "team-ninjas"
    CostCenter  = "1234"
  }
}

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
