resource "azurerm_public_ip" "this" {
  count               = var.public_ip ? 1 : 0
  name                = "${var.name}-pub-ip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group
  ip_configuration {
    name                          = var.name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip != null ? "Static" : "Dynamic"
    private_ip_address            = var.private_ip != null ? var.private_ip : null
    public_ip_address_id          = var.public_ip ? azurerm_public_ip.this[0].id : null
  }
  tags = var.common_tags
}

data "azurerm_platform_image" "this" {
  location  = var.location
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group
  network_interface_ids           = [azurerm_network_interface.this.id]
  admin_username                  = "instance_user"
  admin_password                  = var.password
  computer_name                   = var.name
  size                            = var.instance_size
  source_image_id                 = var.image == null ? null : var.image
  custom_data                     = data.cloudinit_config.this.rendered
  disable_password_authentication = false
  tags = merge(var.common_tags, {
    Name = var.name
  })

  dynamic "source_image_reference" {
    for_each = var.image == null ? ["ubuntu"] : []

    content {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}


data "cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = var.user_data_templatefile
  }
}

resource "azurerm_network_security_group" "this" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  tags                = var.common_tags
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_network_security_rule" "this_rfc_1918" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "rfc-1918"
  priority                    = 100
  protocol                    = "*"
  source_port_range           = "*"
  source_address_prefixes     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  destination_port_range      = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.this.name
}

resource "azurerm_network_security_rule" "this_inbound_tcp" {
  for_each                    = var.inbound_tcp
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "inbound_tcp_${each.key}"
  priority                    = (index(keys(var.inbound_tcp), each.key) + 101)
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefixes     = each.value
  destination_port_range      = each.key
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.this.name
}

resource "azurerm_network_security_rule" "this_inbound_udp" {
  for_each                    = var.inbound_udp
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "inbound_udp_${each.key}"
  priority                    = (index(keys(var.inbound_tcp), each.key) + 151)
  protocol                    = "Udp"
  source_port_range           = "*"
  source_address_prefixes     = each.value
  destination_port_range      = each.key
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.this.name
}
