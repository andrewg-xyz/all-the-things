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

resource "random_string" "random" {
  length  = 16
  special = false
}

module "server-node" {
  count  = var.node_count
  source = "../../proxmox/node"
  # Proxmox 
  pm_api_url  = var.pm_api_url
  pm_user     = var.pm_user
  pm_password = var.pm_password

  # Resource
  index          = count.index
  vmid           = var.vmid_base + count.index
  name           = "rke2-svr-${count.index}"
  vm_ip          = "${var.vm_ip_base}${var.vm_ip_start + count.index}"
  vm_gw          = var.vm_gw
  ssh_key_public = file("${var.pub_ssh_key_path}")
  user_secret    = var.user_secret
}

resource "null_resource" "configure-server-node" {
  depends_on = [ module.server-node ]
  count = length(module.server-node[*])

  connection {
    host        = module.server-node[count.index].node_ip
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
      "sudo mkdir -p /root/rke2-artifacts",
      "sudo cp /tmp/rke2-artifacts/* /root/rke2-artifacts/",
      "sudo cp /tmp/rke2-install.sh /root/rke2-install.sh",
      "sudo chmod +x /root/rke2-install.sh",
      "sudo /root/rke2-install.sh -t ${random_string.random.result} -s ${module.server-node[0].node_ip} -d || true", # || true because the rke2 install process handles failures. systemctl returns in error on first failure, but will retry until successful
    ]
  }
}

# This could be done with terraform output, but that seems to require a whole bunch of crap to translate
resource "null_resource" "copy-kubeconfig" {
  depends_on = [
    null_resource.configure-server-node[0]
  ]
  provisioner "local-exec" {
    command = "scp ${module.server-node[0].node_ip}:/home/user/.kube/config . && sed -i'.bak' \"s|127.0.0.1|${module.server-node[0].node_ip}|g\" config"
  }
}
