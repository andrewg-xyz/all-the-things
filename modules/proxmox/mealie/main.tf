terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
}

module "node" {
  count  = 1
  source = "../node"
  # Proxmox
  pm_api_url  = var.pm_api_url
  pm_user     = var.pm_user
  pm_password = var.pm_password

  # Resource
  index          = count.index
  vmid           = 101 + "${count.index}"
  name           = "mealie"
  vm_ip          = "${var.vm_ip_base}${var.vm_ip_start + count.index}"
  vm_gw          = var.vm_gw
  ssh_key_public = file("${var.pub_ssh_key_path}")
  user_secret    = var.user_secret
}
