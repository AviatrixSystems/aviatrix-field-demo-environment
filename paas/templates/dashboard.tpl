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
export DEBIAN_FRONTEND=noninteractive
sudo apt-get clean
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install docker.io -y
sudo apt-get install apache2-utils -y
sudo systemctl start docker
sudo systemctl enable docker

bcrypt64="$(sudo htpasswd -bnBC 9 "" ${pwd} | tr -d ':\n' | sed 's/$2y/$2a/' | base64 -w 0)"

sudo cat > config.yaml << EOL
ui:
  header: "${cloud} ${gatus} dashboard"
  logo: "https://aviatrix.com/wp-content/uploads/2023/03/1-1024x1024.png"
  title: "${cloud}-${gatus}"
web:
  port: 8443
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
%{ for s in instances ~}
    - url: "http://${s}:443/api/v1/endpoints/statuses"
%{ endfor ~}
EOL

sudo docker run -d --restart unless-stopped --name gatus -p 80:8080 -p 443:8443 --mount type=bind,source=/config.yaml,target=/config/config.yaml twinproduction/gatus:v5.12.1
