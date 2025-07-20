terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.36.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">=2.5.0"
    }
  }
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
  subscription_id                 = "5f220201-71db-4b78-b23f-ec5939d9aabf"
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
  admin_enabled       = true

  tags = {
    ENV = "Test"
  }
}

# Create AKS Cluster
resource "azurerm_kubernetes_cluster" "akc_twinbots" {
  name                              = "akc_twinbots"
  resource_group_name               = azurerm_resource_group.rg_twinbots.name
  location                          = azurerm_resource_group.rg_twinbots.location
  dns_prefix                        = "exampleaks1"
  role_based_access_control_enabled = true

  default_node_pool {
    name = "default"
    tags = {}
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
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

# Create Azure Key Vault
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv_twinbots" {
  name                       = "kv-twinbots"
  location                   = azurerm_resource_group.rg_twinbots.location
  resource_group_name        = azurerm_resource_group.rg_twinbots.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
    ]

    secret_permissions = [
      "Get",
      "List",
    ]
  }

}
