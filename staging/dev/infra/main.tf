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
    name = "dev00"
    vmid = "1000"
    target_node = "bane"
  }
  node1 = {
    ip = "${var.vm_ip_base}1"
    name = "dev01"
    vmid = "1001"
    target_node = "bane"
  }
  node2 = {
    ip = "${var.vm_ip_base}2"
    name = "dev02"
    vmid = "1002"
    target_node = "bane"
  }
  node3 = {
    ip = "${var.vm_ip_base}3"
    name = "dev03"
    vmid = "1003"
    target_node = "revan"
  }
  node4 = {
    ip = "${var.vm_ip_base}4"
    name = "dev04"
    vmid = "1004"
    target_node = "bane"
  }
  node5 = {
    ip = "${var.vm_ip_base}5"
    name = "dev05"
    vmid = "1005"
    target_node = "revan"
  }
  node6 = {
    ip = "${var.vm_ip_base}6"
    name = "dev06"
    vmid = "1006"
    target_node = "bane"
  }
  node7 = {
    ip = "${var.vm_ip_base}7"
    name = "dev07"
    vmid = "1007"
    target_node = "revan"
  }
  node8 = {
    ip = "${var.vm_ip_base}8"
    name = "dev08"
    vmid = "1008"
    target_node = "bane"
  }
}

resource "null_resource" "rke2-artifacts" {
  provisioner "local-exec" {
    command = "../../../scripts/get-rke2-artifacts.sh"
  }
}

module "node0" {
  source = "../../../modules/base_node"
  clone_template = "ubuntu-ci-template-v2"

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
    module.node0,
    null_resource.rke2-artifacts,
    random_string.random
  ]

  connection {
    host        = local.node0.ip
    user        = "user"
    private_key = file("${var.priv_ssh_key_path}")
    agent       = true
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "./rke2-artifacts"
    destination = "/tmp/rke2-artifacts"
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
      "sudo mkdir -p /etc/rancher/rke2",
      "echo \"token: ${random_string.random.result}\" | sudo tee /etc/rancher/rke2/config.yaml > /dev/null",
      "sudo INSTALL_RKE2_ARTIFACT_PATH=/tmp/rke2-artifacts/ sh /tmp/rke2-artifacts/install.sh",
      "sudo systemctl enable rke2-server.service",
      "sudo systemctl start rke2-server.service",
      "mkdir /home/user/.kube",
      "sudo cp /etc/rancher/rke2/rke2.yaml /home/user/.kube/config",
      "sudo chown user:user /home/user/.kube/config"
    ]
  }
}

module "node1" {
  source = "../../../modules/base_node"

  # Proxmox 
  pm_api_url  = var.pm_api_url
  pm_user     = var.pm_user
  pm_password = var.pm_password

  # Resource
  vmid           = local.node1.vmid
  name           = local.node1.name
  target_node    = local.node1.target_node
  vm_ip          = local.node1.ip
  vm_gw          = var.vm_gw
  ssh_key_public = file("${var.pub_ssh_key_path}")
  user_secret    = var.user_secret
}

resource "null_resource" "configure-node1" {
  depends_on = [
    module.node1,
    resource.null_resource.configure-node0
  ]

  connection {
    host        = local.node1.ip
    user        = "user"
    private_key = file("${var.priv_ssh_key_path}")
    agent       = true
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "./rke2-artifacts"
    destination = "/tmp/rke2-artifacts"
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
      "sudo mkdir -p /etc/rancher/rke2",
      "echo \"token: ${random_string.random.result}\" | sudo tee /etc/rancher/rke2/config.yaml > /dev/null",
      "sudo bash -c 'echo \"server: https://${local.node0.ip}:9345\" >> /etc/rancher/rke2/config.yaml'",
      "sudo INSTALL_RKE2_ARTIFACT_PATH=/tmp/rke2-artifacts/ sh /tmp/rke2-artifacts/install.sh",
      "sudo systemctl enable rke2-server.service",
      "sudo systemctl start rke2-server.service",
      "mkdir /home/user/.kube",
      "sudo cp /etc/rancher/rke2/rke2.yaml /home/user/.kube/config",
      "sudo chown user:user /home/user/.kube/config"
    ]
  }
}

