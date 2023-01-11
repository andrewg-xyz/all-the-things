variable "pm_api_url" {}
variable "pm_user" {}
variable "pm_password" {}
variable "vm_ip" {}
variable "vm_gw" {}
variable "user_secret" {}

module "node01" {
    source = "../../modules/k3s_node"

    # Proxmox 
    pm_api_url = var.pm_api_url
    pm_user = var.pm_user
    pm_password = var.pm_password
    
    # Resource
    name = "test-node01"
    target_node = "bane"
    vm_ip = var.vm_ip
    vm_gw = var.vm_gw
    ssh_key_public = "${file("/Users/agreene/.ssh/id_ed25519.pub")}"
    user_secret = var.user_secret
}