variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
  sensitive   = true
}

variable "pm_api_token_id" {
  description = "Proxmox Token ID for authentication"
  type        = string
  sensitive   = true
}
variable "pm_api_token_secret" {
  description = "Proxmox API token secret value"
  type        = string
  sensitive   = true
}

