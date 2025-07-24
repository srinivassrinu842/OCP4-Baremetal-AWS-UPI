terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Bastion Module
module "bastion" {
  source = "./modules/bastion"

  environment            = var.environment
  vpc_id                 = module.network.vpc_id
  public_subnet_id       = module.network.public_subnet_id
  bastion_ami            = var.bastion_ami
  bastion_instance_type  = var.bastion_instance_type
  key_name               = var.key_name
  bastion_private_ip     = var.bastion_private_ip
  private_subnet_cidrs   = var.private_subnet_cidrs
  bootstrap1_private_ip  = var.bootst1_private_ip
  master1_private_ip     = var.master1_private_ip
  master2_private_ip     = var.master2_private_ip
  master3_private_ip     = var.master3_private_ip
  ocp_version            = var.ocp_version
  domain_name            = var.domain_name
  pull_secret            = var.pull_secret
}

# Network Module
module "network" {
  source = "./modules/network"

  environment                   = var.environment
  vpc_cidr                     = var.vpc_cidr
  public_subnet_cidr           = var.public_subnet_cidr
  private_subnet_cidrs         = var.private_subnet_cidrs
  availability_zones           = var.availability_zones
  bastion_network_interface_id = module.bastion.bastion_network_interface_id
}

# OpenShift Cluster Module
module "openshift_cluster" {
  source = "./modules/openshift_cluster"

  environment              = var.environment
  vpc_id                   = module.network.vpc_id
  vpc_cidr                 = var.vpc_cidr
  private_subnet_ids       = module.network.private_subnet_ids
  domain_name              = var.domain_name
  bastion_private_ip       = var.bastion_private_ip
  create_nodes             = var.create_nodes
  bootstrap1_private_ip    = var.bootst1_private_ip
  master_private_ips       = [var.master1_private_ip, var.master2_private_ip, var.master3_private_ip]
  node_ami                 = var.node_ami
  bootstrap_instance_type  = var.bootstrap_instance_type
  master_instance_type     = var.master_instance_type
  key_name                 = var.key_name
  bastion_instance         = module.bastion
}