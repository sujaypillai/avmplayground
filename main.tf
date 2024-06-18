provider "azurerm" {
  features {}
}

module "resource_group" {
  source   = "./avm-res-resources-resourcegroup"
  location = var.location
  name     = "rg-mistore"
}

module "avm-uai" {
  source              = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version             = "0.3.0"
  name                = "uai-mistore"
  resource_group_name = module.resource_group.name
  location            = var.location
}

module "avm-aks" {
  source              = "Azure/avm-ptn-aks-production/azurerm"
  version             = "0.1.0"
  kubernetes_version  = "1.28"
  enable_telemetry    = true
  name                = "avm-mistore"
  resource_group_name = module.resource_group.name
  managed_identities = {
    user_assigned_resource_ids = [module.avm-uai.resource_id]
  }
  location = var.location
  node_pools = {
    workload = {
      name                 = "workload"
      vm_size              = "Standard_DS2_v2"
      min_count            = 1
      max_count            = 3
      enable_auto_scaling  = true
      os_sku               = "Ubuntu"
      mode                 = "User"
      orchestrator_version = "1.28.0"
    }
  }
}