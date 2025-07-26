variable "django_secret_key" {
  description = "Django secret key"
  type        = string
}

variable "openai_api_key" {
  description = "OpenAI API key"
  type        = string
}

variable "azsubscription_id" {
  description = "Azure Subscription id"
  type        = string
}

variable "az_location" {
  default     = "North Europe"
  description = "region for resources"
  type        = string
}

variable "pg_user_server" {
  description = "PostgreSQL name=user@server for app"
  type        = string
}

variable "pg_user" {
  description = "PostgreSQL admin user"
  type        = string
}

variable "pg_password" {
  description = "PostgreSQL admin password"
  type        = string
}

variable "pg_host" {
  description = "PostgreSQL DB host"
  type        = string
}

variable "pg_server" {
  description = "PostgreSQL DB server"
  type        = string
}

variable "pg_port" {
  description = "PostgreSQL DB port"
  type        = number
}

variable "pg_version" {
  description = "PostgreSQL DB version"
  type        = number
}
