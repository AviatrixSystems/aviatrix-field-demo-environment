resource "aws_security_group" "appiq_aws" {
  name        = "appiq-example-destination-sg"
  description = "appiq example security group"
  vpc_id      = module.spokes["${var.aws_accounting_account_name}-dev"].vpc.vpc_id

  tags = merge(var.common_tags, {
    Name = "appiq-example-destination-sg"
  })
  provider = aws.accounting
}

resource "aws_security_group_rule" "ingress_https_appiq_aws" {
  type              = "ingress"
  description       = "Allow inbound https access"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = aws_security_group.appiq_aws.id
  provider          = aws.accounting
}

resource "aws_security_group_rule" "ingress_ssh_appiq_aws" {
  type              = "ingress"
  description       = "Allow inbound ssh access"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
  security_group_id = aws_security_group.appiq_aws.id
  provider          = aws.accounting
}

resource "aws_security_group_rule" "egress_appiq_aws" {
  type              = "egress"
  description       = "Allow all outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.appiq_aws.id
  provider          = aws.accounting
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
  owners   = ["099720109477"] # Canonical
  provider = aws.accounting
}

resource "tls_private_key" "appiq_aws" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "appiq_aws" {
  key_name   = "instance-key-appiq-aws"
  public_key = tls_private_key.appiq_aws.public_key_openssh
  provider   = aws.accounting
}

resource "aws_instance" "appiq_aws" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.nano"
  ebs_optimized               = false
  monitoring                  = true
  key_name                    = aws_key_pair.appiq_aws.key_name
  subnet_id                   = module.spokes["${var.aws_accounting_account_name}-dev"].vpc.private_subnets[0].subnet_id
  private_ip                  = "10.1.2.5"
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.appiq_aws.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags = merge(var.common_tags, {
    Name        = "appiq-example-destination"
    Application = "appiq"
    Environment = "prod"
    Tier        = "app"
  })
  user_data = templatefile("${var.workload_template_path}/appiq.tpl",
    {
      name     = "appiq-example-destination"
      domain   = "demo.aviatrixtest.com"
      password = var.workload_instance_password
      endpoint = "10.2.2.45"
  })
  provider   = aws.accounting
  depends_on = [module.spokes]
}

## ----------------------------------------------------------
resource "azurerm_network_interface" "appiq_azure" {
  name                = "appiq-example-source"
  location            = module.spokes["${var.azure_marketing_account_name}-all"].vpc.region
  resource_group_name = module.spokes["${var.azure_marketing_account_name}-all"].vpc.resource_group
  ip_configuration {
    name                          = "appiq-example-source"
    subnet_id                     = module.spokes["${var.azure_marketing_account_name}-all"].vpc.private_subnets[0].subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.2.2.45"
  }
  tags = var.common_tags
}

resource "azurerm_linux_virtual_machine" "appiq_azure" {
  name                            = "appiq-example-source"
  location                        = module.spokes["${var.azure_marketing_account_name}-all"].vpc.region
  resource_group_name             = module.spokes["${var.azure_marketing_account_name}-all"].vpc.resource_group
  network_interface_ids           = [azurerm_network_interface.appiq_azure.id]
  admin_username                  = "instance_user"
  admin_password                  = var.workload_instance_password
  computer_name                   = "appiq-example-source"
  size                            = "Standard_B2ats_v2"
  custom_data                     = data.cloudinit_config.appiq_azure.rendered
  disable_password_authentication = false
  tags = merge(var.common_tags, {
    Name        = "appiq-example-source"
    Application = "appiq"
    Environment = "prod"
    Tier        = "app"
  })

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

data "cloudinit_config" "appiq_azure" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${var.workload_template_path}/appiq.tpl",
      {
        name     = "appiq-example-source"
        domain   = "demo.aviatrixtest.com"
        password = var.workload_instance_password
        endpoint = "10.1.2.5"
    })
  }
  depends_on = [module.spokes]
}

resource "azurerm_network_security_group" "appiq_azure" {
  name                = "appiq-example-source"
  resource_group_name = module.spokes["${var.azure_marketing_account_name}-all"].vpc.resource_group
  location            = module.spokes["${var.azure_marketing_account_name}-all"].vpc.region
  tags                = var.common_tags
}

resource "azurerm_network_interface_security_group_association" "appiq_azure" {
  network_interface_id      = azurerm_network_interface.appiq_azure.id
  network_security_group_id = azurerm_network_security_group.appiq_azure.id
}

resource "azurerm_network_security_rule" "inbound_https_appiq_azure" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "https"
  priority                    = 100
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefixes     = ["10.0.0.0/8"]
  destination_port_range      = "443"
  destination_address_prefix  = "*"
  resource_group_name         = module.spokes["${var.azure_marketing_account_name}-all"].vpc.resource_group
  network_security_group_name = azurerm_network_security_group.appiq_azure.name
}

resource "azurerm_network_security_rule" "inbound_ssh_appiq_azure" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "ssh"
  priority                    = 101
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefixes     = ["10.0.0.0/8"]
  destination_port_range      = "22"
  destination_address_prefix  = "*"
  resource_group_name         = module.spokes["${var.azure_marketing_account_name}-all"].vpc.resource_group
  network_security_group_name = azurerm_network_security_group.appiq_azure.name
}
