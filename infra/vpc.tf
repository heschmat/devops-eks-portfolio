data "aws_availability_zones" "available" {
  state = "available"
}

module "eks-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = var.vpc_name
  cidr = var.cidr_block

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets = [cidrsubnet(var.cidr_block, 8, 110), cidrsubnet(var.cidr_block, 8, 120)]
  public_subnets  = [cidrsubnet(var.cidr_block, 8, 10), cidrsubnet(var.cidr_block, 8, 20)]

  create_igw = true

  enable_dns_hostnames = true

  # nat_gateway configuration
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  create_private_nat_gateway_route = true

  tags = var.tags
}
