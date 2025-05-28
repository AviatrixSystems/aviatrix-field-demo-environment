resource "azurerm_kubernetes_cluster" "k8s" {
  location                          = var.location
  name                              = "${var.cluster_name}-cluster"
  resource_group_name               = var.resource_group
  node_resource_group               = "${var.cluster_name}-aksnode-rg"
  dns_prefix                        = "${var.cluster_name}-cluster"
  local_account_disabled            = false
  role_based_access_control_enabled = true

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name           = "agentpool"
    vm_size        = var.cluster_instance_size
    node_count     = 1
    vnet_subnet_id = var.subnet_id

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = var.max_surge
      node_soak_duration_in_minutes = 0
    }
  }
  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = var.ssh_key
    }
  }
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

}

data "azurerm_subscription" "pod" {}
# The identity created for the cluster must be given the permission to manage
# the network resources to register the load balancer.
resource "azurerm_role_assignment" "network_contributor" {
  # scope                = data.azurerm_subscription.pod.id # split("/providers", var.resource_id)[0]
  scope                = split("/providers", var.resource_id)[0]
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.k8s.identity[0].principal_id
}

