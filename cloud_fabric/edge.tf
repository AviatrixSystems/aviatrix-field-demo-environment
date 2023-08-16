data "http" "myip" {
  url = "http://ifconfig.me"
}

module "edge" {
  source                         = "github.com/jb-smoker/avxedgedemo?ref=v3.1.1"
  admin_cidr                     = ["${chomp(data.http.myip.response_body)}/32"]
  region                         = "us-west2"
  pov_prefix                     = local.edge_prefix
  host_vm_size                   = "n2-standard-2"
  test_vm_size                   = "n2-standard-2"
  test_vm_internet_ingress_ports = ["443", "8443"]
  host_vm_cidr                   = "10.40.251.16/28"
  host_vm_asn                    = 64900
  host_vm_count                  = 1
  edge_vm_asn                    = 64581
  edge_lan_cidr                  = "10.40.251.0/29"
  edge_image_filename            = "${path.module}/avx-edge-kvm-7.1-2023-04-24.qcow2"
  test_vm_metadata_startup_script = templatefile("${var.workload_template_path}/edge.tpl", {
    name   = local.edge_prefix
    domain = "demo.aviatrixtest.com"
    apps   = join(",", local.apps)
    pwd    = var.workload_instance_password
  })
  external_cidrs = []
  vm_ssh_key     = file("~/.ssh/id_rsa.pub")
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

resource "null_resource" "edge" {
  connection {
    type        = "ssh"
    user        = "johnsmoker"
    private_key = file("~/.ssh/id_rsa")
    host        = module.edge.test_vm_pip.address
  }

  provisioner "file" {
    content     = var.dashboard_public_cert
    destination = "/tmp/cert.crt"
  }

  provisioner "file" {
    content     = var.dashboard_private_key
    destination = "/tmp/private.key"
  }

  provisioner "remote-exec" {
    inline = [
      "cd \"/\"",
      "sleep 300",
      "sudo cp /tmp/cert.crt /server.crt",
      "sudo cp /tmp/private.key /server.key",
      "sudo docker run -d --restart unless-stopped --name gatus -p 80:8080 -p 443:8443 --mount type=bind,source=/config.yaml,target=/config/config.yaml --mount type=bind,source=/server.crt,target=/config/server.crt --mount type=bind,source=/server.key,target=/config/server.key twinproduction/gatus",
      "sudo docker run -d --restart unless-stopped --name gatus-e -p 82:8080 -p 8443:8443 --mount type=bind,source=/config-e.yaml,target=/config/config.yaml --mount type=bind,source=/server.crt,target=/config/server.crt --mount type=bind,source=/server.key,target=/config/server.key twinproduction/gatus",
    ]
  }
  depends_on = [
    module.edge,
  ]
}

resource "aws_route53_record" "dashboard" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "dashboard.${data.aws_route53_zone.demo.name}"
  type    = "A"
  ttl     = "1"
  records = [module.edge.test_vm_pip.address]
}
