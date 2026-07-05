resource "aws_network_acl" "public" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "${var.company_name}-public-nacl"
  }
}

resource "aws_network_acl_rule" "public_inbound_http" {
  count          = length(var.allowed_inbound_cidr_blocks)
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.allowed_inbound_cidr_blocks[count.index]
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_inbound_https" {
  count          = length(var.allowed_inbound_cidr_blocks)
  network_acl_id = aws_network_acl.public.id
  rule_number    = 200 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.allowed_inbound_cidr_blocks[count.index]
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_inbound_private_ephemeral" {
  count          = length(local.private_subnet_cidrs)
  network_acl_id = aws_network_acl.public.id
  rule_number    = 300 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.private_subnet_cidrs[count.index]
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_inbound_private_https" {
  count          = length(local.private_subnet_cidrs)
  network_acl_id = aws_network_acl.public.id
  rule_number    = 350 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.private_subnet_cidrs[count.index]
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_inbound_external_https_response" {
  count          = length(local.external_https_cidrs)
  network_acl_id = aws_network_acl.public.id
  rule_number    = 400 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.external_https_cidrs[count.index]
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_inbound_debug_package_response" {
  count          = length(local.debug_package_install_bypass_cidrs)
  network_acl_id = aws_network_acl.public.id
  rule_number    = 500 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.debug_package_install_bypass_cidrs[count.index]
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_inbound_deny_all" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 30000
  egress         = false
  protocol       = "-1"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "public_outbound_client_response" {
  count          = length(var.allowed_inbound_cidr_blocks)
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.allowed_inbound_cidr_blocks[count.index]
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_outbound_private_http" {
  count          = length(local.private_subnet_cidrs)
  network_acl_id = aws_network_acl.public.id
  rule_number    = 200 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.private_subnet_cidrs[count.index]
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_outbound_private_ephemeral" {
  count          = length(local.private_subnet_cidrs)
  network_acl_id = aws_network_acl.public.id
  rule_number    = 250 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.private_subnet_cidrs[count.index]
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_outbound_external_https" {
  count          = length(local.external_https_cidrs)
  network_acl_id = aws_network_acl.public.id
  rule_number    = 300 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.external_https_cidrs[count.index]
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_outbound_debug_package_http" {
  count          = length(local.debug_package_install_bypass_cidrs)
  network_acl_id = aws_network_acl.public.id
  rule_number    = 400 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.debug_package_install_bypass_cidrs[count.index]
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "public_outbound_debug_package_https" {
  count          = length(local.debug_package_install_bypass_cidrs)
  network_acl_id = aws_network_acl.public.id
  rule_number    = 500 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.debug_package_install_bypass_cidrs[count.index]
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_outbound_deny_all" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 30000
  egress         = true
  protocol       = "-1"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl" "private" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.company_name}-private-nacl"
  }
}

resource "aws_network_acl_rule" "private_inbound_public_http" {
  count          = length(local.public_subnet_cidrs)
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.public_subnet_cidrs[count.index]
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_inbound_web_mysql" {
  count          = length(local.private_subnet_cidrs)
  network_acl_id = aws_network_acl.private.id
  rule_number    = 200 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.private_subnet_cidrs[count.index]
  from_port      = 3306
  to_port        = 3306
}

resource "aws_network_acl_rule" "private_inbound_vpc_ephemeral" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 400
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.vpc_cidr
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_inbound_vpc_udp_ephemeral" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 401
  egress         = false
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = local.vpc_cidr
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_inbound_external_https_response" {
  count          = length(local.external_https_cidrs)
  network_acl_id = aws_network_acl.private.id
  rule_number    = 500 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.external_https_cidrs[count.index]
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_inbound_debug_package_response" {
  count          = length(local.debug_package_install_bypass_cidrs)
  network_acl_id = aws_network_acl.private.id
  rule_number    = 600 + count.index
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.debug_package_install_bypass_cidrs[count.index]
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_inbound_deny_all" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 30000
  egress         = false
  protocol       = "-1"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "private_outbound_public_response" {
  count          = length(local.public_subnet_cidrs)
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.public_subnet_cidrs[count.index]
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_outbound_mysql" {
  count          = length(local.private_subnet_cidrs)
  network_acl_id = aws_network_acl.private.id
  rule_number    = 200 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.private_subnet_cidrs[count.index]
  from_port      = 3306
  to_port        = 3306
}

resource "aws_network_acl_rule" "private_outbound_vpc_ephemeral" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 400
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.vpc_cidr
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_outbound_external_https" {
  count          = length(local.external_https_cidrs)
  network_acl_id = aws_network_acl.private.id
  rule_number    = 500 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.external_https_cidrs[count.index]
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_outbound_debug_package_http" {
  count          = length(local.debug_package_install_bypass_cidrs)
  network_acl_id = aws_network_acl.private.id
  rule_number    = 600 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.debug_package_install_bypass_cidrs[count.index]
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "private_outbound_debug_package_https" {
  count          = length(local.debug_package_install_bypass_cidrs)
  network_acl_id = aws_network_acl.private.id
  rule_number    = 700 + count.index
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.debug_package_install_bypass_cidrs[count.index]
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_outbound_deny_all" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 30000
  egress         = true
  protocol       = "-1"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}
