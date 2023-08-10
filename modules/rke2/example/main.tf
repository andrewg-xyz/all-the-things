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
  node_count = 2

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

module "rke2-agents" {
  depends_on = [ module.rke2-servers ]
  source = "../agent"
  node_count = 1
  offset = 2 #match module.rke2-servers.node_count
  server_ip = module.rke2-servers.server_ip
  token = module.rke2-servers.token

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


