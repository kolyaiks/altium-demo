module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = "${var.company_name}-vpc"
  cidr = local.vpc_cidr
  azs = [
    data.aws_availability_zones.azs.names[0],
    data.aws_availability_zones.azs.names[1],
    data.aws_availability_zones.azs.names[2]
  ]
  public_subnets     = local.public_subnet_cidrs
  private_subnets    = local.private_subnet_cidrs
  enable_nat_gateway = true
  single_nat_gateway = true
}
