output "public_ip" {
  value = var.public_ip ? google_compute_instance.this.network_interface[0].access_config[0].nat_ip : null
}

output "private_ip" {
  value = google_compute_instance.this.network_interface[0].network_ip
}
