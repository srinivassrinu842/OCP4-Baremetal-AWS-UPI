variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID"
  type        = string
}

variable "bastion_ami" {
  description = "AMI ID for bastion host"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "bastion_private_ip" {
  description = "Private IP for bastion host"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "bootstrap1_private_ip" {
  description = "Private IP for bootstrap node"
  type        = string
}

variable "master1_private_ip" {
  description = "Private IP for master1 node"
  type        = string
}

variable "master2_private_ip" {
  description = "Private IP for master2 node"
  type        = string
}

variable "master3_private_ip" {
  description = "Private IP for master3 node"
  type        = string
}

variable "ocp_version" {
  description = "OpenShift version"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the cluster"
  type        = string
}

variable "pull_secret" {
  description = "Path to pull secret file"
  type        = string
}