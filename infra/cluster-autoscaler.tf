# -----------------------------------------------------------
# IAM Role for Cluster Autoscaler (IRSA)
# -----------------------------------------------------------
resource "aws_iam_role" "cluster_autoscaler" {
  name = "${var.cluster_name}-cluster-autoscaler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "cluster_autoscaler" {
  name = "${var.cluster_name}-cluster-autoscaler-policy"
  role = aws_iam_role.cluster_autoscaler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      }
    ]
  })
}

# -----------------------------------------------------------
# Kubernetes Service Account for Cluster Autoscaler
# -----------------------------------------------------------
resource "kubernetes_service_account" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
    }
  }
}

# -----------------------------------------------------------
# Deploy Cluster Autoscaler with Helm
# -----------------------------------------------------------
/*
resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.37.0" # Match to your EKS version

  depends_on = [kubernetes_service_account.cluster_autoscaler]

  values = [
    yamlencode({
      autoDiscovery = {
        clusterName = var.cluster_name
      }
      awsRegion = var.region
      rbac = {
        serviceAccount = {
          create = false
          name   = "cluster-autoscaler"
        }
      }
      extraArgs = {
        balance-similar-node-groups = "true"
        skip-nodes-with-system-pods = "false"
        scale-down-unneeded-time    = "2m"
        scale-down-delay-after-add  = "2m"
      }
    })
  ]
}
*/

resource "local_file" "autoscaler_values" {
  filename = "${path.module}/cluster-autoscaler-values.yaml"
  content  = <<-EOT
    autoDiscovery:
      clusterName: ${var.cluster_name}
    awsRegion: ${var.region}
    rbac:
      serviceAccount:
        create: false
        name: cluster-autoscaler
    extraArgs:
      balance-similar-node-groups: "true"
      skip-nodes-with-system-pods: "false"
      scale-down-unneeded-time: "1m"       # default 10m
      scale-down-delay-after-add: "1m"     # default 10m
  EOT
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.37.0"

  depends_on = [kubernetes_service_account.cluster_autoscaler]

  values = [
    #file("${path.module}/cluster-autoscaler-values.yaml")
    local_file.autoscaler_values.content
  ]
}
