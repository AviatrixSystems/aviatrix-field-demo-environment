resource "aws_route53_record" "copilot_proxy_demo" {
  zone_id = data.aws_route53_zone.demo_aviatrix_com.zone_id
  name    = "demo.aviatrix.com"
  type    = "A"
  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "copilot_proxy" {
  zone_id = data.aws_route53_zone.demo_aviatrixtest_com.zone_id
  name    = "copilot"
  type    = "A"
  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }
}

resource "aws_security_group_rule" "copilot_proxy" {
  type                     = "ingress"
  description              = "Allow https access from alb"
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_alb.id
  security_group_id        = aws_security_group.grafana.id
}

resource "aws_alb_listener_rule" "copilot_proxy" {
  listener_arn = aws_lb_listener.public_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.copilot_proxy.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.copilot_proxy.fqdn]
    }
  }
}

resource "aws_alb_listener_rule" "copilot_proxy_demo" {
  listener_arn = aws_lb_listener.public_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.copilot_proxy.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.copilot_proxy_demo.fqdn]
    }
  }
}
# resource "aws_alb_listener_rule" "copilot_proxy_test" {
#   listener_arn = aws_lb_listener.public_https.arn

#   action {
#     type = "redirect"

#     redirect {
#       host        = "demo.aviatrix.com"
#       port        = "443"
#       path        = "/#{path}"
#       query       = "#{query}"
#       status_code = "HTTP_301"
#     }
#   }

#   condition {
#     host_header {
#       values = [aws_route53_record.copilot_proxy.fqdn]
#     }
#   }
# }

resource "aws_alb_target_group" "copilot_proxy" {
  name     = "avx-copilot-proxy"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixVpcID

  health_check {
    protocol = "HTTPS"
    port     = "8443"
    path     = "/"
    matcher  = "200,302"
  }

  tags = merge(local.tfvars.common_tags, {
    Name = "aviatrix-copilot-proxy"
  })
}

resource "aws_alb_target_group_attachment" "copilot_proxy" {
  target_id        = aws_instance.grafana.id
  target_group_arn = aws_alb_target_group.copilot_proxy.arn
  port             = "8443"
}

