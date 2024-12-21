#! /bin/bash
sudo hostnamectl set-hostname ${name}
sudo grep -r PasswordAuthentication /etc/ssh -l | xargs -n 1 sudo sed -i 's/#\s*PasswordAuthentication\s.*$/PasswordAuthentication yes/; s/^PasswordAuthentication\s*no$/PasswordAuthentication yes/'
# Add workload user
sudo adduser workload
sudo echo "workload:${password}" | sudo /usr/sbin/chpasswd
sudo sed -i'' -e 's+\%sudo.*+\%sudo  ALL=(ALL) NOPASSWD: ALL+g' /etc/sudoers
sudo usermod -aG sudo workload
sudo service sshd restart
# Set logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# Update packages
sudo DEBIAN_FRONTEND=noninteractive apt-get clean
sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install nginx -y

# Update the domain suffix
sed -i '$d' /etc/netplan/50-cloud-init.yaml
echo "            nameservers:" >> /etc/netplan/50-cloud-init.yaml
echo "               search: [${domain}]" >> /etc/netplan/50-cloud-init.yaml
netplan apply

sudo sed -i 's/80/81/g' /etc/nginx/sites-available/default

echo "server {
    listen 80;
    listen 443;

    error_page    500 502 503 504  /50x.html;

    location      / {
        root      html;
    }

}" > /etc/nginx/conf.d/default.conf

sudo service nginx restart

# Traffic gen
cat <<SCR >>/root/cron.sh
#!/bin/bash
HOUR=\$(date +%H)
if test \$HOUR -lt 11; then
    for i in {1..10}
    do
        curl -I https://${endpoint} --insecure --connect-timeout 2; echo "\$(date): curl ${endpoint}" | sudo tee -a /var/log/traffic-gen.log
        sleep 2
    done
fi
SCR

chmod +x /root/cron.sh
crontab<<CRN
*/5 * * * * /root/cron.sh
1 0 * * * rm -f /var/log/traffic-gen.log
CRN

sudo systemctl restart cron
