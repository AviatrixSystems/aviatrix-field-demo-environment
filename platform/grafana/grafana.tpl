#! /bin/bash
# Set logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# Update packages
sudo DEBIAN_FRONTEND=noninteractive apt-get clean
sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install docker.io -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install docker-compose -y
sudo systemctl start docker
sudo systemctl enable docker

sudo cp -r /tmp/grafana /etc
sudo cp /tmp/grafana.crt /etc/grafana/nginx/grafana.crt
sudo cp /tmp/grafana.key /etc/grafana/nginx/grafana.key
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
