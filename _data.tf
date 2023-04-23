data "aws_vpc" "current" {}

data "aws_subnets" "current" {
  tags = {
    "Scheme" = "private"
  }
}

