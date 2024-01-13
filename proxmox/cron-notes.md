# Edit crontab
`crontab -e`
# view cron logs
`grep CRON /var/log/syslog`
# Update Proxmox Cloud Init Templates
0 0 * * 0 /root/wrapper.sh `hostname`
