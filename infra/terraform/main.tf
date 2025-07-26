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

resource "azurerm_user_assigned_identity" "identity_twinbots" {
  name                = "identity-twinbots"
  location            = azurerm_resource_group.rg_twinbots.location
  resource_group_name = azurerm_resource_group.rg_twinbots.name

  tags = {
    ENV = "Test"
  }
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

# Assign acrpull role to the user assigned identity
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr_twinbots.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.identity_twinbots.principal_id
}

# Create app service plan
resource "azurerm_service_plan" "asp_twinbots" {
  name                = "asp-twinbots"
  location            = azurerm_resource_group.rg_twinbots.location
  resource_group_name = azurerm_resource_group.rg_twinbots.name
  sku_name            = "F1" # Free tier
  os_type             = "Linux"
  # capacity = 1
}

# create the web app using Docker container from ACR
resource "azurerm_linux_web_app" "django_web_app" {
  name                = "django-web-app"
  location            = azurerm_resource_group.rg_twinbots.location
  resource_group_name = azurerm_resource_group.rg_twinbots.name
  service_plan_id     = azurerm_service_plan.asp_twinbots.id

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.identity_twinbots.id
    ]
  }

  depends_on = [
    azurerm_service_plan.asp_twinbots
  ]
  site_config {
    always_on = false
    application_stack {
      docker_image_name        = "twinbots-web:latest"
      docker_registry_url      = "https://${azurerm_container_registry.acr_twinbots.login_server}"
      docker_registry_username = azurerm_container_registry.acr_twinbots.admin_username
      docker_registry_password = azurerm_container_registry.acr_twinbots.admin_password
    }
  }
  app_settings = {
    DEBUG             = "False"
    DJANGO_SECRET_KEY = var.django_secret_key
    OPENAI_API_KEY    = var.openai_api_key
    PG_NAME           = var.pg_user_server
    PG_USER           = var.pg_user
    PG_PASSWORD       = var.pg_password
    PG_HOST           = var.pg_host
    PG_PORT           = var.pg_port
    WEBSITES_PORT     = "8000"
    ALLOWED_HOSTS     = "django-web-app.azurewebsites.net"
  }

  tags = {
    ENV = "Test"
  }
}

# PostgresSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "postgres_twinbots" {
  name                   = var.pg_server
  resource_group_name    = azurerm_resource_group.rg_twinbots.name
  location               = azurerm_resource_group.rg_twinbots.location
  administrator_login    = var.pg_user
  administrator_password = var.pg_password
  create_mode            = "Default"
  version                = var.pg_version
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  backup_retention_days  = 7

  authentication {
    password_auth_enabled = true
  }
}

# PostgresSQL Database
resource "azurerm_postgresql_flexible_server_database" "db_twinbots" {
  name      = var.pg_user
  server_id = azurerm_postgresql_flexible_server.postgres_twinbots.id
  collation = "C"
  charset   = "UTF8"

}

# Firewall rule for PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.postgres_twinbots.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}



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
