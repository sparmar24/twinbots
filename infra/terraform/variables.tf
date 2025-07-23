variable "django_secret_key" {
  description = "Django secret key"
  type        = string
}

variable "openai_api_key" {
  description = "OpenAI API key"
  type        = string
}

variable "azsubscription_id" {
  description = "PostgreSQL DB port"
  type        = string 
}

variable "az_location" {
  default     = "North Europe"
  description = "region for resources"
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

variable "pg_name" {
  description = "PostgreSQL DB name"
  type        = string
}

variable "pg_port" {
  description = "PostgreSQL DB port"
  type        = number 
}
