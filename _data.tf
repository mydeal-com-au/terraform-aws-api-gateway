data "aws_vpc" "current" {}

data "aws_subnets" "current" {
  tags = {
    "Scheme" = "private"
  }
}

data "aws_acm_certificate" "current" {
  domain   = var.hostZoneName
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "current" {
  name = var.hostZoneName
}
