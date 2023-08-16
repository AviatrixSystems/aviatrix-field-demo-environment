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
sudo DEBIAN_FRONTEND=noninteractive apt-get clean
sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install docker.io -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install nginx -y
ksudo systemctl start docker
sudo systemctl enable docker

# Update the domain suffix
sed -i '$d' /etc/netplan/50-cloud-init.yaml
echo "            nameservers:" >> /etc/netplan/50-cloud-init.yaml
echo "               search: [${domain}]" >> /etc/netplan/50-cloud-init.yaml
netplan apply

sudo cat > config.yaml << EOL
ui:
  header: "${name} lan dashboard"
endpoints:
EOL

sudo cat > config-e.yaml << EOL
ui:
  header: "${name} egress dashboard"
endpoints:
EOL

for endpoint in $(echo ${external}|tr "," "\n");
do 
    sudo cat >> config-e.yaml << EOL
    - name: $endpoint
      url: "https://$endpoint"
      interval: ${interval}s
      group: "${name} [egress]"
      conditions:
      - "[STATUS] == 200"
EOL
done

for endpoint in $(echo ${apps}|tr "," "\n");
do 
    sudo cat >> config.yaml << EOL
    - name: $endpoint-443
      url: "tcp://$endpoint:443"
      interval: ${interval}s
      group: "${name} [apps]"
      conditions:
      - "[CONNECTED] == true"
    - name: $endpoint-8443
      url: "tcp://$endpoint:8443"
      interval: ${interval}s
      group: "${name} [shared]"
      conditions:
      - "[CONNECTED] == true"
    - name: $endpoint-1521
      url: "tcp://$endpoint:1521"
      interval: ${interval}s
      group: "${name} [shared]"
      conditions:
      - "[CONNECTED] == true"
    - name: "$endpoint-1433"
      url: "tcp://$endpoint:1433"
      interval: ${interval}s
      group: "${name} [data]"
      conditions:
      - "[CONNECTED] == true"
    - name: "$endpoint-3306"
      url: "tcp://$endpoint:3306"
      interval: ${interval}s
      group: "${name} [data]"
      conditions:
      - "[CONNECTED] == true"
    - name: "$endpoint-30005"
      url: "tcp://$endpoint:30005"
      interval: ${interval}s
      group: "${name} [data]"
      conditions:
      - "[CONNECTED] == true"
    - name: "$endpoint-50100"
      url: "tcp://$endpoint:50100"
      interval: ${interval}s
      group: "${name} [data]"
      conditions:
      - "[CONNECTED] == true"
EOL
done

sudo sed -i 's/80/81/g' /etc/nginx/sites-available/default

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

sudo service nginx restart

sleep 300
# TODO: verion pin - docker pull twinproduction/gatus:v5.4.0
sudo docker run -d --restart unless-stopped --name gatus -p 80:8080 --mount type=bind,source="$(pwd)"/config.yaml,target=/config/config.yaml twinproduction/gatus
if [ ${external} != [] ]; then
  sudo docker run -d --restart unless-stopped --name gatus-e -p 82:8080 --mount type=bind,source="$(pwd)"/config-e.yaml,target=/config/config.yaml twinproduction/gatus
fi

# Create some malicious traffic
curl http://testmynids.org/uid/index.html
