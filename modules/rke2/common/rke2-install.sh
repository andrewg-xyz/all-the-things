#!/bin/bash

token=$1
server_ip=$2
node_ip=$3

config_dir=/etc/rancher/rke2

sudo mkdir -p $config_dir
echo "token: $token" | sudo tee $config_dir/config.yaml >/dev/null
if [ $server_ip != $node_ip ]; then
    echo "server: https://${server_ip}:9345" | sudo tee -a $config_dir//config.yaml >/dev/null
fi
sudo INSTALL_RKE2_ARTIFACT_PATH=/tmp/rke2-artifacts/ sh /tmp/rke2-artifacts/install.sh
sudo systemctl enable rke2-server.service
sudo systemctl start rke2-server.service

if [ $server_ip == $node_ip ]; then
    mkdir /home/user/.kube
    sudo cp /etc/rancher/rke2/rke2.yaml /home/user/.kube/config
    sudo chown user:user /home/user/.kube/config
fi
