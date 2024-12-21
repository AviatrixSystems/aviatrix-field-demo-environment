resource "aws_security_group" "this" {
  name        = var.name
  description = "Instance security group"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = var.name
  })
}

resource "aws_security_group_rule" "this_rfc1918" {
  type              = "ingress"
  description       = "Allow all inbound from rfc1918"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  cidr_blocks       = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "this_inbound_tcp" {
  for_each          = var.inbound_tcp
  type              = "ingress"
  description       = "Allow inbound access from cidrs"
  from_port         = each.key
  to_port           = each.key
  protocol          = "tcp"
  cidr_blocks       = each.value
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "this_inbound_udp" {
  for_each          = var.inbound_udp
  type              = "ingress"
  description       = "Allow inbound access from cidrs"
  from_port         = each.key
  to_port           = each.key
  protocol          = "udp"
  cidr_blocks       = each.value
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "this_egress" {
  type              = "egress"
  description       = "Allow all outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
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

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_id" "this" {
  byte_length = 4
}

resource "aws_key_pair" "this" {
  key_name   = "instance-key-${var.vpc_id}-${random_id.this.id}"
  public_key = var.public_key != null ? var.public_key : tls_private_key.this.public_key_openssh
}

resource "aws_instance" "this" {
  ami                         = var.image == null ? data.aws_ami.ubuntu.id : var.image
  instance_type               = var.instance_size
  ebs_optimized               = false
  monitoring                  = true
  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = var.subnet_id
  iam_instance_profile        = var.iam_instance_profile
  user_data                   = var.user_data_templatefile
  associate_public_ip_address = var.public_ip ? true : false
  vpc_security_group_ids      = [aws_security_group.this.id]
  private_ip                  = var.private_ip != null ? var.private_ip : null

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags = merge(var.common_tags, {
    Name = var.name
  })
}
