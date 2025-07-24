variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "domain_name" {
  description = "Domain name for the private hosted zone"
  type        = string
  default     = "lab.ocp.lan"
}

variable "bastion_ami" {
  description = "AMI ID for bastion host"
  type        = string
  default     = "ami-0dfc569a8686b9320"
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.medium"
}

variable "ocp_version" {
  description = "OpenShift version"
  type        = string
  default     = "4.14.0"
}

variable "key_name" {
  description = "SSH key name"
  type        = string
  default     = "my-key"
}

variable "bastion_private_ip" {
  description = "Private IP for bastion host"
  type        = string
  default     = "10.0.1.10"
}

variable "bootst1_private_ip" {
  description = "Private IP for bootstrap node"
  type        = string
  default     = "10.0.2.10"
}

variable "master1_private_ip" {
  description = "Private IP for master1 node"
  type        = string
  default     = "10.0.2.11"
}

variable "master2_private_ip" {
  description = "Private IP for master2 node"
  type        = string
  default     = "10.0.3.11"
}

variable "master3_private_ip" {
  description = "Private IP for master3 node"
  type        = string
  default     = "10.0.4.11"
}

variable "create_nodes" {
  description = "Whether to create bootstrap and master nodes"
  type        = bool
  default     = false
}

variable "node_ami" {
  description = "AMI ID for OpenShift nodes"
  type        = string
  default     = "ami-0dfc569a8686b9320"  # Same as bastion by default
}

variable "bootstrap_instance_type" {
  description = "Instance type for bootstrap node"
  type        = string
  default     = "t3.xlarge"
}

variable "master_instance_type" {
  description = "Instance type for master nodes"
  type        = string
  default     = "t3.xlarge"
}

variable "pull_secret" {
  description = "Pull secret for OpenShift"
  type        = string
  default     = "pull-secret.txt"
}
