locals {
  pull_secret_content = file(var.pull_secret)
}

# Security group for bastion host
resource "aws_security_group" "bastion" {
  name        = "${var.environment}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }
  
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kubernetes API access"
  }
  
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Custom port 9000"
  }
  
  ingress {
    from_port   = 22623
    to_port     = 22623
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Machine Config Server"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Machine Config Server"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.environment}-bastion-sg"
  }
}

# Bastion host network interface
resource "aws_network_interface" "bastion" {
  subnet_id       = var.public_subnet_id
  private_ips     = [var.bastion_private_ip]
  security_groups = [aws_security_group.bastion.id]
  source_dest_check = false

  tags = {
    Name = "${var.environment}-bastion-eni"
  }
}

# Bastion host EC2 instance
resource "aws_instance" "bastion" {
  ami           = var.bastion_ami
  instance_type = var.bastion_instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.bastion.id
    device_index         = 0
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.environment}-bastion"
  }

  user_data = templatefile("${path.module}/../../bastion_setup.tftpl", {
    bastion_private_ip     = var.bastion_private_ip
    private_subnet_cidr_0  = var.private_subnet_cidrs[0]
    private_subnet_cidr_1  = var.private_subnet_cidrs[1]
    private_subnet_cidr_2  = var.private_subnet_cidrs[2]
    bootstrap1_private_ip  = var.bootstrap1_private_ip
    master1_private_ip     = var.master1_private_ip
    master2_private_ip     = var.master2_private_ip
    master3_private_ip     = var.master3_private_ip
    ocp_version            = var.ocp_version
    domain_name            = var.domain_name
    environment            = var.environment
    pull_secret            = local.pull_secret_content
    MIRROR                 = "https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp"
  })
}