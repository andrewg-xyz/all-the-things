variable "pm_api_url" {}
variable "pm_user" {}
variable "pm_password" {}
variable "vm_gw" {}
variable "user_secret" {}
variable "pub_ssh_key_path" {}
variable "priv_ssh_key_path" {}
variable "vm_ip_base" {}

locals {
  node0 = {
    ip = "${var.vm_ip_base}0"
    name = "mini00"
    vmid = "1100"
    target_node = "bane"
  }

}

module "node0" {
  source = "../../../../modules/base_node"

  # Proxmox 
  pm_api_url  = var.pm_api_url
  pm_user     = var.pm_user
  pm_password = var.pm_password

  # Resource
  vmid           = local.node0.vmid
  name           = local.node0.name
  target_node    = local.node0.target_node
  vm_ip          = local.node0.ip
  vm_gw          = var.vm_gw
  ssh_key_public = file("${var.pub_ssh_key_path}")
  user_secret    = var.user_secret
}

resource "null_resource" "configure-node0" {
  depends_on = [
    module.node0
  ]

  connection {
    host        = local.node0.ip
    user        = "user"
    private_key = file("${var.priv_ssh_key_path}")
    agent       = true
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "./k3s.sh"
    destination = "/tmp/k3s.sh"
  }

  provisioner "remote-exec" {
    inline = [
      # Having issue "(remote-exec): Warning! D-Bus connection terminated." and debugging is difficult. hoping giving the VM longer to initialize will help
      "sleep 20",
      # format and mount disk  
      "sudo mkdir /var/lib/rancher",
      "sudo mkfs.ext4 /dev/sdb",
      "sudo mount /dev/sdb /var/lib/rancher",
      # install k3s
      "chmod +x /tmp/k3s.sh",
      "/tmp/k3s.sh -m -n ${local.node0.name} -t ${random_string.random.result} -s https://${local.node0.ip}:6443 -d",
      "sudo mkdir /home/user/.kube",
      "sudo cp /etc/rancher/k3s/k3s.yaml /home/user/.kube/config",
      "sudo chown user:user /home/user/.kube/config"
    ]
  }
}

# This could be done with terraform output, but that seems to require a whole bunch of crap to translate
resource "null_resource" "copy-kubeconfig" {
  depends_on = [
    null_resource.configure-node0
  ]
  provisioner "local-exec" {
    command = "scp ${local.node0.ip}:/home/user/.kube/config . && sed -i'.bak' \"s|127.0.0.1|${local.node0.ip}|g\" config"
  }
}

resource "random_string" "random" {
  length  = 16
  special = false
}
