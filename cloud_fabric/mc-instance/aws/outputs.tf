output "public_ip" {
  value = var.public_ip ? aws_instance.this.public_ip : null
}

output "private_ip" {
  value = aws_instance.this.private_ip
}
