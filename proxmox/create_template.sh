#!/bin/bash

node=$1
id=$2
delete=${3:-0}

ubuntu_distro=mantic
ssh_key='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5gDqGux/p7JR/I/mBE/LYoJc8RBdSikmyVj7OTqBMW andrewsgreene89@gmail.com'
apt install libguestfs-tools -y

# check if node and id are set
if [[ -z $node || -z $id ]]; then
    echo "Error: node and id must be set."
    exit 1
fi

# Check if the ID already exists
if qm list | grep -q " $id " ; then
    echo "Error: ID $id already exists."
    if [[ $delete -ne 0 ]]; then
        echo "Deleting existing VM $id..."
        qm destroy $id
    else
        echo "Exiting..."
        exit 1
    fi
fi

cd /tmp
wget https://cloud-images.ubuntu.com/$ubuntu_distro/current/$ubuntu_distro-server-cloudimg-amd64.img
virt-customize -a /tmp/$ubuntu_distro-server-cloudimg-amd64.img --install qemu-guest-agent
virt-customize -a /tmp/$ubuntu_distro-server-cloudimg-amd64.img --run-command "echo -n > /etc/machine-id"
virt-customize -a /tmp/$ubuntu_distro-server-cloudimg-amd64.img --run-command "apt-get update -y"
touch /etc/pve/nodes/$node/qemu-server/$id.conf
qm importdisk $id /tmp/$ubuntu_distro-server-cloudimg-amd64.img local-lvm
qm set $id --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-$id-disk-0
qm set $id --ide2 local-lvm:cloudinit
qm set $id --boot c --bootdisk scsi0
qm set $id --serial0 socket --vga serial0
qm set $id --agent enabled=1
qm set $id --name ubuntu-ci-template-$ubuntu_distro
qm set $id --sshkey <(cat <<<"${ssh_key}")
qm template $id
rm -rf /tmp/$ubuntu_distro-server-cloudimg-amd64.img
cd -