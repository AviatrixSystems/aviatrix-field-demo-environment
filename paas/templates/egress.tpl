#! /bin/bash
sudo hostnamectl set-hostname ${name}
# Set logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# Add workload user
sudo grep -r PasswordAuthentication /etc/ssh -l | xargs -n 1 sudo sed -i 's/#\s*PasswordAuthentication\s.*$/PasswordAuthentication yes/; s/^PasswordAuthentication\s*no$/PasswordAuthentication yes/'
sudo adduser workload
sudo echo "workload:${password}" | sudo /usr/sbin/chpasswd
sudo sed -i'' -e 's+\%sudo.*+\%sudo  ALL=(ALL) NOPASSWD: ALL+g' /etc/sudoers
sudo usermod -aG sudo workload
sudo service sshd restart
# Update packages
export DEBIAN_FRONTEND=noninteractive
sudo apt-get clean
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

sudo cat > config.yaml << EOL
ui:
  header: "${name}"
  logo: "https://aviatrix.com/wp-content/uploads/2023/03/1-1024x1024.png"
  link: "https://www.aviatrix.com"
  title: "${name}"
web:
  port: 8443
endpoints:
EOL

sudo cat >> config.yaml << EOL
%{ for s in https ~}
    - name: ${s}:443
      url: "https://${s}"
      client:
        insecure: false
        ignore-redirect: false
        timeout: 10s
      interval: 10s
      group: "${name}-egress"
      conditions:
      - "[CONNECTED] == true"
%{ endfor ~}
%{ for s in http ~}
    - name: ${s}:80
      url: "http://${s}"
      client:
        insecure: false
        ignore-redirect: false
        timeout: 10s
      interval: 10s
      group: "${name}-egress"
      conditions:
      - "[CONNECTED] == true"
%{ endfor ~}
EOL

sudo docker run -d --restart unless-stopped --name gatus -p 443:8443 --mount type=bind,source=/config.yaml,target=/config/config.yaml twinproduction/gatus:v5.12.1
