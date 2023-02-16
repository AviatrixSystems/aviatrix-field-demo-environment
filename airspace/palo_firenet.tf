# Palo bootstrap s3 bucket and files
resource "aws_s3_bucket" "palo" {
  bucket = var.palo_bucket_name
}

resource "aws_s3_bucket_public_access_block" "palo" {
  bucket = aws_s3_bucket.palo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "palo" {
  bucket = aws_s3_bucket.palo.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "palo" {
  bucket = aws_s3_bucket.palo.bucket

  rule {
    bucket_key_enabled = false

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "bootstrap" {
  bucket = aws_s3_bucket.palo.id
  key    = "config/bootstrap.xml"
  source = "${var.palo_bootstrap_path}/bootstrap.xml"
  etag   = filemd5("${var.palo_bootstrap_path}/bootstrap.xml")
}

resource "aws_s3_object" "init_cfg" {
  bucket = aws_s3_bucket.palo.id
  key    = "config/init-cfg.txt"
  source = "${var.palo_bootstrap_path}/init-cfg.txt"
  etag   = filemd5("${var.palo_bootstrap_path}/init-cfg.txt")
}

resource "aws_s3_object" "content" {
  bucket = aws_s3_bucket.palo.id
  acl    = "private"
  key    = "content/"
  source = "/dev/null"
}

resource "aws_s3_object" "license" {
  bucket = aws_s3_bucket.palo.id
  acl    = "private"
  key    = "license/"
  source = "/dev/null"
}

resource "aws_s3_object" "software" {
  bucket = aws_s3_bucket.palo.id
  acl    = "private"
  key    = "software/"
  source = "/dev/null"
}

# Palo iam policy and bootstrap role
data "aws_iam_policy_document" "palo" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::*"]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "palo" {
  name   = "aviatrix-bootstrap-VM-S3-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.palo.json
}

resource "aws_iam_role" "palo" {
  name               = "aviatrix-bootstrap-VM-S3-role"
  description        = "palo alto vm series bootstrap"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "palo" {
  role       = aws_iam_role.palo.id
  policy_arn = aws_iam_policy.palo.arn
}

resource "aws_iam_instance_profile" "palo" {
  name = "aviatrix-bootstrap-VM-S3-role"
  role = aws_iam_role.palo.name
}

# Enable palo policies
resource "aviatrix_transit_firenet_policy" "palo_peering" {
  for_each                     = { for k, v in local.transit_firenet : k => v if k != "aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}" }
  transit_firenet_gateway_name = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  inspected_resource_name      = "PEERING:${module.multicloud_transit.transit[each.key].transit_gateway.gw_name}"
  depends_on = [
    module.multicloud_transit
  ]
}

resource "aviatrix_transit_firenet_policy" "palo_spokes" {
  for_each                     = { for spoke in local.regional_spokes : "${spoke.avx_account}-${spoke.spoke}" => spoke if "${spoke.avx_account}" == var.aws_accounting_account_name }
  transit_firenet_gateway_name = module.multicloud_transit.transit["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].transit_gateway.gw_name
  inspected_resource_name      = "SPOKE:${module.spokes["${each.value.avx_account}-${each.value.spoke}"].spoke_gateway.gw_name}"
  depends_on = [
    module.multicloud_transit
  ]
}

# Enable palo vendor integration
# Need to wait 15 minutes for initialization
# data "aviatrix_firenet_vendor_integration" "palo" {
#   vpc_id        = module.multicloud_transit.firenet["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].aviatrix_firewall_instance[0].vpc_id
#   instance_id   = module.multicloud_transit.firenet["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].aviatrix_firewall_instance[0].instance_id
#   vendor_type   = "Palo Alto Networks VM-Series"
#   public_ip     = module.multicloud_transit.firenet["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].aviatrix_firewall_instance[0].public_ip
#   username      = var.palo_admin_username
#   password      = var.palo_admin_password
#   firewall_name = module.multicloud_transit.firenet["aws_${replace(lower(var.transit_aws_palo_firenet_region), "/[ -]/", "_")}"].aviatrix_firewall_instance[0].firewall_name
#   save          = true
# }
