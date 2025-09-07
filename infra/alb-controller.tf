# 1. IAM Role for the Controller (with IRSA trust)
resource "aws_iam_role" "aws_lb_controller" {
  name = "${var.cluster_name}-aws-lb-controller"

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
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

# 2. Download the official IAM policy for AWS Load Balancer Controller
data "http" "aws_lb_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.9.1/docs/install/iam_policy.json"
}

# 3. Create the IAM Policy
resource "aws_iam_policy" "aws_lb_controller" {
  name        = "${var.cluster_name}-AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = data.http.aws_lb_controller_policy.response_body
}

# 4. Attach the policy to the IAM Role
resource "aws_iam_role_policy_attachment" "aws_lb_controller_attach" {
  role       = aws_iam_role.aws_lb_controller.name
  policy_arn = aws_iam_policy.aws_lb_controller.arn
}

# 5. Kubernetes Service Account with Role Annotation
resource "kubernetes_service_account" "aws_lb_controller" {
  #depends_on = [aws_eks_access_policy_association.cluster_admin]
  depends_on = [time_sleep.wait_for_rbac]

  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller.arn
    }
    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }
}

# 6. Deploy the Controller (Helm)
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  # v2.8.1 and this line => port=0 error
  #version    = "1.9.1" # Example version — check latest compatible with your EKS version
  version = "1.10.0" # 👈 chart that deploys v2.9.1 controller
  depends_on = [
    kubernetes_service_account.aws_lb_controller,
    aws_iam_role_policy_attachment.aws_lb_controller_attach
  ]

  values = [
    yamlencode({
      clusterName = var.cluster_name
      serviceAccount = {
        create = false
        name   = "aws-load-balancer-controller"
      }
      region = var.region
      vpcId  = module.vpc.vpc_id
    })
  ]

  wait    = true # wait for pods to be ready
  timeout = 600  # allow up to 10 minutes
}
