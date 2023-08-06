#!/bin/bash

HOME="/root"

# Set logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Set hostname
hostnamectl set-hostname ${name}

sudo DEBIAN_FRONTEND=noninteractive apt-get clean
sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install docker.io -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install apache2-utils -y
sudo systemctl start docker
sudo systemctl enable docker

# Update the domain suffix
sed -i '$d' /etc/netplan/50-cloud-init.yaml
echo "            nameservers:" >> /etc/netplan/50-cloud-init.yaml
echo "               search: [${domain}]" >> /etc/netplan/50-cloud-init.yaml
netplan apply

bcrypt64="$(sudo htpasswd -bnBC 9 "" ${pwd} | tr -d ':\n' | sed 's/$2y/$2a/' | base64 -w 0)"

sudo cat > config.yaml << EOL
ui:
  header: "Aviatrix demo lan dashboard"
  logo: "https://aviatrix.com/wp-content/uploads/2023/03/1-1024x1024.png"
web:
  port: 8443
  tls:
    certificate-file: "/config/server.crt"
    private-key-file: "/config/server.key"
security:
  basic:
    username: "admin"
    password-bcrypt-base64: "$bcrypt64"
endpoints:
  - name: aviatrix
    url: "https://www.aviatrix.com"
    interval: 5s
    group: aviatrix
    conditions:
      - "[STATUS] == 200"
remote:
  instances:
EOL

sudo cat > config-e.yaml << EOL
ui:
  header: "Aviatrix demo egress dashboard"
  logo: "https://aviatrix.com/wp-content/uploads/2023/03/1-1024x1024.png"
web:
  port: 8443
  tls:
    certificate-file: "/config/server.crt"
    private-key-file: "/config/server.key"
security:
  basic:
    username: "admin"
    password-bcrypt-base64: "$bcrypt64"
endpoints:
  - name: aviatrix
    url: "https://www.aviatrix.com"
    interval: 5s
    group: aviatrix
    conditions:
      - "[STATUS] == 200"
remote:
  instances:
EOL

for endpoint in $(echo ${apps}|tr "," "\n");
do 
    sudo cat >> config.yaml << EOL
    - endpoint-prefix: "$endpoint --> "
      url: "http://$endpoint.${domain}/api/v1/endpoints/statuses"
EOL
done

for endpoint in $(echo ${apps}|tr "," "\n");
do 
    sudo cat >> config-e.yaml << EOL
    - endpoint-prefix: "$endpoint --> "
      url: "http://$endpoint.${domain}:82/api/v1/endpoints/statuses"
EOL
done
