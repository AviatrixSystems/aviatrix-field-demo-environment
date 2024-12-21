data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "this" {
  name         = var.name
  machine_type = var.instance_size
  zone         = "${var.region}-b"

  boot_disk {
    initialize_params {
      image = var.image == null ? data.google_compute_image.ubuntu.self_link : var.image
    }
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.subnet_id
    network_ip = var.private_ip != null ? var.private_ip : null
    dynamic "access_config" {
      for_each = var.public_ip ? ["public_ip"] : []

      content {
        #   // Ephemeral public IP
      }
    }
    # enable for instance troubleshooting
    # access_config {
    #   // Ephemeral public IP
    # }
  }

  metadata_startup_script = var.user_data_templatefile

  labels = merge(local.lower_common_tags, {
    name = var.name
  })

  tags = ["instance", "avx-snat-noip"]
  metadata = {
    ssh-keys = fileexists("~/.ssh/id_rsa.pub") ? "ubuntu:${file("~/.ssh/id_rsa.pub")}" : null
  }
}

resource "google_compute_firewall" "this_ingress" {
  name    = "${var.name}-ingress"
  network = var.vpc_id

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
  target_tags   = ["instance"]
}

resource "google_compute_firewall" "this_ingress_tcp" {
  for_each = var.inbound_tcp
  name     = "${var.name}-ingress-tcp-${each.key}"
  network  = var.vpc_id

  allow {
    protocol = "tcp"
    ports    = [each.key]
  }

  source_ranges = each.value
  target_tags   = ["instance"]
}

resource "google_compute_firewall" "this_ingress_udp" {
  for_each = var.inbound_udp
  name     = "${var.name}-ingress-udp-${each.key}"
  network  = var.vpc_id

  allow {
    protocol = "udp"
    ports    = [each.key]
  }

  source_ranges = each.value
  target_tags   = ["instance"]
}

resource "google_compute_firewall" "this_egress" {
  name      = "${var.name}-egress"
  network   = var.vpc_id
  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["instance"]
}
