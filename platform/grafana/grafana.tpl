#! /bin/bash
# Set logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# Update packages
export DEBIAN_FRONTEND=noninteractive
sudo apt-get clean
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install docker.io -y
sudo apt-get install docker-compose -y
sudo apt-get install make -y
sudo apt-get install docker-compose-v2 -y
sudo systemctl start docker
sudo systemctl enable docker

sudo cp -r /tmp/grafana /etc
sudo cp -r /tmp/copilot_proxy /etc
sudo cp /tmp/grafana.crt /etc/grafana/nginx/grafana.crt
sudo cp /tmp/grafana.key /etc/grafana/nginx/grafana.key
sudo cp /tmp/grafana.crt /etc/copilot_proxy/nginx/nginx.crt
sudo cp /tmp/grafana.key /etc/copilot_proxy/nginx/nginx.key
sudo sed -i "s/pendo_key_1/${pendo_key_1}/g" /etc/copilot_proxy/nginx/nginx.conf
sudo sed -i "s/pendo_key_2/${pendo_key_2}/g" /etc/copilot_proxy/nginx/nginx.conf
sudo sed -i "s/copilot_fqdn/${copilot_fqdn}/g" /etc/copilot_proxy/sidecar/app.py
sudo sed -i "s/copilot_pwd/${copilot_pwd}/g" /etc/copilot_proxy/sidecar/app.py
sudo sed -i "s/copilot_ro_user/${copilot_ro_user}/g" /etc/copilot_proxy/sidecar/app.py
sudo sed -i "s/copilot_fqdn/${copilot_fqdn}/g" /etc/grafana/prometheus/prometheus.yml
sudo sed -i "s/copilot_api_key/${copilot_api_key}/g" /etc/grafana/prometheus/prometheus.yml
sudo sed -i "s/grafana_admin_password/${grafana_admin_password}/g" /etc/grafana/compose.yaml
sudo sed -i "s/grafana_client_id/${grafana_client_id}/g" /etc/grafana/compose.yaml
sudo sed -i "s/grafana_client_secret/${grafana_client_secret}/g" /etc/grafana/compose.yaml
sudo sed -i "s,grafana_auth_url,${grafana_auth_url},g" /etc/grafana/compose.yaml
sudo sed -i "s,grafana_token_url,${grafana_token_url},g" /etc/grafana/compose.yaml
sudo sed -i "s/azure_tenant_id/${azure_tenant_id}/g" /etc/grafana/compose.yaml
sudo sed -i "s/grafana_fqdn/${grafana_fqdn}/g" /etc/grafana/compose.yaml

cd /etc/grafana
sudo docker-compose up -d

export BACKEND_USERNAME=${copilot_ro_user}
export BACKEND_PASSWORD=${copilot_pwd}
export BACKEND_URL=${copilot_fqdn}

cd /etc/copilot_proxy
make build
sudo docker compose up -d

sudo docker run -d \
    -e CPLT_API_KEY=${copilot_api_key} \
    -e CPLT_DOMAIN=${copilot_fqdn} \
    -e NRIA_LICENSE_KEY=${new_relic_api_key} \
    aviatrix/avx-new-relic:1.0.0

cat <<SCR >>/root/cron.sh
#!/bin/bash
cd /etc/copilot_proxy
docker compose restart
SCR

chmod +x /root/cron.sh
crontab<<CRN
0 4 * * SAT /root/cron.sh
CRN

sudo systemctl restart cron
