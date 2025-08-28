terraform {
  required_version = ">= 1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4" # or latest stable
    }
  }
}

provider "aws" {
  region = var.region
}

/*
Now your kubernetes_* resources (like kubernetes_service_account.cluster_autoscaler) will know how to talk to the real cluster instead of localhost.

╷
│ Error: Post "http://localhost/api/v1/namespaces/kube-system/serviceaccounts": dial tcp 127.0.0.1:80: connect: connection refused
│ 
│   with kubernetes_service_account.cluster_autoscaler,
│   on main.tf line 101, in resource "kubernetes_service_account" "cluster_autoscaler":
│  101: resource "kubernetes_service_account" "cluster_autoscaler" {
│ 
╵

*/
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

/*
We  must also configure helm to use the same cluster connection.

╷
│ Error: installation failed
│ 
│   with helm_release.cluster_autoscaler,
│   on main.tf line 114, in resource "helm_release" "cluster_autoscaler":
│  114: resource "helm_release" "cluster_autoscaler" {
│ 
│ Kubernetes cluster unreachable: invalid configuration: no configuration has been provided, try setting KUBERNETES_MASTER environment variable
╵

*/

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
