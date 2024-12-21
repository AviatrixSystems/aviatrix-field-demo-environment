resource "azurerm_resource_group" "paas" {
  name     = "avx-pass"
  location = var.azure_region
}

resource "azurerm_nat_gateway" "paas" {
  for_each            = toset(local.cps)
  location            = azurerm_resource_group.paas.location
  name                = "nat-${each.value}"
  resource_group_name = azurerm_resource_group.paas.name
}

resource "azurerm_public_ip" "nat" {
  for_each            = toset(local.cps)
  name                = "nat-${each.value}-ip"
  location            = azurerm_resource_group.paas.location
  resource_group_name = azurerm_resource_group.paas.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat" {
  for_each             = toset(local.cps)
  nat_gateway_id       = azurerm_nat_gateway.paas[each.value].id
  public_ip_address_id = azurerm_public_ip.nat[each.value].id
}

locals {
  vnet_address_space = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24", "10.2.4.0/24", "10.2.5.0/24"]
}

resource "azurerm_route_table" "public" {
  for_each            = toset(local.cps)
  location            = var.azure_region
  name                = "${each.value}-public-rt"
  resource_group_name = azurerm_resource_group.paas.name
  route {
    name           = "local"
    address_prefix = local.vnet_address_space[index(local.cps, each.value)]
    next_hop_type  = "VnetLocal"
  }
  route {
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_route_table" "private" {
  for_each            = toset(local.cps)
  location            = var.azure_region
  name                = "${each.value}-private-rt"
  resource_group_name = azurerm_resource_group.paas.name
  route {
    name           = "local"
    address_prefix = local.vnet_address_space[index(local.cps, each.value)]
    next_hop_type  = "VnetLocal"
  }
}

module "vnet" {
  for_each = toset(local.cps)
  source   = "Azure/avm-res-network-virtualnetwork/azurerm"
  version  = "0.7.1"

  address_space       = [local.vnet_address_space[index(local.cps, each.value)]]
  location            = var.azure_region
  name                = "${each.value}-vnet"
  resource_group_name = azurerm_resource_group.paas.name
  subnets = {
    "subnet1" = {
      name                            = "private1"
      address_prefixes                = [cidrsubnet("10.2.${index(local.cps, each.value) + 1}.0/24", 4, 0)]
      default_outbound_access_enabled = false
      route_table = {
        id = azurerm_route_table.private[each.value].id
      }
      nat_gateway = {
        id = azurerm_nat_gateway.paas[each.value].id
    } }
    "subnet2" = {
      name                            = "private2"
      address_prefixes                = [cidrsubnet("10.2.${index(local.cps, each.value) + 1}.0/24", 4, 1)]
      default_outbound_access_enabled = false
      route_table = {
        id = azurerm_route_table.private[each.value].id
      }
      nat_gateway = {
        id = azurerm_nat_gateway.paas[each.value].id
    } }
    "subnet3" = {
      name                            = "private3"
      address_prefixes                = [cidrsubnet("10.2.${index(local.cps, each.value) + 1}.0/24", 4, 2)]
      default_outbound_access_enabled = false
      route_table = {
        id = azurerm_route_table.private[each.value].id
      }
      nat_gateway = {
        id = azurerm_nat_gateway.paas[each.value].id
    } }
    "subnet4" = {
      name                            = "public1"
      address_prefixes                = [cidrsubnet("10.2.${index(local.cps, each.value) + 1}.0/24", 4, 3)]
      default_outbound_access_enabled = true
      route_table = {
        id = azurerm_route_table.public[each.value].id
      }
    }
    "subnet5" = {
      name                            = "public2"
      address_prefixes                = [cidrsubnet("10.2.${index(local.cps, each.value) + 1}.0/24", 4, 4)]
      default_outbound_access_enabled = true
      route_table = {
        id = azurerm_route_table.public[each.value].id
      }
    }
    "subnet6" = {
      name                            = "public3"
      address_prefixes                = [cidrsubnet("10.2.${index(local.cps, each.value) + 1}.0/24", 4, 5)]
      default_outbound_access_enabled = true
      route_table = {
        id = azurerm_route_table.public[each.value].id
      }
    }
  }
}


module "az_gatus1" {
  for_each       = toset(local.cps)
  source         = "github.com/aviatrix-internal-only-org/avxlabs-mc-instance"
  name           = "${each.value}-egress-az1"
  resource_group = azurerm_resource_group.paas.name
  subnet_id      = module.vnet[each.value].subnets["subnet1"].resource_id
  location       = var.azure_region
  cloud          = "azure"
  instance_size  = "Standard_B1ms"
  public_key     = local.tfvars.ssh_public_key
  password       = local.tfvars.workload_instance_password
  private_ip     = "10.2.${index(local.cps, each.value) + 1}.10"

  user_data_templatefile = templatefile("${path.module}/templates/egress.tpl",
    {
      name     = "${each.value}-egress-az1"
      https    = local.https
      http     = local.http
      password = local.tfvars.workload_instance_password
      interval = "5"
  })
}

module "az_gatus2" {
  for_each       = toset(local.cps)
  source         = "github.com/aviatrix-internal-only-org/avxlabs-mc-instance"
  name           = "${each.value}-egress-az2"
  resource_group = azurerm_resource_group.paas.name
  subnet_id      = module.vnet[each.value].subnets["subnet2"].resource_id
  location       = var.azure_region
  cloud          = "azure"
  instance_size  = "Standard_B1ms"
  public_key     = local.tfvars.ssh_public_key
  password       = local.tfvars.workload_instance_password
  private_ip     = "10.2.${index(local.cps, each.value) + 1}.25"

  user_data_templatefile = templatefile("${path.module}/templates/egress.tpl",
    {
      name     = "${each.value}-egress-az2"
      https    = local.https
      http     = local.http
      password = local.tfvars.workload_instance_password
      interval = "5"
  })
}

module "az_gatus3" {
  for_each       = toset(local.cps)
  source         = "github.com/aviatrix-internal-only-org/avxlabs-mc-instance"
  name           = "${each.value}-egress-az3"
  resource_group = azurerm_resource_group.paas.name
  subnet_id      = module.vnet[each.value].subnets["subnet3"].resource_id
  location       = var.azure_region
  cloud          = "azure"
  instance_size  = "Standard_B1ms"
  public_key     = local.tfvars.ssh_public_key
  password       = local.tfvars.workload_instance_password
  private_ip     = "10.2.${index(local.cps, each.value) + 1}.40"

  user_data_templatefile = templatefile("${path.module}/templates/egress.tpl",
    {
      name     = "${each.value}-egress-az3"
      https    = local.https
      http     = local.http
      password = local.tfvars.workload_instance_password
      interval = "5"
  })
}

module "az_gatus_dashboard" {
  for_each       = toset(local.cps)
  source         = "github.com/aviatrix-internal-only-org/avxlabs-mc-instance?ref=v1.0.9"
  name           = "${each.value}-dashboard"
  resource_group = azurerm_resource_group.paas.name
  subnet_id      = module.vnet[each.value].subnets["subnet4"].resource_id
  location       = var.azure_region
  cloud          = "azure"
  public_key     = local.tfvars.ssh_public_key
  password       = local.tfvars.workload_instance_password
  instance_size  = "Standard_B1ms"
  common_tags    = {}
  public_ip      = true
  inbound_tcp = {
    22  = ["${chomp(data.http.myip.response_body)}/32"]
    443 = [module.nginx.public_ip]
  }

  user_data_templatefile = templatefile("${path.module}/templates/dashboard.tpl",
    {
      name      = "${each.value}-dashboard"
      gatus     = each.value
      instances = ["${module.az_gatus1[each.value].private_ip}", "${module.az_gatus2[each.value].private_ip}", "${module.az_gatus3[each.value].private_ip}"]
      pwd       = local.tfvars.workload_instance_password
      cloud     = "Azure"
  })
}
