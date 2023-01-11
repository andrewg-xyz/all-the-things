# Infrastructure provisioning

Leveraging [Telmate proxmox provider](https://github.com/Telmate/terraform-provider-proxmox) to use terraform to deploy VMs into the proxmox cluster.

## deploying

!!! Work in Progress !!!

1. See [../modules/k3d_node] for the common module reused across these deployments
2. See [../staging/cluster_up] for a current example on deployment. Note: this is incomplete, but successful deploys a VM from a cloud init template (with network/login)

Before running `terraform plan/apply` I store secrets/sensitive data in an `.env` file and `source .env`

Ex. 
```
export TF_VAR_pm_api_url="https://wherever-yo-proxmox-lives:8006/api2/json"
export TF_VAR_pm_user="your-user@pam"
export TF_VAR_pm_password="your-secret"
export TF_VAR_vm_gw="123.123.123.123"
export TF_VAR_vm_ip="123.123.123.1"
export TF_VAR_user_secret="your-secret-for-target-vm"
```