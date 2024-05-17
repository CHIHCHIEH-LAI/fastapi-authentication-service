module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  # Details
  name = var.vpc_name
  cidr = var.vpc_cidr
  azs = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  # NAT Gateway
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

