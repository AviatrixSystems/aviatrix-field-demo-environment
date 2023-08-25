data "aws_route53_zone" "demo_aviatrixtest_com" {
  name = "demo.aviatrixtest.com"
}

data "aws_acm_certificate" "asterisk_demo_aviatrixtest_com" {
  domain   = "*.demo.aviatrixtest.com"
  statuses = ["ISSUED"]
}

data "aws_acm_certificate" "asterisk_aviatrixtest_com" {
  domain   = "*.aviatrixtest.com"
  statuses = ["ISSUED"]
}

resource "aws_route53_record" "ctrl" {
  zone_id = data.aws_route53_zone.demo_aviatrixtest_com.zone_id
  name    = "ctrl"
  type    = "A"
  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cplt" {
  zone_id = data.aws_route53_zone.demo_aviatrixtest_com.zone_id
  name    = "cplt"
  type    = "A"
  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }
}

resource "aws_security_group" "public_alb" {
  name        = "aviatrix-public"
  description = "Allow http inbound traffic"
  vpc_id      = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixVpcID

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

resource "aws_security_group_rule" "public_egress_ctl" {
  type              = "egress"
  description       = "Allows 443 outbound"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_alb.id
}

resource "aws_subnet" "controller_subnet_b" {
  vpc_id            = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixVpcID
  availability_zone = "${var.aws_region}b"
  cidr_block        = "172.64.2.0/24"

  tags = {
    Name = "controller_subnet_b"
  }
}

data "aws_route_table" "controller" {
  filter {
    name   = "tag:Name"
    values = ["AviatrixPublicSubnetRouteTable"]
  }
  depends_on = [aws_cloudformation_stack.avx_ctrl_cplt]
}

resource "aws_route_table_association" "controller_subnet_b" {
  subnet_id      = aws_subnet.controller_subnet_b.id
  route_table_id = data.aws_route_table.controller.id
}

resource "aws_lb" "public" {
  name               = "aviatrix-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb.id]
  subnets            = [aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixSubnetID, aws_subnet.controller_subnet_b.id]
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
  certificate_arn   = data.aws_acm_certificate.asterisk_demo_aviatrixtest_com.arn

  default_action {
    type = "redirect"

    redirect {
      host        = "cplt.demo.aviatrixtest.com"
      port        = "443"
      path        = "/#{path}"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_certificate" "demo_aviatrixtest_com" {
  listener_arn    = aws_lb_listener.public_https.arn
  certificate_arn = data.aws_acm_certificate.asterisk_demo_aviatrixtest_com.arn
}

resource "aws_lb_listener_certificate" "aviatrixtest_com" {
  listener_arn    = aws_lb_listener.public_https.arn
  certificate_arn = data.aws_acm_certificate.asterisk_aviatrixtest_com.arn
}

resource "aws_alb_listener_rule" "ctrl" {
  listener_arn = aws_lb_listener.public_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ctrl.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.ctrl.fqdn]
    }
  }
}

resource "aws_alb_listener_rule" "cplt" {
  listener_arn = aws_lb_listener.public_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.cplt.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.cplt.fqdn]
    }
  }
}

resource "aws_alb_listener_rule" "legacy_controller" {
  listener_arn = aws_lb_listener.public_https.arn

  action {
    type = "redirect"

    redirect {
      host        = "ctrl.demo.aviatrixtest.com"
      port        = "443"
      path        = "/#{path}"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["controller.aviatrixtest.com"]
    }
  }
}

resource "aws_alb_listener_rule" "legacy_copilot" {
  listener_arn = aws_lb_listener.public_https.arn

  action {
    type = "redirect"

    redirect {
      host        = "cplt.demo.aviatrixtest.com"
      port        = "443"
      path        = "/#{path}"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["copilot.aviatrixtest.com"]
    }
  }
}

resource "aws_alb_listener_rule" "legacy_demo" {
  listener_arn = aws_lb_listener.public_https.arn

  action {
    type = "redirect"

    redirect {
      host        = "ctrl.demo.aviatrixtest.com"
      port        = "443"
      path        = "/#{path}"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["demo.aviatrixtest.com"]
    }
  }
}

resource "aws_alb_target_group" "ctrl" {
  name     = "avx-controller"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixVpcID

  health_check {
    protocol = "HTTPS"
    path     = "/"
    matcher  = "200"
  }

  tags = merge(local.tfvars.common_tags, {
    Name = "aviatrix-controller"
  })
}

resource "aws_alb_target_group" "cplt" {
  name     = "avx-copilot"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixVpcID

  health_check {
    protocol = "HTTPS"
    path     = "/"
    matcher  = "200"
  }

  tags = merge(local.tfvars.common_tags, {
    Name = "aviatrix-copilot"
  })
}

resource "aws_alb_target_group_attachment" "ctrl" {
  target_id        = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixControllerInstanceID
  target_group_arn = aws_alb_target_group.ctrl.arn
  port             = "443"
}

resource "aws_alb_target_group_attachment" "cplt" {
  target_id        = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixCoPilotInstanceID
  target_group_arn = aws_alb_target_group.cplt.arn
  port             = "443"
}

resource "aws_security_group_rule" "alb_controller" {
  type                     = "ingress"
  description              = "Allows HTTPS inbound from the alb"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_alb.id
  security_group_id        = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixControllerSecurityGroupID
}

resource "aws_security_group_rule" "alb_copilot" {
  type                     = "ingress"
  description              = "Allows HTTPS inbound from the alb"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_alb.id
  security_group_id        = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixCoPilotSecurityGroupID
}
