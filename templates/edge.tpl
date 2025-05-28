#!/bin/bash
HOME="/root"
# Set logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Set hostname
hostnamectl set-hostname ${name}
export DEBIAN_FRONTEND=noninteractive
sudo apt-get clean
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install docker.io -y
sudo apt-get install apache2-utils -y
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
  link: "https://www.aviatrix.com"
  title: "Demo lan"
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
    interval: 600s
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
  link: "https://www.aviatrix.com"
  title: "Demo egress"
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
    interval: 600s
    group: aviatrix
    conditions:
      - "[STATUS] == 200"
remote:
  instances:
EOL

sudo cat > config-k.yaml << EOL
ui:
  header: "Aviatrix demo k8s dashboard"
  logo: "https://aviatrix.com/wp-content/uploads/2023/03/1-1024x1024.png"
  link: "https://www.aviatrix.com"
  title: "Demo k8s"
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
    interval: 600s
    group: aviatrix
    conditions:
      - "[STATUS] == 200"
remote:
  instances:
EOL

sudo cat >> config.yaml << EOL
%{ for s in apps ~}
    - endpoint-prefix: "${s} --> "
      url: "http://${s}.${domain}/api/v1/endpoints/statuses"
%{ endfor ~}
EOL
sudo cat >> config-e.yaml << EOL
%{ for s in apps ~}
    - endpoint-prefix: "${s} --> "
      url: "http://${s}.${domain}:82/api/v1/endpoints/statuses"
%{ endfor ~}
EOL
sudo cat >> config-k.yaml << EOL
%{ for s in k8s ~}
    - endpoint-prefix: "${s} --> "
      url: "http://${s}.${domain}:443/api/v1/endpoints/statuses"
%{ endfor ~}
EOL


echo "${cert}" | sudo tee -a /tmp/cert.crt
echo "${key}" | sudo tee -a /tmp/private.key

cd /
sudo cp /tmp/cert.crt /server.crt
sudo cp /tmp/private.key /server.key
sudo docker run -d --restart unless-stopped --name gatus -p 443:8443 --mount type=bind,source=/config.yaml,target=/config/config.yaml --mount type=bind,source=/server.crt,target=/config/server.crt --mount type=bind,source=/server.key,target=/config/server.key twinproduction/gatus:v5.12.1
sudo docker run -d --restart unless-stopped --name gatus-e -p 8443:8443 --mount type=bind,source=/config-e.yaml,target=/config/config.yaml --mount type=bind,source=/server.crt,target=/config/server.crt --mount type=bind,source=/server.key,target=/config/server.key twinproduction/gatus:v5.12.1
sudo docker run -d --restart unless-stopped --name gatus-k -p 9443:8443 --mount type=bind,source=/config-k.yaml,target=/config/config.yaml --mount type=bind,source=/server.crt,target=/config/server.crt --mount type=bind,source=/server.key,target=/config/server.key twinproduction/gatus:v5.12.1
