output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = module.network.public_subnet_id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.network.private_subnet_ids
}

output "bastion_public_ip" {
  description = "The public IP of the bastion host"
  value       = module.bastion.bastion_public_ip
}

output "bastion_private_ip" {
  description = "The private IP of the bastion host"
  value       = module.bastion.bastion_private_ip
}

output "private_hosted_zone_id" {
  description = "The ID of the private hosted zone"
  value       = module.openshift_cluster.private_hosted_zone_id
}

output "bootstrap_private_ip" {
  description = "The private IP of the bootstrap node"
  value       = module.openshift_cluster.bootstrap_private_ip
}

output "master1_private_ip" {
  description = "The private IP of master1 node"
  value       = length(module.openshift_cluster.master_private_ips) > 0 ? module.openshift_cluster.master_private_ips[0] : "Not created yet"
}

output "master2_private_ip" {
  description = "The private IP of master2 node"
  value       = length(module.openshift_cluster.master_private_ips) > 1 ? module.openshift_cluster.master_private_ips[1] : "Not created yet"
}

output "master3_private_ip" {
  description = "The private IP of master3 node"
  value       = length(module.openshift_cluster.master_private_ips) > 2 ? module.openshift_cluster.master_private_ips[2] : "Not created yet"
}