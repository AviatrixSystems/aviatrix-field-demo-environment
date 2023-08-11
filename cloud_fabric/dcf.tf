# Distributed firewall
resource "aviatrix_distributed_firewalling_config" "demo" {
  enable_distributed_firewalling = true
}

resource "aviatrix_web_group" "allow_internet_https" {
  name = "allowed-internet-https"
  selector {
    match_expressions {
      snifilter = "*.alibabacloud.com"
    }
    match_expressions {
      snifilter = "azure.microsoft.com"
    }
    match_expressions {
      snifilter = "aws.amazon.com"
    }
    match_expressions {
      snifilter = "*.amazonaws.com"
    }
    match_expressions {
      snifilter = "*.aviatrix.com"
    }
    match_expressions {
      snifilter = "aviatrix.com"
    }
    match_expressions {
      snifilter = "cloud.google.com"
    }
    match_expressions {
      snifilter = "*.docker.com"
    }
    match_expressions {
      snifilter = "*.docker.io"
    }
    match_expressions {
      snifilter = "www.oracle.com"
    }
  }
}

resource "aviatrix_web_group" "allow_internet_http" {
  name = "allowed-internet-http"
  selector {
    match_expressions {
      snifilter = "*.ubuntu.com"
    }
  }
}

resource "aviatrix_web_group" "allow_nids_detection" {
  name = "allowed-nids-detection"
  selector {
    match_expressions {
      snifilter = "testmynids.org"
    }
  }
}

resource "aviatrix_smart_group" "rfc1918" {
  name = "rfc1918"
  selector {
    match_expressions {
      cidr = "10.0.0.0/8"
    }
    match_expressions {
      cidr = "172.16.0.0/12"
    }
    match_expressions {
      cidr = "192.168.0.0/16"
    }
  }
}

resource "aviatrix_smart_group" "dev" {
  name = "dev"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        Environment = "dev"
      }
    }
    match_expressions {
      type = "vm"
      tags = {
        environment = "dev"
      }
    }
  }
}

resource "aviatrix_smart_group" "qa" {
  name = "qa"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        Environment = "qa"
      }
    }
    match_expressions {
      type = "vm"
      tags = {
        environment = "qa"
      }
    }
  }
}

resource "aviatrix_smart_group" "prod" {
  name = "prod"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        Environment = "prod"
      }
    }
    match_expressions {
      type = "vm"
      tags = {
        environment = "prod"
      }
    }
  }
}

resource "aviatrix_smart_group" "shared" {
  name = "shared"
  selector {
    match_expressions {
      cidr = "10.3.2.0/24"
    }
  }
}

resource "aviatrix_smart_group" "edge" {
  name = "edge"
  selector {
    match_expressions {
      cidr = "10.40.251.0/24"
    }
  }
}

resource "aviatrix_distributed_firewalling_policy_list" "egress_enforce" {
  policies {
    name     = "allow-internet-http"
    action   = "INTRUSION_DETECTION_PERMIT"
    priority = 0
    protocol = "TCP"
    logging  = true
    watch    = false
    port_ranges {
      lo = 80
    }
    src_smart_groups = [
      aviatrix_smart_group.rfc1918.uuid
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000001" # Public Internet
    ]
    web_groups = [
      aviatrix_web_group.allow_internet_http.uuid,
      aviatrix_web_group.allow_nids_detection.uuid,
    ]
  }
  policies {
    name     = "allow-internet-https"
    action   = "PERMIT"
    priority = 100
    protocol = "TCP"
    logging  = true
    watch    = false
    port_ranges {
      lo = 443
    }
    src_smart_groups = [
      aviatrix_smart_group.rfc1918.uuid
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000001" # Public Internet
    ]
    web_groups = [
      aviatrix_web_group.allow_internet_https.uuid,
    ]
  }
  policies {
    name     = "allow-dev"
    action   = "PERMIT"
    priority = 200
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      aviatrix_smart_group.dev.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.dev.uuid
    ]
  }

  policies {
    name     = "allow-qa"
    action   = "PERMIT"
    priority = 300
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      aviatrix_smart_group.qa.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.qa.uuid
    ]
  }
  policies {
    name     = "allow-prod"
    action   = "PERMIT"
    priority = 400
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      aviatrix_smart_group.prod.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.prod.uuid
    ]
  }
  policies {
    name     = "allow-shared"
    action   = "PERMIT"
    priority = 500
    protocol = "TCP"
    port_ranges {
      lo = 8443
    }
    port_ranges {
      lo = 1521
    }
    logging = true
    watch   = false
    src_smart_groups = [
      aviatrix_smart_group.dev.uuid,
      aviatrix_smart_group.prod.uuid,
      aviatrix_smart_group.qa.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.shared.uuid
    ]
  }
  policies {
    name     = "allow-edge"
    action   = "PERMIT"
    priority = 600
    protocol = "TCP"
    port_ranges {
      lo = 80
      hi = 82
    }
    port_ranges {
      lo = 22
    }
    logging = true
    watch   = false
    src_smart_groups = [
      aviatrix_smart_group.edge.uuid
    ]
    dst_smart_groups = [
      aviatrix_smart_group.dev.uuid,
      aviatrix_smart_group.prod.uuid,
      aviatrix_smart_group.qa.uuid
    ]
  }
  # policies {
  #   name     = "application-deny-all"
  #   action   = "DENY"
  #   priority = 10000
  #   protocol = "Any"
  #   logging  = true
  #   watch    = false
  #   src_smart_groups = [
  #     aviatrix_smart_group.dev.uuid,
  #     aviatrix_smart_group.qa.uuid,
  #     aviatrix_smart_group.prod.uuid
  #   ]
  #   dst_smart_groups = [
  #     aviatrix_smart_group.dev.uuid,
  #     aviatrix_smart_group.qa.uuid,
  #     aviatrix_smart_group.prod.uuid
  #   ]
  # }
  policies {
    name     = "default-deny-all"
    action   = "DENY"
    priority = 2147483646
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      "def000ad-0000-0000-0000-000000000000" # Anywhere
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000000" # Anywhere
    ]
  }
  policies {
    name     = "default-allow-all"
    action   = "PERMIT"
    priority = 2147483647
    protocol = "Any"
    logging  = true
    watch    = false
    src_smart_groups = [
      "def000ad-0000-0000-0000-000000000000" # Anywhere
    ]
    dst_smart_groups = [
      "def000ad-0000-0000-0000-000000000000" # Anywhere
    ]
  }
  depends_on = [
    aviatrix_distributed_firewalling_config.demo
  ]
}

# Security Group (SG) Orchestration - Intra-Vpc
resource "aviatrix_distributed_firewalling_intra_vpc" "azure" {
  vpcs {
    account_name = var.azure_marketing_account_name
    vpc_id       = module.spokes["${var.azure_marketing_account_name}-all"].vpc.vpc_id
    region       = module.spokes["${var.azure_marketing_account_name}-all"].vpc.region
  }
  depends_on = [
    aviatrix_distributed_firewalling_config.demo,
    module.marketing_prod,
    module.marketing_dev,
    module.marketing_qa,
  ]
}
