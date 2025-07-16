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
 
# Create resource group 
resource "azurerm_resource_group" "rg_twinbots" {
  name     = "rg_twinbots"
  location = "West Europe"
}

# Register the Microsoft.Kubernetes provider if not already registered
resource "azurerm_resource_provider_registration" "k8s" {
  name = "Microsoft.ContainerService"
}

# Create an Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr_twinbots" {
  name                = "acrtwinbots"
  resource_group_name = azurerm_resource_group.rg_twinbots.name
  location            = azurerm_resource_group.rg_twinbots.location
  sku                 = "Basic"
  admin_enabled       = false

  tags = {
    ENV = "Test"
  }
}

# Create AKS Cluster
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

# Attach ACR to AKS (so AKS can pull images)
  depends_on = [azurerm_container_registry.acr_twinbots, azurerm_kubernetes_cluster.akc_twinbots]
}

# Assign ACR pull permission to AKS managed identity
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr_twinbots.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.akc_twinbots.identity[0].principal_id
  depends_on           = [azurerm_kubernetes_cluster.akc_twinbots]
}

