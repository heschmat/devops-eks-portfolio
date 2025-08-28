module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs = ["${var.region}a", "${var.region}b"]
  # for internet-facing resources (e.g., load balancers)
  public_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  # for internal resources (e.g., EC2 instances, EKS worker nodes)
  private_subnets = ["10.0.64.0/19", "10.0.96.0/19"]

  enable_nat_gateway = true # so private subnets can reach the internet
  # save costs by creating just one NAT Gateway (instead of one per AZ).
  # Downside: introduces a single point of failure.
  single_nat_gateway = true

  # These are special AWS tags recognized by Kubernetes (specifically the AWS cloud provider for EKS).
  # Kubernetes automatically picks the right subnets for our services based on these tags.
  public_subnet_tags = {
    # for internet-facing ELBs (load balancers)
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Project = var.cluster_name
  }
}

/*
+------------------------------------------------------------+
|                        VPC: 10.0.0.0/16                    |
|                                                            |
|   🌐 Internet Gateway (IGW)                                |
|                |                                           |
|   +----------------------+    +----------------------+     |
|   | Public Subnet A      |    | Public Subnet B      |     |
|   | 10.0.0.0/19          |    | 10.0.32.0/19         |     |
|   | (k8s: ELB)           |    | (k8s: ELB)           |     |
|   +----------------------+    +----------------------+     |
|                |                       |                   |
|                +-----------+-----------+                   |
|                            |                               |
|                      🔄 NAT Gateway                        |
|                            |                               |
|   +----------------------+    +----------------------+     |
|   | Private Subnet A     |    | Private Subnet B     |     |
|   | 10.0.64.0/19         |    | 10.0.96.0/19         |     |
|   | (k8s: internal-ELB,  |    | (k8s: internal-ELB,  |     |
|   |  worker nodes)       |    |  worker nodes)       |     |
|   +----------------------+    +----------------------+     |
|                                                            |
+------------------------------------------------------------+
*/

# Do you also want me to extend this ASCII to show how EKS control plane and services (e.g., LoadBalancers, Pods) would map onto it?