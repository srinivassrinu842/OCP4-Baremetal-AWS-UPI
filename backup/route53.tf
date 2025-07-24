# Private hosted zone
resource "aws_route53_zone" "private" {
  name = "${var.environment}.${var.domain_name}"

  vpc {
    vpc_id = aws_vpc.main.id
  }

  tags = {
    Name = "${var.environment}-private-zone"
  }
}

# DNS Records
resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "api.${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [var.bastion_private_ip]
}

resource "aws_route53_record" "api_int" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "api-int.${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [var.bastion_private_ip]
}

resource "aws_route53_record" "apps" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "*.apps.${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [var.bastion_private_ip]
}

resource "aws_route53_record" "bootst1" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "bootst1.${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [var.bootst1_private_ip]
}

resource "aws_route53_record" "master1" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "master1.${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [var.master1_private_ip]
}

resource "aws_route53_record" "master2" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "master2.${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [var.master2_private_ip]
}

resource "aws_route53_record" "master3" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "master3.${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [var.master3_private_ip]
}