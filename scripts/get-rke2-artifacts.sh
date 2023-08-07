#!/bin/bash

#following https://docs.rke2.io/install/airgap#install-rke2
rke2_version=v1.27.4+rke2r1
if [ -z ./rke2-artifacts ]; then
    mkdir ./rke2-artifacts
fi
cd ./rke2-artifacts/
curl -OLs https://github.com/rancher/rke2/releases/download/$rke2_version/rke2-images.linux-amd64.tar.zst
curl -OLs https://github.com/rancher/rke2/releases/download/$rke2_version/rke2.linux-amd64.tar.gz
curl -OLs https://github.com/rancher/rke2/releases/download/$rke2_version/sha256sum-amd64.txt
curl -sfL https://get.rke2.io --output install.sh
cd -