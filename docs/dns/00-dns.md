# DNS

Internal DNS through AdGuard running on two Raspberry Pi 4B's

## Configuration

1. Raspberry Pi Images
   1. Raspberry Pi OS Lite (64-bit)
   2. enable SSH, using key
   3. set hostname dns01/dns02
   4. set username/password (dns/***)
2. Network
   ```
   ssh dns@x.x.x.x (ping dns01|dns02.local to find dhcp IP)
   sudo nano /etc/dhcpcd.conf
   # Edit interface eth0
   # Example:
   # interface eth0
   # static ip_address=x.x.x.x/24
   # static routers=x.x.x.x
   # static domain_name_servers=8.8.8.8 8.8.4.4
   sudo reboot
   ```
3. Install Adguardhome, adguardhome-sync, and certbot
   ```
   scp scripts/dns/* dns@x.x.x.x:
   ssh dns@x.x.x.x
   chmod +x dns_install.sh
   sudo ./dns_install.sh
   sudo reboot
   ```
4. Generate Certs (or copy from first node)
   ```
   certbot certonly --manual --preferred-challenges dns --config-dir=./certs/config --work-dir=./certs/work --logs-dir=./certs/logs
   # Follow prompts 
   ```
5. Configure Adguardhome
   1. Open browser to http://x.x.x.x:3000
   2. Follow configuration tutorial
   3. Add DNS servers
      1.DNS server listen interface eth0 - x.x.x.x
   4. Add Certificates _settings>encryption settings configure+add certs_


## Adguard Sync

on one of the servers, 
1. update values in dns_sync.sh
   1. this node, must have the other node's DNS nameserver
2. ./dns_sync.sh &