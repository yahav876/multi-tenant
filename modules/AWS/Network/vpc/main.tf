module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name                  = var.vpc_name
  cidr                  = var.vpc_cidr
  azs                   = var.vpc_azs
  private_subnets       = var.private_subnet_cidr
  public_subnets        = var.public_subnet_cidr
  enable_nat_gateway    = var.enable_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  private_subnet_tags = var.private_subnet_tags
  public_subnet_tags  = var.public_subnet_tags
}
