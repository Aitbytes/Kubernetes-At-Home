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
variable "ciuser" {
  description = "Default User for everynode"
  type        = string
  sensitive   = true
}
variable "cipassword" {
  description = "Default User password for everynode"
  type        = string
  sensitive   = true
}

