output "private_hosted_zone_id" {
  description = "ID of the private hosted zone"
  value       = aws_route53_zone.private.zone_id
}

output "bootstrap_private_ip" {
  description = "Private IP of the bootstrap node"
  value       = var.create_nodes ? aws_instance.bootst1[0].private_ip : null
}

output "master_private_ips" {
  description = "Private IPs of the master nodes"
  value       = var.create_nodes ? aws_instance.master[*].private_ip : []
}