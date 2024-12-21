output "palo_alb" {
  description = "The outputs for the palo alto firewall alb"
  value       = aws_lb.palo
}

output "workload_instances" {
  description = "List of deployed workload instance names"
  value = {
    apps   = formatlist("%s.demo.aviatrixtest.com", local.apps)
    data   = formatlist("%s.demo.aviatrixtest.com", local.data)
    shared = formatlist("%s.demo.aviatrixtest.com", local.shared)
  }
}