# module "node2" {
#   source = "../../../modules/base_node"

#   # Proxmox 
#   pm_api_url  = var.pm_api_url
#   pm_user     = var.pm_user
#   pm_password = var.pm_password

#   # Resource
#   vmid           = local.node2.vmid
#   name           = local.node2.name
#   target_node    = local.node2.target_node
#   vm_ip          = local.node2.ip
#   vm_gw          = var.vm_gw
#   ssh_key_public = file("${var.pub_ssh_key_path}")
#   user_secret    = var.user_secret
# }

# resource "null_resource" "configure-node2" {
#   depends_on = [
#     module.node2,
#     resource.null_resource.configure-node1
#   ]

#   connection {
#     host        = local.node2.ip
#     user        = "user"
#     private_key = file("${var.priv_ssh_key_path}")
#     agent       = true
#     timeout     = "2m"
#   }

#   provisioner "file" {
#     source      = "../../../scripts/k3s.sh"
#     destination = "/tmp/k3s.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       # Having issue "(remote-exec): Warning! D-Bus connection terminated." and debugging is difficult. hoping giving the VM longer to initialize will help
#       "sleep 20",
#       # format and mount disk  
#       "sudo mkdir /var/lib/rancher",
#       "sudo mkfs.ext4 /dev/sdb",
#       "sudo mount /dev/sdb /var/lib/rancher",
#       # install k3s
#       "chmod +x /tmp/k3s.sh",
#       "/tmp/k3s.sh -n ${local.node2.name} -t ${random_string.random.result} -s https://${local.node0.ip}:6443 -d",

#     ]
#   }
# }

# module "node3" {
#   source = "../../../modules/base_node"

#   # Proxmox 
#   pm_api_url  = var.pm_api_url
#   pm_user     = var.pm_user
#   pm_password = var.pm_password

#   # Resource
#   vmid           = local.node3.vmid
#   name           = local.node3.name
#   target_node    = local.node3.target_node
#   vm_ip          = local.node3.ip
#   vm_gw          = var.vm_gw
#   ssh_key_public = file("${var.pub_ssh_key_path}")
#   user_secret    = var.user_secret
# }

# resource "null_resource" "configure-node3" {
#   depends_on = [
#     module.node3,
#     resource.null_resource.configure-node2
#   ]

#   connection {
#     host        = local.node3.ip
#     user        = "user"
#     private_key = file("${var.priv_ssh_key_path}")
#     agent       = true
#     timeout     = "2m"
#   }

#   provisioner "file" {
#     source      = "../../../scripts/k3s.sh"
#     destination = "/tmp/k3s.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       # Having issue "(remote-exec): Warning! D-Bus connection terminated." and debugging is difficult. hoping giving the VM longer to initialize will help
#       "sleep 20",
#       # format and mount disk  
#       "sudo mkdir /var/lib/rancher",
#       "sudo mkfs.ext4 /dev/sdb",
#       "sudo mount /dev/sdb /var/lib/rancher",
#       # install k3s
#       "chmod +x /tmp/k3s.sh",
#       "/tmp/k3s.sh -n ${local.node3.name} -t ${random_string.random.result} -s https://${local.node0.ip}:6443 -d",

#     ]
#   }
# }

# module "node4" {
#   source = "../../../modules/base_node"

#   # Proxmox 
#   pm_api_url  = var.pm_api_url
#   pm_user     = var.pm_user
#   pm_password = var.pm_password

