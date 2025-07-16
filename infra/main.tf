terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.36.0"
    }
    azapi = {
      source = "azure/azapi"
      version = ">=2.5.0"
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id = "5f220201-71db-4b78-b23f-ec5939d9aabf"
}
provider "azapi" {
}

resource "azurerm_resource_group" "rg_twinbots" {
  name     = "rg_twinbots"
  location = "West Europe"
}

# Register the Microsoft.Kubernetes provider if not already registered
resource "azurerm_resource_provider_registration" "k8s" {
 name = "Microsoft.ContainerService"
}

resource "azurerm_kubernetes_cluster" "akc_twinbots" {
  name                         = "akc_twinbots"
  resource_group_name          = azurerm_resource_group.rg_twinbots.name
  location                     = azurerm_resource_group.rg_twinbots.location
  dns_prefix                   = "exampleaks1"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }
}
