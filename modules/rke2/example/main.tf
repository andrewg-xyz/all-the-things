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

module "rke2-servers" {
  source     = "../server"
  node_count = 3

  pm_api_url  = var.pm_api_url
  pm_user     = var.pm_user
  pm_password = var.pm_password

  vmid_base        = 1000
  vm_ip_base       = var.vm_ip_base
  vm_ip_start      = var.vm_ip_start
  user_secret      = var.user_secret
  pub_ssh_key_path = var.pub_ssh_key_path
  priv_ssh_key_path= var.priv_ssh_key_path
  vm_gw            = var.vm_gw
}