#   # Resource
#   vmid           = local.node4.vmid
#   name           = local.node4.name
#   target_node    = local.node4.target_node
#   vm_ip          = local.node4.ip
#   vm_gw          = var.vm_gw
#   ssh_key_public = file("${var.pub_ssh_key_path}")
#   user_secret    = var.user_secret
# }

# resource "null_resource" "configure-node4" {
#   depends_on = [
#     module.node4,
#     resource.null_resource.configure-node3
#   ]

#   connection {
#     host        = local.node4.ip
#     user        = "user"
#     private_key = file("${var.priv_ssh_key_path}")
#     agent       = true
#     timeout     = "2m"
#   }

#   provisioner "file" {
#     source      = "../../../scripts/k3s.sh"
#     destination = "/tmp/k3s.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       # Having issue "(remote-exec): Warning! D-Bus connection terminated." and debugging is difficult. hoping giving the VM longer to initialize will help
#       "sleep 20",
#       # format and mount disk  
#       "sudo mkdir /var/lib/rancher",
#       "sudo mkfs.ext4 /dev/sdb",
#       "sudo mount /dev/sdb /var/lib/rancher",
#       # install k3s
#       "chmod +x /tmp/k3s.sh",
#       "/tmp/k3s.sh -n ${local.node4.name} -t ${random_string.random.result} -s https://${local.node0.ip}:6443 -d",

#     ]
#   }
# }

# module "node5" {
#   source = "../../../modules/base_node"

#   # Proxmox 
#   pm_api_url  = var.pm_api_url
#   pm_user     = var.pm_user
#   pm_password = var.pm_password

#   # Resource
#   vmid           = local.node5.vmid
#   name           = local.node5.name
#   target_node    = local.node5.target_node
#   vm_ip          = local.node5.ip
#   vm_gw          = var.vm_gw
#   ssh_key_public = file("${var.pub_ssh_key_path}")
#   user_secret    = var.user_secret
# }

# resource "null_resource" "configure-node5" {
#   depends_on = [
#     module.node5,
#     resource.null_resource.configure-node4
#   ]

#   connection {
#     host        = local.node5.ip
#     user        = "user"
#     private_key = file("${var.priv_ssh_key_path}")
#     agent       = true
#     timeout     = "2m"
#   }

#   provisioner "file" {
#     source      = "../../../scripts/k3s.sh"
#     destination = "/tmp/k3s.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       # Having issue "(remote-exec): Warning! D-Bus connection terminated." and debugging is difficult. hoping giving the VM longer to initialize will help
#       "sleep 20",
#       # format and mount disk  
#       "sudo mkdir /var/lib/rancher",
#       "sudo mkfs.ext4 /dev/sdb",
#       "sudo mount /dev/sdb /var/lib/rancher",
#       # install k3s
#       "chmod +x /tmp/k3s.sh",
#       "/tmp/k3s.sh -n ${local.node5.name} -t ${random_string.random.result} -s https://${local.node0.ip}:6443 -d",

#     ]
#   }
# }

# module "node6" {
#   source = "../../../modules/base_node"

#   # Proxmox 
#   pm_api_url  = var.pm_api_url
#   pm_user     = var.pm_user
#   pm_password = var.pm_password

#   # Resource
#   vmid           = local.node6.vmid
#   name           = local.node6.name
#   target_node    = local.node6.target_node
#   vm_ip          = local.node6.ip
#   vm_gw          = var.vm_gw
#   ssh_key_public = file("${var.pub_ssh_key_path}")
#   user_secret    = var.user_secret
# }

# resource "null_resource" "configure-node6" {
#   depends_on = [
#     module.node6,
#     resource.null_resource.configure-node5
#   ]

#   connection {
#     host        = local.node6.ip
#     user        = "user"
#     private_key = file("${var.priv_ssh_key_path}")
#     agent       = true
#     timeout     = "2m"
#   }

