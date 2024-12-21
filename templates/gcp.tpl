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

# SAP mock
echo "server {
    listen 443;
    listen 514;
    listen 1521;
    listen 8443;
    listen 30000-30041; 
    listen 50010;
    listen 50100;
    listen 1433;
    listen 3306;

    error_page    500 502 503 504  /50x.html;

    location      / {
        root      html;
    }

}" > /etc/nginx/conf.d/default.conf

service nginx restart
