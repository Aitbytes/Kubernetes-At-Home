provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_record" "master_dns" {
  for_each = {
    for instance in google_compute_instance.vms :
    instance.name => instance.network_interface[0].access_config[0].nat_ip
    if can(regex("-m$", instance.name))
  }

  zone_id = var.cloudflare_zone_id
  name    = each.key
  value   = each.value
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "worker_dns" {
  for_each = {
    for instance in google_compute_instance.vms :
    instance.name => instance.network_interface[0].access_config[0].nat_ip
    if can(regex("-w$", instance.name))
  }

  zone_id = var.cloudflare_zone_id
  name    = each.key
  value   = each.value
  type    = "A"
  proxied = false
}