#   provisioner "file" {
#     source      = "../../../scripts/k3s.sh"
#     destination = "/tmp/k3s.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       # Having issue "(remote-exec): Warning! D-Bus connection terminated." and debugging is difficult. hoping giving the VM longer to initialize will help
#       "sleep 20",
#       # format and mount disk  
#       "sudo mkdir /var/lib/rancher",
#       "sudo mkfs.ext4 /dev/sdb",
#       "sudo mount /dev/sdb /var/lib/rancher",
#       # install k3s
#       "chmod +x /tmp/k3s.sh",
#       "/tmp/k3s.sh -n ${local.node6.name} -t ${random_string.random.result} -s https://${local.node0.ip}:6443 -d",

#     ]
#   }
# }

# module "node7" {
#   source = "../../../modules/base_node"

#   # Proxmox 
#   pm_api_url  = var.pm_api_url
#   pm_user     = var.pm_user
#   pm_password = var.pm_password

#   # Resource
#   vmid           = local.node7.vmid
#   name           = local.node7.name
#   target_node    = local.node7.target_node
#   vm_ip          = local.node7.ip
#   vm_gw          = var.vm_gw
#   ssh_key_public = file("${var.pub_ssh_key_path}")
#   user_secret    = var.user_secret
# }

# resource "null_resource" "configure-node7" {
#   depends_on = [
#     module.node7,
#     resource.null_resource.configure-node6
#   ]

#   connection {
#     host        = local.node7.ip
#     user        = "user"
#     private_key = file("${var.priv_ssh_key_path}")
#     agent       = true
#     timeout     = "2m"
#   }

#   provisioner "file" {
#     source      = "../../../scripts/k3s.sh"
#     destination = "/tmp/k3s.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       # Having issue "(remote-exec): Warning! D-Bus connection terminated." and debugging is difficult. hoping giving the VM longer to initialize will help
#       "sleep 20",
#       # format and mount disk  
#       "sudo mkdir /var/lib/rancher",
#       "sudo mkfs.ext4 /dev/sdb",
#       "sudo mount /dev/sdb /var/lib/rancher",
#       # install k3s
#       "chmod +x /tmp/k3s.sh",
#       "/tmp/k3s.sh -n ${local.node7.name} -t ${random_string.random.result} -s https://${local.node0.ip}:6443 -d",

#     ]
#   }
# }

# module "node8" {
#   source = "../../../modules/base_node"

#   # Proxmox 
#   pm_api_url  = var.pm_api_url
#   pm_user     = var.pm_user
#   pm_password = var.pm_password

#   # Resource
#   vmid           = local.node8.vmid
#   name           = local.node8.name
#   target_node    = local.node8.target_node
#   vm_ip          = local.node8.ip
#   vm_gw          = var.vm_gw
#   ssh_key_public = file("${var.pub_ssh_key_path}")
#   user_secret    = var.user_secret
# }

# resource "null_resource" "configure-node8" {
#   depends_on = [
#     module.node8,
#     resource.null_resource.configure-node7
#   ]

#   connection {
#     host        = local.node8.ip
#     user        = "user"
#     private_key = file("${var.priv_ssh_key_path}")
#     agent       = true
#     timeout     = "2m"
#   }

#   provisioner "file" {
#     source      = "../../../scripts/k3s.sh"
#     destination = "/tmp/k3s.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       # Having issue "(remote-exec): Warning! D-Bus connection terminated." and debugging is difficult. hoping giving the VM longer to initialize will help
#       "sleep 20",
#       # format and mount disk  
#       "sudo mkdir /var/lib/rancher",
#       "sudo mkfs.ext4 /dev/sdb",
#       "sudo mount /dev/sdb /var/lib/rancher",
#       # install k3s
#       "chmod +x /tmp/k3s.sh",
#       "/tmp/k3s.sh -n ${local.node8.name} -t ${random_string.random.result} -s https://${local.node0.ip}:6443 -d",
#     ]
#   }
# }

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
