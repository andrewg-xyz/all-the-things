output "node_ip" {
    value = proxmox_vm_qemu.virtualmachine.ssh_host
}