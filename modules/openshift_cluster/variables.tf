variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "domain_name" {
  description = "Domain name for the cluster"
  type        = string
}

variable "bastion_private_ip" {
  description = "Private IP of the bastion host"
  type        = string
}

variable "create_nodes" {
  description = "Whether to create OpenShift nodes"
  type        = bool
  default     = false
}

variable "bootstrap1_private_ip" {
  description = "Private IP for bootstrap node"
  type        = string
}

variable "master_private_ips" {
  description = "Private IPs for master nodes"
  type        = list(string)
}

/*
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
*/

variable "node_ami" {
  description = "AMI ID for OpenShift nodes"
  type        = string
}

variable "bootstrap_instance_type" {
  description = "Instance type for bootstrap node"
  type        = string
}

variable "master_instance_type" {
  description = "Instance type for master nodes"
  type        = string
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "bastion_instance" {
  description = "Bastion instance for dependency"
  type        = any
}