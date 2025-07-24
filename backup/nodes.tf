# Security group for OpenShift nodes
resource "aws_security_group" "ocp_nodes" {
  name        = "${var.environment}-ocp-nodes-sg"
  description = "Security group for OpenShift nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "SSH access from within VPC"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "All traffic from within VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.environment}-ocp-nodes-sg"
  }
}

# Bootstrap node
resource "aws_network_interface" "bootst1" {
  subnet_id       = aws_subnet.private[0].id
  private_ips     = [var.bootst1_private_ip]
  security_groups = [aws_security_group.ocp_nodes.id]

  tags = {
    Name = "${var.environment}-bootst1-eni"
  }
}

resource "aws_instance" "bootst1" {
  count = var.create_nodes ? 1 : 0

  ami           = var.node_ami
  instance_type = var.bootstrap_instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.bootst1.id
    device_index        = 0
  }

  root_block_device {
    volume_size = 120
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.environment}-bootst1"
  }

  user_data = <<-EOF
    { 
      "ignition": { 
        "version": "3.2.0", 
        "config": { 
          "merge": [{ 
            "source": "http://10.0.1.10:8080/ignition/bootstrap.ign", 
            "verification": {} 
          }] 
        } 
      } 
    }
  EOF

  depends_on = [aws_instance.bastion]
}

# Master nodes
resource "aws_network_interface" "master1" {
  subnet_id       = aws_subnet.private[0].id
  private_ips     = [var.master1_private_ip]
  security_groups = [aws_security_group.ocp_nodes.id]

  tags = {
    Name = "${var.environment}-master1-eni"
  }
}

resource "aws_instance" "master1" {
  count = var.create_nodes ? 1 : 0

  ami           = var.node_ami
  instance_type = var.master_instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.master1.id
    device_index        = 0
  }

  root_block_device {
    volume_size = 120
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.environment}-master1"
  }

  user_data = <<-EOF
    { 
      "ignition": { 
        "version": "3.2.0", 
        "config": { 
          "merge": [{ 
            "source": "http://10.0.1.10:8080/ignition/master.ign", 
            "verification": {} 
          }] 
        } 
      } 
    }
  EOF

  depends_on = [aws_instance.bastion]
}

resource "aws_network_interface" "master2" {
  subnet_id       = aws_subnet.private[1].id
  private_ips     = [var.master2_private_ip]
  security_groups = [aws_security_group.ocp_nodes.id]

  tags = {
    Name = "${var.environment}-master2-eni"
  }
}

resource "aws_instance" "master2" {
  count = var.create_nodes ? 1 : 0

  ami           = var.node_ami
  instance_type = var.master_instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.master2.id
    device_index        = 0
  }

  root_block_device {
    volume_size = 120
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.environment}-master2"
  }

  user_data = <<-EOF
    { 
      "ignition": { 
        "version": "3.2.0", 
        "config": { 
          "merge": [{ 
            "source": "http://10.0.1.10:8080/ignition/master.ign", 
            "verification": {} 
          }] 
        } 
      } 
    }
  EOF

  depends_on = [aws_instance.bastion]
}

resource "aws_network_interface" "master3" {
  subnet_id       = aws_subnet.private[2].id
  private_ips     = [var.master3_private_ip]
  security_groups = [aws_security_group.ocp_nodes.id]

  tags = {
    Name = "${var.environment}-master3-eni"
  }
}

resource "aws_instance" "master3" {
  count = var.create_nodes ? 1 : 0

  ami           = var.node_ami
  instance_type = var.master_instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.master3.id
    device_index        = 0
  }

  root_block_device {
    volume_size = 120
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.environment}-master3"
  }

  user_data = <<-EOF
    { 
      "ignition": { 
        "version": "3.2.0", 
        "config": { 
          "merge": [{ 
            "source": "http://10.0.1.10:8080/ignition/master.ign", 
            "verification": {} 
          }] 
        } 
      } 
    }
  EOF

  depends_on = [aws_instance.bastion]
}