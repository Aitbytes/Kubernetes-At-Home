variable "region" {
  description = "Region where the ressource are deployed"
  type        = string
}

variable "zone" {
  description = "Zone where the ressource are deployed"
  type        = string
}

variable "project_id" {
  description = "ID of the project"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
}

variable "domain" {
  description = "Your domain name"
}
