# Preparation

## Template for Virtual Machines
The Telmate proxmox provider requires a template VM in proxmox.

On each proxmox server, execute

```sh
./scripts/create_cloudinit_template.sh <node> <id>
```
