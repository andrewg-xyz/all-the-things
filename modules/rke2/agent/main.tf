terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

resource "null_resource" "rke2-artifacts" {
  provisioner "local-exec" {
    command = "../common/get-rke2-artifacts.sh"
  }
}

module "agent-node" {
  count  = var.node_count
  source = "../../proxmox/node"
  # Proxmox 
  pm_api_url  = var.pm_api_url
  pm_user     = var.pm_user
  pm_password = var.pm_password

  # Resource
  index          = count.index
  vmid           = var.vmid_base + count.index + var.offset
  name           = "rke2-agent-${count.index}"
  vm_ip          = "${var.vm_ip_base}${var.vm_ip_start + count.index + var.offset}"
  vm_gw          = var.vm_gw
  ssh_key_public = file("${var.pub_ssh_key_path}")
  user_secret    = var.user_secret
}

resource "null_resource" "configure-agent-node" {
  depends_on = [ module.agent-node ]
  count = length(module.agent-node[*])

  connection {
    host        = module.agent-node[count.index].node_ip
    user        = "user"
    private_key = file("${var.priv_ssh_key_path}")
    agent       = true
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "./rke2-artifacts"
    destination = "/tmp/rke2-artifacts"
  }

  provisioner "file" {
    source      = "../common/rke2-install.sh"
    destination = "/tmp/rke2-install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      # Having issue "(remote-exec): Warning! D-Bus connection terminated." and debugging is difficult. hoping giving the VM longer to initialize will help
      "sleep 20",
      # format and mount disk  
      "sudo mkdir /var/lib/rancher",
      "sudo mkfs.ext4 /dev/sdb",
      "sudo mount /dev/sdb /var/lib/rancher",
      # install rke2
      "sudo chmod +x /tmp/rke2-install.sh",
      "sudo /tmp/rke2-install.sh ${var.token} ${var.server_ip} 0 1 || true", # || true because the rke2 install process handles failures. systemctl returns in error on first failure, but will retry until successful
    ]
  }
}