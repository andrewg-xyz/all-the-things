#!/bin/bash

usage() {
    echo "Usage: Utility script for installing a RKE2 cluster"
    echo "  -t  [string_val] cluster join token"
    echo "  -s  [string_val] main server ip (Ex. 10.0.0.1)"
    echo "  -a               agent flag"
    exit 1
}

while getopts "t:s:a" o; do
    case "${o}" in
    t) token="${OPTARG}" ;;
    s) server_ip="${OPTARG}" ;;
    a) agent=1 ;;
    *) usage ;;
    esac
done
shift $(($OPTIND - 1))

node_ip=`ip addr show eth0 | awk '/inet / {print $2}' | cut -d '/' -f1`

config_dir=/etc/rancher/rke2
config_file=$config_dir/config.yaml

mkdir -p $config_dir

cat <<EOF >"$config_file"
disable:
  - rke2-ingress-nginx
  - rke2-metrics-server
token: "$token"
EOF

if [ $server_ip != $node_ip ]; then
    echo "server: https://${server_ip}:9345" | sudo tee -a $config_dir/config.yaml >/dev/null
fi
sudo INSTALL_RKE2_ARTIFACT_PATH=/root/rke2-artifacts/ sh /root/rke2-artifacts/install.sh
if [ -z $agent ]; then
    sudo systemctl enable rke2-server.service
    sudo systemctl start rke2-server.service
else
    sudo systemctl enable rke2-agent.service
    sudo systemctl start rke2-agent.service
fi

if [ $server_ip == $node_ip ]; then
    mkdir /home/user/.kube
    sudo cp /etc/rancher/rke2/rke2.yaml /home/user/.kube/config
    sudo chown user:user /home/user/.kube/config
fi
