data "aws_s3_object" "demo_cert" {
  bucket = "demo.aviatrixtest.com"
  key    = "demo.aviatrixtest/cert.crt"
}

data "aws_s3_object" "demo_key" {
  bucket = "demo.aviatrixtest.com"
  key    = "demo.aviatrixtest/private.key"
}

resource "aws_route53_record" "grafana" {
  zone_id = data.aws_route53_zone.demo_aviatrixtest_com.zone_id
  name    = "grafana"
  type    = "A"
  alias {
    name                   = aws_lb.public.dns_name
    zone_id                = aws_lb.public.zone_id
    evaluate_target_health = true
  }
}

resource "aws_security_group" "grafana" {
  name        = "grafana-demo-sg"
  description = "Grafana security group"
  vpc_id      = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixVpcID

  tags = merge(local.tfvars.common_tags, {
    Name = "grafana-demo-sg"
  })
}

resource "aws_security_group_rule" "grafana_22" {
  type              = "ingress"
  description       = "Allow inbound access from cidrs"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.response_body)}/32"]
  security_group_id = aws_security_group.grafana.id
}

resource "aws_security_group_rule" "grafana_443" {
  type                     = "ingress"
  description              = "Allow https access from alb"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_alb.id
  security_group_id        = aws_security_group.grafana.id
}

resource "aws_security_group_rule" "grafana_egress" {
  type              = "egress"
  description       = "Allow all outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.grafana.id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "grafana" {
  key_name   = "grafana-ssh-key"
  public_key = local.tfvars.ssh_public_key
}

resource "aws_instance" "grafana" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  ebs_optimized = false
  monitoring    = true
  key_name      = aws_key_pair.grafana.key_name
  subnet_id     = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixSubnetID
  user_data = templatefile("${path.module}/grafana/grafana.tpl",
    {
      copilot_api_key        = local.tfvars.copilot_api_key
      copilot_fqdn           = aws_route53_record.cplt.fqdn
      grafana_fqdn           = aws_route53_record.grafana.fqdn
      grafana_admin_password = local.tfvars.ctrl_password
      grafana_client_id      = local.tfvars.grafana_client_id
      grafana_client_secret  = local.tfvars.grafana_client_secret
      grafana_auth_url       = local.tfvars.grafana_auth_url
      grafana_token_url      = local.tfvars.grafana_token_url
      azure_tenant_id        = local.tfvars.azure_directory_id
  })
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.grafana.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags = merge(local.tfvars.common_tags, {
    Name = "grafana-demo"
  })

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file("~/.ssh/avxnuc")
    timeout     = "1m"
    agent       = "false"
  }

  provisioner "file" {
    source      = "${path.module}/grafana" # local files
    destination = "/tmp"
  }

  provisioner "file" {
    content     = data.aws_s3_object.demo_cert.body
    destination = "/tmp/grafana.crt"
  }

  provisioner "file" {
    content     = data.aws_s3_object.demo_key.body
    destination = "/tmp/grafana.key"
  }
}

resource "aws_alb_listener_rule" "grafana" {
  listener_arn = aws_lb_listener.public_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.grafana.arn
  }

  condition {
    host_header {
      values = [aws_route53_record.grafana.fqdn]
    }
  }
}

resource "aws_alb_target_group" "grafana" {
  name     = "avx-grafana"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_cloudformation_stack.avx_ctrl_cplt.outputs.AviatrixVpcID

  health_check {
    protocol = "HTTPS"
    path     = "/login"
    matcher  = "200"
  }

  tags = merge(local.tfvars.common_tags, {
    Name = "aviatrix-grafana"
  })
}

resource "aws_alb_target_group_attachment" "grafana" {
  target_id        = aws_instance.grafana.id
  target_group_arn = aws_alb_target_group.grafana.arn
  port             = "443"
}
