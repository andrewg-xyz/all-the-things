variable "pm_api_url" {}
variable "pm_user" {}
variable "pm_password" {}
variable "vm_ip" {}
variable "vm_gw" {}
variable "user_secret" {}
variable "pub_ssh_key_path" {}
variable "priv_ssh_key_path" {}

module "node01" {
  source = "../../modules/k3s_node"

  # Proxmox 
  pm_api_url  = var.pm_api_url
  pm_user     = var.pm_user
  pm_password = var.pm_password

  # Resource
  name           = "test-node01"
  target_node    = "bane"
  vm_ip          = var.vm_ip
  vm_gw          = var.vm_gw
  ssh_key_public = file("${var.pub_ssh_key_path}")
  user_secret    = var.user_secret
}

resource "null_resource" "configure-node01" {
  depends_on = [
    module.node01
  ]

  connection {
    host        = var.vm_ip
    user        = "user"
    private_key = file("${var.priv_ssh_key_path}")
    agent       = true
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "../../scripts/k3s.sh"
    destination = "/tmp/k3s.sh"
  }

  provisioner "remote-exec" {
    inline = [
      # format and mount disk  
      "sudo mkdir /var/lib/rancher",
      "sudo mkfs.ext4 /dev/sdb",
      "sudo mount /dev/sdb /var/lib/rancher",
      # install k3s
      "chmod +x /tmp/k3s.sh",
      "/tmp/k3s.sh -m -n kv0 -t ${random_string.random.result} -s https://${var.vm_ip}:6443 -d",
      "sudo mkdir /home/user/.kube",
      "sudo cp /etc/rancher/k3s/k3s.yaml /home/user/.kube/config",
      "sudo chown user:user /home/user/.kube/config"
    ]
  }
}

# This could be done with terraform output, but that seems to require a whole bunch of crap to translate
resource "null_resource" "copy-kubeconfig" {
  depends_on = [
    null_resource.configure-node01
  ]
  provisioner "local-exec" {
    command = "scp ${var.vm_ip}:/home/user/.kube/config . && sed -i'.bak' \"s|127.0.0.1|${var.vm_ip}|g\" config"
  }
}

resource "random_string" "random" {
  length  = 16
  special = false
}
