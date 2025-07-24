resource "aws_route53_zone" "private" {
  name = var.domain_name

  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name = "${var.environment}-private-zone"
  }
}

# Route53 Records
resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "api.${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.bastion_private_ip]
}

resource "aws_route53_record" "api_int" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "api-int.${var.environment}.${var.domain_name}" 
  type    = "A"
  ttl     = 300
  records = [var.bastion_private_ip]
}

resource "aws_route53_record" "apps" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "*.apps.${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.bastion_private_ip]
}

resource "aws_route53_record" "bootstrap" {
  count   = var.create_nodes ? 1 : 0
  zone_id = aws_route53_zone.private.zone_id
  name    = "bootst1.${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.bootstrap1_private_ip]
}

resource "aws_route53_record" "master1" {
  count   = var.create_nodes ? 1 : 0
  zone_id = aws_route53_zone.private.zone_id
  name    = "master1.${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.master_private_ips[0]]
}

resource "aws_route53_record" "master2" {
  count   = var.create_nodes ? 1 : 0
  zone_id = aws_route53_zone.private.zone_id
  name    = "master2.${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.master_private_ips[1]]
}

resource "aws_route53_record" "master3" {
  count   = var.create_nodes ? 1 : 0
  zone_id = aws_route53_zone.private.zone_id
  name    = "master3.${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [var.master_private_ips[2]]
}

# Security group for OpenShift nodes
resource "aws_security_group" "openshift_nodes" {
  count       = var.create_nodes ? 1 : 0
  name        = "${var.environment}-openshift-nodes-sg"
  description = "Security group for OpenShift nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "SSH access from VPC"
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Kubernetes API"
  }

  ingress {
    from_port   = 22623
    to_port     = 22623
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Machine Config Server"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.environment}-openshift-nodes-sg"
  }
}

# Bootstrap Node
resource "aws_network_interface" "bootst1" {
  count           = var.create_nodes ? 1 : 0
  subnet_id       = var.private_subnet_ids[0]
  private_ips     = [var.bootstrap1_private_ip]
  security_groups = [aws_security_group.openshift_nodes[0].id]

  tags = {
    Name = "${var.environment}-bootstrap-eni"
  }
}

resource "aws_instance" "bootst1" {
  count         = var.create_nodes ? 1 : 0
  ami           = var.node_ami
  instance_type = var.bootstrap_instance_type
  key_name      = var.key_name

  network_interface {
    network_interface_id = aws_network_interface.bootst1[0].id
    device_index         = 0
  }

  root_block_device {
    volume_size = 60
    volume_type = "gp3"
  }

  user_data = <<-EOF
    { 
      "ignition": { 
        "version": "3.2.0", 
        "config": { 
          "merge": [{ 
            "source": "http://${var.bastion_private_ip}:8080/ignition/bootstrap.ign", 
            "verification": {} 
          }] 
        } 
      } 
    }
  EOF

  tags = {
    Name = "${var.environment}-bootstrap"
  }

  depends_on = [var.bastion_instance]
}

# Master Nodes
resource "aws_instance" "master" {
  count         = var.create_nodes ? 3 : 0
  ami           = var.node_ami
  instance_type = var.master_instance_type
  key_name      = var.key_name
  subnet_id     = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]

  private_ip = var.master_private_ips[count.index]

  vpc_security_group_ids = [aws_security_group.openshift_nodes[0].id]

  root_block_device {
    volume_size = 120
    volume_type = "gp3"
  }

  user_data = <<-EOF
    { 
      "ignition": { 
        "version": "3.2.0", 
        "config": { 
          "merge": [{ 
            "source": "http://${var.bastion_private_ip}:8080/ignition/master.ign", 
            "verification": {} 
          }] 
        } 
      } 
    }
  EOF

  tags = {
    Name = "${var.environment}-master-${count.index + 1}"
  }

  depends_on = [aws_instance.bootst1]
}

# Remove the individual master node resources
/*
resource "aws_instance" "master1" { ... }
resource "aws_instance" "master2" { ... }
resource "aws_instance" "master3" { ... }
*/