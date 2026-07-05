resource "aws_security_group" "alb" {
  name        = "${var.company_name}-alb-sg"
  description = "Security group for the ${var.company_name} ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP from allowed CIDR blocks"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_inbound_cidr_blocks
  }

  ingress {
    description = "Allow HTTPS from allowed CIDR blocks"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_inbound_cidr_blocks
  }

  egress {
    description = "Allow HTTP from ALB to web instances"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = local.private_subnet_cidrs
  }

  tags = {
    Name = "${var.company_name}-alb-sg"
  }
}

resource "aws_security_group" "ec2" {
  name        = "${var.company_name}-ec2-sg"
  description = "Security group for EC2 instances behind the ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow HTTP from ALB security group"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow HTTPS to package repository and secureweb.com"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.external_https_cidrs
  }

  dynamic "egress" {
    for_each = local.debug_package_install_bypass_cidrs

    content {
      description = "Debug bypass: allow HTTP to system package repositories"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [egress.value]
    }
  }

  dynamic "egress" {
    for_each = local.debug_package_install_bypass_cidrs

    content {
      description = "Debug bypass: allow HTTPS to system package repositories"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [egress.value]
    }
  }

  egress {
    description = "Allow MySQL to private database subnets"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = local.private_subnet_cidrs
  }

  tags = {
    Name = "${var.company_name}-ec2-sg"
  }
}

resource "aws_security_group" "mysql" {
  name        = "${var.company_name}-mysql-sg"
  description = "Security group for the MySQL EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow MySQL from web EC2 security group"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    description = "Allow HTTPS to package repositories during bootstrap"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.package_repository_cidrs
  }

  tags = {
    Name = "${var.company_name}-mysql-sg"
  }
}
