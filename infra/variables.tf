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

output "kubeconfig_update_command" {
  description = "Command to update kubeconfig for this EKS cluster"
  value       = "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}"
}

/*
terraform apply \
  -var="eks_admin_principal_arn=arn:aws:iam::183056140671:user/devninja"

# or:
export TF_VAR_eks_admin_principal_arn="arn:aws:iam::183056140671:user/devninja"

N.B. source .env won't work!
*/
variable "eks_admin_principal_arn" {
  type        = string
  description = "IAM user or role ARN to be granted cluster admin via EKS Access Policy"
}
