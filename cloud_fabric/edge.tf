data "http" "myip" {
  url = "http://icanhazip.com"
}

module "edge" {
  source                         = "terraform-aviatrix-modules/gcp-edge-demo/aviatrix"
  version                        = "3.2.2"
  admin_cidr                     = ["${chomp(data.http.myip.response_body)}/32"]
  region                         = "us-west2"
  pov_prefix                     = local.edge_prefix
  host_vm_size                   = "n2-standard-2"
  test_vm_size                   = "n2-standard-2"
  test_vm_internet_ingress_ports = ["443", "8443", "9443"]
  host_vm_cidr                   = "10.40.251.16/28"
  host_vm_asn                    = 64900
  host_vm_count                  = 1
  edge_vm_asn                    = 64581
  edge_lan_cidr                  = "10.40.251.0/29"
  edge_image_location            = "avxlabs-pod1-edge-bucket/avx-gateway-avx-g3-202409102334.qcow2"
  gcp_ubuntu_image               = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250219"
  test_vm_metadata_startup_script = templatefile("${var.workload_template_path}/edge.tpl", {
    name   = local.edge_prefix
    domain = "demo.aviatrixtest.com"
    apps   = local.apps
    k8s = [
      "accounting-frontend-web-dev",
      "accounting-frontend-web-prod",
      "marketing-frontend-web-dev",
      "marketing-frontend-web-prod",
      "accounting-backend-api-dev",
      "accounting-backend-api-prod",
      "marketing-backend-api-dev",
      "marketing-backend-api-prod"
    ]
    pwd  = var.workload_instance_password
    cert = var.dashboard_public_cert
    key  = var.dashboard_private_key
  })
  external_cidrs = [
    "10.40.1.0/28", "10.40.1.16/28", "10.40.1.32/28", "10.40.1.48/28", "10.40.1.64/28", "10.40.1.80/28", "10.40.1.96/28", "10.40.1.112/28", "10.40.1.128/28", "10.40.1.144/28", "10.40.1.160/28", "10.40.1.176/28", "10.40.1.192/28", "10.40.1.208/28", "10.40.1.224/28", "10.40.1.240/28",
    "10.40.2.0/28", "10.40.2.16/28", "10.40.2.32/28", "10.40.2.48/28", "10.40.2.64/28", "10.40.2.80/28", "10.40.2.96/28", "10.40.2.112/28", "10.40.2.128/28", "10.40.2.144/28", "10.40.2.160/28", "10.40.2.176/28", "10.40.2.192/28", "10.40.2.208/28", "10.40.2.224/28", "10.40.2.240/28",
    "10.40.3.0/28", "10.40.3.16/28", "10.40.3.32/28", "10.40.3.48/28", "10.40.3.64/28", "10.40.3.80/28", "10.40.3.96/28", "10.40.3.112/28", "10.40.3.128/28", "10.40.3.144/28", "10.40.3.160/28", "10.40.3.176/28", "10.40.3.192/28", "10.40.3.208/28", "10.40.3.224/28", "10.40.3.240/28",
    "10.40.4.0/28", "10.40.4.16/28", "10.40.4.32/28", "10.40.4.48/28", "10.40.4.64/28", "10.40.4.80/28", "10.40.4.96/28", "10.40.4.112/28", "10.40.4.128/28", "10.40.4.144/28", "10.40.4.160/28", "10.40.4.176/28", "10.40.4.192/28", "10.40.4.208/28", "10.40.4.224/28", "10.40.4.240/28",
    "10.40.5.0/28", "10.40.5.16/28", "10.40.5.32/28", "10.40.5.48/28", "10.40.5.64/28", "10.40.5.80/28", "10.40.5.96/28", "10.40.5.112/28", "10.40.5.128/28", "10.40.5.144/28", "10.40.5.160/28", "10.40.5.176/28", "10.40.5.192/28", "10.40.5.208/28", "10.40.5.224/28", "10.40.5.240/28",
    "10.40.6.0/28", "10.40.6.16/28", "10.40.6.32/28", "10.40.6.48/28", "10.40.6.64/28", "10.40.6.80/28", "10.40.6.96/28", "10.40.6.112/28", "10.40.6.128/28", "10.40.6.144/28", "10.40.6.160/28", "10.40.6.176/28", "10.40.6.192/28", "10.40.6.208/28", "10.40.6.224/28", "10.40.6.240/28",
    "10.40.7.0/28", "10.40.7.16/28", "10.40.7.32/28", "10.40.7.48/28", "10.40.7.64/28", "10.40.7.80/28", "10.40.7.96/28", "10.40.7.112/28", "10.40.7.128/28", "10.40.7.144/28", "10.40.7.160/28", "10.40.7.176/28", "10.40.7.192/28", "10.40.7.208/28", "10.40.7.224/28", "10.40.7.240/28",
    "10.40.8.0/28", "10.40.8.16/28", "10.40.8.32/28", "10.40.8.48/28", "10.40.8.64/28", "10.40.8.80/28", "10.40.8.96/28", "10.40.8.112/28", "10.40.8.128/28", "10.40.8.144/28", "10.40.8.160/28", "10.40.8.176/28", "10.40.8.192/28", "10.40.8.208/28", "10.40.8.224/28", "10.40.8.240/28",
    "10.40.9.0/28", "10.40.9.16/28", "10.40.9.32/28", "10.40.9.48/28", "10.40.9.64/28", "10.40.9.80/28", "10.40.9.96/28", "10.40.9.112/28", "10.40.9.128/28", "10.40.9.144/28", "10.40.9.160/28", "10.40.9.176/28", "10.40.9.192/28", "10.40.9.208/28", "10.40.9.224/28", "10.40.9.240/28",
  ]
  vm_ssh_key = var.public_key
  transit_gateways = [
    module.backbone.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.backbone.transit["aws_${replace(lower(var.transit_aws_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.backbone.transit["azure_${replace(lower(var.transit_azure_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.backbone.transit["oci_${replace(lower(var.transit_oci_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.backbone.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
  ]
  providers = {
    google = google.operations
  }
}

resource "aws_route53_record" "dashboard" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "dashboard.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [module.edge.test_vm_pip.address]
}

module "edge_mp" {
  source                         = "terraform-aviatrix-modules/gcp-edge-demo/aviatrix"
  version                        = "3.2.2"
  admin_cidr                     = ["${chomp(data.http.myip.response_body)}/32"]
  region                         = "us-west4"
  pov_prefix                     = local.edge_prefix_megaport
  host_vm_size                   = "n2-standard-2"
  test_vm_size                   = "f1-micro"
  test_vm_internet_ingress_ports = []
  host_vm_cidr                   = "10.50.251.16/28"
  host_vm_asn                    = 64901
  host_vm_count                  = 1
  edge_vm_asn                    = 64582
  edge_lan_cidr                  = "10.50.251.0/29"
  edge_image_location            = "avxlabs-pod1-edge-bucket/avx-gateway-avx-g3-202504251525.qcow2"
  gcp_ubuntu_image               = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20250219"
  external_cidrs                 = []
  vm_ssh_key                     = var.public_key
  transit_gateways = [
    module.backbone.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.backbone.transit["aws_${replace(lower(var.transit_aws_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.backbone.transit["azure_${replace(lower(var.transit_azure_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.backbone.transit["oci_${replace(lower(var.transit_oci_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
    module.backbone.transit["gcp_${replace(lower(var.transit_gcp_region), "/[ -]/", "_")}"].transit_gateway.gw_name,
  ]
  providers = {
    google = google.operations
  }
}

