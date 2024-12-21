data "aws_route53_zone" "paas_aviatrixtest_com" {
  name = "paas.aviatrixtest.com"
}

data "aws_acm_certificate" "asterisk_aviatrixtest_com" {
  domain   = "*.aviatrixtest.com"
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "asterisk_paas_aviatrixtest_com" {
  domain   = "*.paas.aviatrixtest.com"
  statuses = ["ISSUED"]
}

resource "aws_route53_record" "paas" {
  zone_id = data.aws_route53_zone.paas_aviatrixtest_com.zone_id
  name    = data.aws_route53_zone.paas_aviatrixtest_com.name
  type    = "A"
  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "aws_gatus" {
  for_each = toset(local.cps)
  zone_id  = data.aws_route53_zone.paas_aviatrixtest_com.zone_id
  name     = "aws-${each.value}"
  type     = "A"
  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "azure_gatus" {
  for_each = toset(local.cps)
  zone_id  = data.aws_route53_zone.paas_aviatrixtest_com.zone_id
  name     = "azure-${each.value}"
  type     = "A"
  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }
}

resource "aws_security_group" "public_alb" {
  name        = "aviatrix-public"
  description = "Allow inbound traffic"
  vpc_id      = module.vpc[local.cps[0]].vpc_id

  tags = merge(local.tfvars.common_tags, {
    Name = "aviatrix-public"
  })
}

resource "aws_security_group_rule" "public_http" {
  type              = "ingress"
  description       = "Allows HTTP inbound"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_alb.id
}

resource "aws_security_group_rule" "public_https" {
  type              = "ingress"
  description       = "Allows HTTPS inbound"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_alb.id
}

resource "aws_security_group_rule" "public_egress_80" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_alb.id
}

resource "aws_security_group_rule" "public_egress_81" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 81
  to_port           = 81
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_alb.id
}

resource "aws_security_group_rule" "public_egress_82" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 82
  to_port           = 82
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_alb.id
}

resource "aws_security_group_rule" "public_egress_83" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 83
  to_port           = 83
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_alb.id
}

resource "aws_security_group_rule" "public_egress_84" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 84
  to_port           = 84
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_alb.id
}

resource "aws_security_group_rule" "public_egress_85" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 85
  to_port           = 85
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_alb.id
}

resource "aws_security_group_rule" "public_egress_443" {
  type              = "egress"
  description       = "Allow outbound"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_alb.id
}

resource "aws_lb" "public" {
  name               = "aviatrix-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb.id]
  subnets            = [module.vpc[local.cps[0]].public_subnets[0], module.vpc[local.cps[0]].public_subnets[1]]
  idle_timeout       = 4000

  enable_deletion_protection = false

  tags = merge(local.tfvars.common_tags, {
    Name = "aviatrix-public"
  })

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
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
}

resource "aws_lb_listener" "public_https" {
  load_balancer_arn = aws_lb.public.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  certificate_arn   = data.aws_acm_certificate.asterisk_aviatrixtest_com.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Nothing to see here."
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_certificate" "aviatrixtest_com" {
  listener_arn    = aws_lb_listener.public_https.arn
  certificate_arn = data.aws_acm_certificate.asterisk_aviatrixtest_com.arn
}

resource "aws_lb_listener_certificate" "paas_aviatrixtest_com" {
  listener_arn    = aws_lb_listener.public_https.arn
  certificate_arn = data.aws_acm_certificate.asterisk_paas_aviatrixtest_com.arn
}

resource "aws_alb_listener_rule" "paas" {
  for_each     = toset(local.cps)
  listener_arn = aws_lb_listener.public_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.paas[each.value].arn
  }

  condition {
    host_header {
      values = [aws_route53_record.aws_gatus[each.value].fqdn]
    }
  }
}

resource "aws_alb_listener_rule" "azure_paas" {
  for_each     = toset(local.cps)
  listener_arn = aws_lb_listener.public_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.azure_paas[each.value].arn
  }

  condition {
    host_header {
      values = [aws_route53_record.azure_gatus[each.value].fqdn]
    }
  }
}

resource "aws_alb_target_group" "paas" {
  for_each    = toset(local.cps)
  name        = each.value
  port        = 443
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc[local.cps[0]].vpc_id

  health_check {
    protocol = "HTTP"
    path     = "/"
    matcher  = "200"
  }

  tags = merge(local.tfvars.common_tags, {
    Name = each.value
  })
}

resource "aws_lb_target_group_attachment" "paas" {
  for_each          = toset(local.cps)
  target_id         = module.gatus_dashboard[each.value].private_ip
  target_group_arn  = aws_alb_target_group.paas[each.value].arn
  port              = "443"
  availability_zone = each.value == local.cps[0] ? null : "all"
}

resource "aws_alb_target_group" "azure_paas" {
  for_each = toset(local.cps)
  name     = "azure-${each.value}"
  port     = "8${index(local.cps, each.value) + 1}"
  protocol = "HTTP"
  vpc_id   = module.vpc[local.cps[0]].vpc_id

  health_check {
    protocol = "HTTP"
    port     = "8${index(local.cps, each.value) + 1}"
    path     = "/"
    matcher  = "200"
  }

  tags = merge(local.tfvars.common_tags, {
    Name = each.value
  })
}

resource "aws_lb_target_group_attachment" "azure_paas" {
  for_each         = toset(local.cps)
  target_id        = module.nginx.instance.id
  target_group_arn = aws_alb_target_group.azure_paas[each.value].arn
  port             = "8${index(local.cps, each.value) + 1}"
}

resource "aws_vpc_peering_connection" "paas" {
  for_each    = toset(setsubtract(local.cps, [local.cps[0]]))
  peer_vpc_id = module.vpc[local.cps[0]].vpc_id
  vpc_id      = module.vpc[each.value].vpc_id
  auto_accept = true
}

resource "aws_route" "paas" {
  for_each                  = toset(setsubtract(local.cps, [local.cps[0]]))
  route_table_id            = module.vpc[local.cps[0]].public_route_table_ids[0]
  destination_cidr_block    = module.vpc[each.value].vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.paas[each.value].id
}

resource "aws_route" "paas_return" {
  for_each                  = toset(setsubtract(local.cps, [local.cps[0]]))
  route_table_id            = module.vpc[each.value].public_route_table_ids[0]
  destination_cidr_block    = module.vpc[local.cps[0]].vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.paas[each.value].id
}
