# Palo bootstrap s3 bucket and files
resource "aws_s3_bucket" "palo" {
  bucket = var.palo_bucket_name
}

resource "aws_s3_bucket_public_access_block" "palo" {
  bucket = aws_s3_bucket.palo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "palo" {
  bucket = aws_s3_bucket.palo.bucket

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "bootstrap" {
  bucket = aws_s3_bucket.palo.id
  key    = "config/bootstrap.xml"
  source = "${var.palo_bootstrap_path}/bootstrap.xml"
  etag   = filemd5("${var.palo_bootstrap_path}/bootstrap.xml")
}

resource "aws_s3_object" "init_cfg" {
  bucket = aws_s3_bucket.palo.id
  key    = "config/init-cfg.txt"
  source = "${var.palo_bootstrap_path}/init-cfg.txt"
  etag   = filemd5("${var.palo_bootstrap_path}/init-cfg.txt")
}

resource "aws_s3_object" "content" {
  bucket = aws_s3_bucket.palo.id
  acl    = "private"
  key    = "content/"
  source = "/dev/null"
}

resource "aws_s3_object" "license" {
  bucket = aws_s3_bucket.palo.id
  acl    = "private"
  key    = "license/"
  source = "/dev/null"
}

resource "aws_s3_object" "software" {
  bucket = aws_s3_bucket.palo.id
  acl    = "private"
  key    = "software/"
  source = "/dev/null"
}

# Palo iam policy and bootstrap role
data "aws_iam_policy_document" "palo" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::*"]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "palo" {
  name   = "aviatrix-bootstrap-VM-S3-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.palo.json
}

resource "aws_iam_role" "palo" {
  name               = "aviatrix-bootstrap-VM-S3-role"
  description        = "palo alto vm series bootstrap"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "palo" {
  role       = aws_iam_role.palo.id
  policy_arn = aws_iam_policy.palo.arn
}

resource "aws_iam_instance_profile" "palo" {
  name = "aviatrix-bootstrap-VM-S3-role"
  role = aws_iam_role.palo.name
}

# Enable palo policies
resource "aviatrix_transit_firenet_policy" "palo_peering" {
  for_each                     = { for k, v in local.backbone : k => v if k != "aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}" }
  transit_firenet_gateway_name = module.backbone.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  inspected_resource_name      = "PEERING:${module.backbone.transit[each.key].transit_gateway.gw_name}"
  depends_on = [
    module.backbone
  ]
}

resource "aviatrix_transit_firenet_policy" "palo_spokes" {
  for_each                     = { for spoke in local.regional_spokes : "${spoke.avx_account}-${spoke.spoke}" => spoke if "${spoke.avx_account}" == var.aws_accounting_account_name }
  transit_firenet_gateway_name = module.backbone.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  inspected_resource_name      = "SPOKE:${module.spokes["${each.value.avx_account}-${each.value.spoke}"].spoke_gateway.gw_name}"
  depends_on = [
    module.backbone
  ]
}

# Enable palo vendor integration
data "aviatrix_firenet_vendor_integration" "palo" {
  vpc_id            = module.backbone.firenet["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].aviatrix_firewall_instance[0].vpc_id
  instance_id       = module.backbone.firenet["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].aviatrix_firewall_instance[0].instance_id
  vendor_type       = "Palo Alto Networks VM-Series"
  public_ip         = module.backbone.firenet["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].aviatrix_firewall_instance[0].public_ip
  username          = var.palo_admin_username
  password          = var.palo_admin_password
  firewall_name     = module.backbone.firenet["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].aviatrix_firewall_instance[0].firewall_name
  number_of_retries = 5
  save              = true
}

# Palo alb
data "aws_security_group" "palo" {
  filter {
    name   = "tag:Name"
    values = ["*-fw1-management"]
  }
  depends_on = [
    module.backbone
  ]
  provider = aws.palo
}

data "aws_subnet" "palo_a" {
  filter {
    name   = "tag:Name"
    values = ["transit-aws-${var.transit_aws_palo_firenet_region}-Public-FW-ingress-egress-${var.transit_aws_palo_firenet_region}a"]
  }
  depends_on = [
    module.backbone
  ]
  provider = aws.palo
}

data "aws_subnet" "palo_b" {
  filter {
    name   = "tag:Name"
    values = ["transit-aws-${var.transit_aws_palo_firenet_region}-Public-FW-ingress-egress-${var.transit_aws_palo_firenet_region}b"]
  }
  depends_on = [
    module.backbone
  ]
  provider = aws.palo
}

data "aws_eip" "palo" {
  filter {
    name   = "tag:Name"
    values = ["transit-aws-${var.transit_aws_palo_firenet_region}-az1-fw1-management-eip"]
  }
  depends_on = [
    module.backbone
  ]
  provider = aws.palo
}

data "aws_acm_certificate" "asterisk_demo_aviatrixtest_com" {
  domain   = "*.demo.aviatrixtest.com"
  statuses = ["ISSUED"]
  provider = aws.palo
}

resource "aws_security_group" "palo_alb" {
  name        = "aviatrix-palo"
  description = "Allow http/s inbound traffic"
  vpc_id      = data.aws_security_group.palo.vpc_id

  tags = merge(var.common_tags, {
    Name = "aviatrix-palo"
  })
  provider = aws.palo
}

resource "aws_security_group_rule" "palo_http" {
  type              = "ingress"
  description       = "Allows HTTP inbound"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.palo_alb.id
  provider          = aws.palo
}

resource "aws_security_group_rule" "palo_https" {
  type              = "ingress"
  description       = "Allows HTTPS inbound"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.palo_alb.id
  provider          = aws.palo
}

resource "aws_security_group_rule" "palo_egress" {
  type              = "egress"
  description       = "Allows 443 outbound"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.palo_alb.id
  provider          = aws.palo
}

resource "aws_lb" "palo" {
  name               = "aviatrix-palo-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.palo_alb.id]
  subnets            = [data.aws_subnet.palo_a.id, data.aws_subnet.palo_b.id]
  idle_timeout       = 4000

  enable_deletion_protection = false

  tags = merge(var.common_tags, {
    Name = "aviatrix-palo"
  })

  timeouts {
    create = "30m"
    delete = "30m"
  }
  provider = aws.palo
}

resource "aws_lb_listener" "palo_http" {
  load_balancer_arn = aws_lb.palo.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  provider = aws.palo
}

resource "aws_lb_listener" "palo_https" {
  load_balancer_arn = aws_lb.palo.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = data.aws_acm_certificate.asterisk_demo_aviatrixtest_com.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Nothing to see here."
      status_code  = "200"
    }
  }
  provider = aws.palo
}

resource "aws_lb_listener_certificate" "demo_aviatrixtest_com" {
  listener_arn    = aws_lb_listener.palo_https.arn
  certificate_arn = data.aws_acm_certificate.asterisk_demo_aviatrixtest_com.arn
  provider        = aws.palo
}

resource "aws_alb_listener_rule" "palo" {
  listener_arn = aws_lb_listener.palo_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.palo.arn
  }

  condition {
    host_header {
      values = ["palo.demo.aviatrixtest.com"]
    }
  }
  provider = aws.palo
}

resource "aws_alb_target_group" "palo" {
  name        = "avx-palo"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = data.aws_security_group.palo.vpc_id
  target_type = "ip"

  health_check {
    protocol = "HTTPS"
    path     = "/php/login.php?"
    matcher  = "200"
  }

  tags = merge(var.common_tags, {
    Name = "aviatrix-palo"
  })
  provider = aws.palo
}

resource "aws_alb_target_group_attachment" "palo" {
  target_id        = data.aws_eip.palo.private_ip
  target_group_arn = aws_alb_target_group.palo.arn
  port             = "443"
  provider         = aws.palo
}

resource "aws_security_group_rule" "alb_palo" {
  type                     = "ingress"
  description              = "Allows HTTPS inbound from the alb"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.palo_alb.id
  security_group_id        = data.aws_security_group.palo.id
  provider                 = aws.palo
}
