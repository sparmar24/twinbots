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
  subscription_id                 = var.azsubscription_id 
}
provider "azapi" {
}

# Create resource group 
resource "azurerm_resource_group" "rg_twinbots" {
  name     = "rg_twinbots"
  location = var.az_location
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
# resource "azurerm_kubernetes_cluster" "akc_twinbots" {
#   name                              = "akc_twinbots"
#   resource_group_name               = azurerm_resource_group.rg_twinbots.name
#   location                          = azurerm_resource_group.rg_twinbots.location
#   dns_prefix                        = "exampleaks1"
#   role_based_access_control_enabled = true
#
#   default_node_pool {
#     name = "default"
#     tags = {}
#     upgrade_settings {
#       drain_timeout_in_minutes      = 0
#       max_surge                     = "10%"
#       node_soak_duration_in_minutes = 0
#     }
#     node_count = 1
#     vm_size    = "Standard_B2s"
#   }
#
#   identity {
#     type = "SystemAssigned"
#   }
#
#   tags = {
#     ENV = "Test"
#   }
#
#   # Attach ACR to AKS (so AKS can pull images)
#   depends_on = [azurerm_container_registry.acr_twinbots, azurerm_kubernetes_cluster.akc_twinbots]
# }
#
# Assign ACR pull permission to AKS managed identity
# resource "azurerm_role_assignment" "acr_pull" {
#   scope                = azurerm_container_registry.acr_twinbots.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_kubernetes_cluster.akc_twinbots.identity[0].principal_id
#   depends_on           = [azurerm_kubernetes_cluster.akc_twinbots]
# }

# Create app service plan
resource "azurerm_service_plan" "asp_twinbots" {
  name                = "asp-twinbots"
  location            = azurerm_resource_group.rg_twinbots.location
  resource_group_name = azurerm_resource_group.rg_twinbots.name
  sku_name           = "F1" # Free tier
  os_type            = "Linux"
  # capacity = 1
  }

resource "azurerm_linux_web_app" "django_web_app" {
  name                = "django-web-app"
  location            = azurerm_resource_group.rg_twinbots.location
  resource_group_name = azurerm_resource_group.rg_twinbots.name
  service_plan_id     = azurerm_service_plan.asp_twinbots.id

  depends_on = [
    azurerm_service_plan.asp_twinbots
  ]
  site_config {
    always_on = false 
    # linux_fx_version = "DOCKER|${azurerm_container_registry.acr_twinbots.login_server}twinbots-web:latest"
  }
    #
    #   DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.acr_twinbots.login_server}"
    #   DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.acr_twinbots.admin_username
    #   DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.acr_twinbots.admin_password

app_settings = {
    WEBSITES_PORT                     = "8000"
    DEBUG                           = "False"
    DJANGO_SECRET_KEY               = var.django_secret_key 
    OPENAI_API_KEY                  = var.openai_api_key
    # DJANGO_SETTINGS_MODULE          = "twinbots.settings"
    DJANGO_SETTINGS_MODULE          = "coresite.settings"
    # "DATABASE_URL"                    = "pg_nameostgres://user:password@hostname:port/dbname"
    DATABASE_URL                    = "postgresql://${var.pg_user}:${var.pg_password}@${var.pg_host}:${var.pg_port}/${var.pg_name}"
    ALLOWED_HOSTS                   = "django-web-app.azurewebsites.net"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }
}

# PostgresSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "postgres_twinbots" {
  name                = "postgres-twinbots"
  resource_group_name = azurerm_resource_group.rg_twinbots.name
  location            = azurerm_resource_group.rg_twinbots.location
  administrator_login = var.pg_user
  administrator_password = var.pg_password
  create_mode        = "Default"
  version             = "13"
  zone                = "1"
  storage_mb          = 32768
  sku_name            = "GP_Standard_D2s_v3"
  backup_retention_days = 7

authentication {
    password_auth_enabled = true
  }

  # high_availability {
  #   mode = "ZoneRedundant"
  # }
  
  # network {
  #   public_network_access_enabled = true
  # }
}

# PostgresSQL Database
  resource "azurerm_postgresql_flexible_server_database" "db_twinbots" {
    name                = "twinbotsdb"
    server_id           = azurerm_postgresql_flexible_server.postgres_twinbots.id
    collation           = "C"
    charset             = "UTF8"

  }

# Firewall rule for PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  server_id           = azurerm_postgresql_flexible_server.postgres_twinbots.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}


data "azurerm_client_config" "current" {}

# resource "azurerm_key_vault" "kv_twinbots" {
#   name                       = "kv-twinbots"
#   location                   = azurerm_resource_group.rg_twinbots.location
#   resource_group_name        = azurerm_resource_group.rg_twinbots.name
#   tenant_id                  = data.azurerm_client_config.current.tenant_id
#   sku_name                   = "standard"
#   soft_delete_retention_days = 7
#   purge_protection_enabled   = true
#
#   network_acls {
#     bypass         = "AzureServices"
#     default_action = "Allow"
#   }
#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = data.azurerm_client_config.current.object_id
#
#     key_permissions = [
#       "Get",
#       "List",
#     ]
#
#     secret_permissions = [
#       "Get",
#       "List",
#     ]
#   }
#
# }
