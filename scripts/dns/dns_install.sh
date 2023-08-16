#!/bin/bash

homeDir=/home/dns
goVersion=go1.21.0.linux-arm64

apt update -y
apt upgrade -y
apt install -y certbot

curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
curl -sSLO https://go.dev/dl/$goVersion.tar.gz
sudo tar -C /usr/local -xzf $goVersion.tar.gz
export GOPATH=$homeDir/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
go install github.com/bakito/adguardhome-sync@latest
echo "export GOPATH=$homeDir/go" >> $homeDir/.bashrc
echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> $homeDir/.bashrc

cat <<EOF >"$homeDir/adguardhome-sync.yaml"
api:
  port: 8081
EOF