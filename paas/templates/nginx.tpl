#! /bin/bash
sudo hostnamectl set-hostname ${name}
# Set logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# Add workload user
sudo grep -r PasswordAuthentication /etc/ssh -l | xargs -n 1 sudo sed -i 's/#\s*PasswordAuthentication\s.*$/PasswordAuthentication yes/; s/^PasswordAuthentication\s*no$/PasswordAuthentication yes/'
sudo adduser workload
sudo echo "workload:${pwd}" | sudo /usr/sbin/chpasswd
sudo sed -i'' -e 's+\%sudo.*+\%sudo  ALL=(ALL) NOPASSWD: ALL+g' /etc/sudoers
sudo usermod -aG sudo workload
sudo service sshd restart
# Update packages
sudo DEBIAN_FRONTEND=noninteractive apt-get clean
sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install nginx -y

echo "server {
    listen 81;
    server_name paas.aviatrixtest.com;
    ssl_protocols TLSv1.2;
    ssl_prefer_server_ciphers on;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    access_log off;
    error_log  off;
    location / {
        proxy_pass http://${marketing}:443;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_cookie_path / /;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$http_connection;
        client_max_body_size 1g;
        keepalive_timeout 120;
        access_log off;
    }
}
    error_page    500 502 503 504  /50x.html;
server {
    listen 82;
    server_name paas.aviatrixtest.com;
    ssl_protocols TLSv1.2;
    ssl_prefer_server_ciphers on;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    access_log off;
    error_log  off;
    location / {
        proxy_pass http://${engineering}:443;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_cookie_path / /;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$http_connection;
        client_max_body_size 1g;
        keepalive_timeout 120;
        access_log off;
    }
    error_page    500 502 503 504  /50x.html;
}
server {
    listen 83;
    server_name paas.aviatrixtest.com;
    ssl_protocols TLSv1.2;
    ssl_prefer_server_ciphers on;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    access_log off;
    error_log  off;
    location / {
        proxy_pass http://${accounting}:443;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_cookie_path / /;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$http_connection;
        client_max_body_size 1g;
        keepalive_timeout 120;
        access_log off;
    }
    error_page    500 502 503 504  /50x.html;
}
server {
    listen 84;
    server_name paas.aviatrixtest.com;
    ssl_protocols TLSv1.2;
    ssl_prefer_server_ciphers on;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    access_log off;
    error_log  off;
    location / {
        proxy_pass http://${operations}:443;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_cookie_path / /;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$http_connection;
        client_max_body_size 1g;
        keepalive_timeout 120;
        access_log off;
    }
    error_page    500 502 503 504  /50x.html;
}
server {
    listen 85;
    server_name paas.aviatrixtest.com;
    ssl_protocols TLSv1.2;
    ssl_prefer_server_ciphers on;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    access_log off;
    error_log  off;
    location / {
        proxy_pass http://${enterprise-data}:443;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_cookie_path / /;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$http_connection;
        client_max_body_size 1g;
        keepalive_timeout 120;
        access_log off;
    }
    error_page    500 502 503 504  /50x.html;
}" > /etc/nginx/conf.d/default.conf

sudo service nginx restart
