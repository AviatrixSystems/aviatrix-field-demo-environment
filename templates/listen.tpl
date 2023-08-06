#! /bin/bash
sudo hostnamectl set-hostname ${name}
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# Add workload user
sudo adduser workload
sudo echo "workload:${password}" | sudo /usr/sbin/chpasswd
sudo sed -i'' -e 's+\%sudo.*+\%sudo  ALL=(ALL) NOPASSWD: ALL+g' /etc/sudoers
sudo usermod -aG sudo workload
sudo service sshd restart
# Set logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# Update packages
sudo apt update -y
sudo apt -y install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update -y
sudo apt-get install sshpass -y
sudo apt-get install cron -y

# SAP mock
echo "server {
    listen 443;
    listen 514;
    listen 5000;
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
