## Provider (must be provided by the user of the module)
variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "pm_user" {
  description = "Proxmox API User"
  type        = string
}

variable "pm_password" {
  description = "Proxmox API Password"
  type        = string
}

## Resource
### (must be provided by the user of the module)
variable "name" {
  description = "The name of the virtualmachine"
  type        = string
}

variable "target_node" {
  description = "The name of the target node"
  type        = string
}

variable "vm_ip" {
  description = "IP of resource, x.x.x.x"
  type        = string
}

variable "vm_gw" {
  description = "Network Gateway"
  type        = string
}

variable "ssh_key_public" {
  description = "SSH public key"
  type        = string
}

variable "user_secret" {
  description = "User secret"
  type        = string
}

### (optionally provided by the user of the module)
variable "vmid" {
  description = "The ID of the virtualmachine"
  type        = string
  default     = 0
}

variable "qemu_agent" {
  description = "Enable qemu guest agent"
  type        = number
  default     = 1
}

variable "clone_template" {
  description = "Source template to clone"
  type        = string
  default     = "ubuntu-ci-template"
}

variable "memory" {
  description = "Memory for each node"
  type        = string 
  default     = "16384"
}

variable "cores" {
  description = "Cores for each node"
  type        = number
  default     = 6
}

variable "os_type" {
  description = "OS Type, cloud-init"
  type        = string
  default     = "cloud-init"
}

variable "ssh_user" {
  description = "Username for ssh"
  type        = string
  default     = "user"
}

variable "disk_type" {
  type    = string
  default = "scsi"
}

variable "storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "primary_disk_size" {
  type    = string
  default = "25G"
}

variable "secondary_disk_size" {
  type    = string
  default = "100G"
}
