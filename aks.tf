resource azurerm_kubernetes_cluster "k8s_cluster" {
  dns_prefix          = "terragoat-${var.environment}"
  location            = var.location
  name                = "terragoat-aks-${var.environment}-${random_integer.rnd_int.result}"
  resource_group_name = var.rg_name
  identity {
    type = "SystemAssigned"
  }
  default_node_pool {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 2
  }
  azure_active_directory_role_based_access_control {
    managed = true
    azure_rbac_enabled = false
  }


  depends_on = [
        azurerm_network_watcher_flow_log.flow_log,
        azurerm_network_watcher.network_watcher,

    ]
}
