resource azurerm_kubernetes_cluster "k8s_cluster" {
  dns_prefix          = "terragoat-${var.environment}"
  location            = var.location
  name                = "terragoat-aks-${var.environment}"
  kubernetes_version  = var.kuber_version
  resource_group_name = var.rg_name
  identity {
    type = "SystemAssigned"
  }
  default_node_pool {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 2
  }
  addon_profile {
    oms_agent {
      enabled = false
    }
    kube_dashboard {
      enabled = true
    }
  }
  role_based_access_control {
    enabled = false
  }
}
