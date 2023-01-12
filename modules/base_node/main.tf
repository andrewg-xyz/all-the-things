resource "proxmox_vm_qemu" "virtualmachine" {
  name        = var.name
  desc        = "base node"
  vmid        = var.vmid
  target_node = var.target_node
  pool        = ""
  ipconfig0   = "ip=${var.vm_ip}/24,gw=${var.vm_gw}"
  agent       = var.qemu_agent
  clone       = var.clone_template
  full_clone  = false
  memory      = var.memory
  cores       = var.cores
  sockets     = 1
  vcpus       = 0
  cpu         = "host"
  os_type     = var.os_type
  sshkeys     = var.ssh_key_public
  ciuser      = var.ssh_user
  cipassword  = var.user_secret
  scsihw      = "virtio-scsi-pci"

  disk {
    type    = var.disk_type
    storage = var.storage_pool
    size    = var.primary_disk_size
  }

  disk {
    type    = var.disk_type
    storage = var.storage_pool
    size    = var.secondary_disk_size
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
}
