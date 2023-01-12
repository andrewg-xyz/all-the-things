# Infrastructure provisioning

Leveraging [Telmate proxmox provider](https://github.com/Telmate/terraform-provider-proxmox) to use terraform to deploy VMs into the proxmox cluster.

## deploying

!!! Work in Progress !!!

1. See [../modules/base_node] for the common module reused across these deployments
   1. I learned this is really not a good use for modules. I end up duplicating a bulk of configs. Improvement would be to pass in the provider to the module - then I may be able to leverage `count, depends_on, for_each` type things.
2. See [../staging/dev] to deploy the dev cluster. I use a local `.env` for sensitive values.  
    ```
    cd ../staging/dev
    source .env
    terraform init
    terraform plan
    terraform apply
    ```
   `.env` example
    ```
    export TF_VAR_pm_api_url="https://wherever-yo-proxmox-lives:8006/api2/json"
    export TF_VAR_pm_user="your-user@pam"
    export TF_VAR_pm_password="your-secret"
    export TF_VAR_vm_gw="123.123.123.123"
    export TF_VAR_vm_ip="123.123.123.1"
    export TF_VAR_user_secret="your-secret-for-target-vm"
    ```