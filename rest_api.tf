
resource "aws_api_gateway_rest_api" "rest_api" {
  count       = var.api_type == "rest" ? 1 : 0
  name         = var.name
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  body = file(var.open_api_file)

}

resource "aws_api_gateway_domain_name" "rest_domain_name" {
  for_each           = {for domain in var.domains: domain.domain => domain if var.api_type == "rest"}
  domain_name              = "${each.value.domain}"
  regional_certificate_arn = data.aws_acm_certificate.certificates[each.value.domain].arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "rest_api_mapping" {
  for_each           = {for domain in var.domains: domain.domain => domain if var.api_type == "rest"}
  api_id      = aws_api_gateway_rest_api.rest_api[0].id
  domain_name = aws_api_gateway_domain_name.rest_domain_name[each.value.domain].domain_name
  stage_name  = "${var.environment_name}-stage"
  depends_on = [aws_api_gateway_stage.rest_stage]
}

resource "aws_route53_record" "rest_api_records" {
  for_each           = {for domain in var.domains: domain.domain => domain if var.api_type == "rest"}
  name     = aws_api_gateway_domain_name.rest_domain_name[each.value.domain].domain_name
  type     = "A"
  zone_id  = data.aws_route53_zone.hosted_zones[each.value.domain].id

  alias {
    evaluate_target_health = false
    name                   = aws_api_gateway_domain_name.rest_domain_name[each.value.domain].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.rest_domain_name[each.value.domain].regional_zone_id
  }
}

data "aws_api_gateway_resource" "rest_resource" {
  for_each           = {for integration in var.integrations: integration.name => integration if var.api_type == "rest"}
  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id
  path        = "/${each.value.api_route_mapping}"
}


resource "aws_api_gateway_integration" "integration" {
  for_each           = {for integration in var.integrations: integration.name => integration if var.api_type == "rest"}
  rest_api_id             = aws_api_gateway_rest_api.rest_api[0].id
  resource_id             = data.aws_api_gateway_resource.rest_resource[each.value.name].id
  http_method             = "GET"
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = each.value.integration_uri

  connection_type         = try(each.value.connection_type, "INTERNET")
  connection_id           = var.create_vpc_link ? aws_api_gateway_vpc_link.gateway_vpc_link[0].id : ""
  depends_on = [data.aws_api_gateway_resource.rest_resource]
}

resource "aws_api_gateway_deployment" "rest_deployment" {
  count       = var.api_type == "rest" ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api[0].body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "rest_stage" {
  count       = var.api_type == "rest" ? 1 : 0
  deployment_id = aws_api_gateway_deployment.rest_deployment[0].id
  rest_api_id   = aws_api_gateway_rest_api.rest_api[0].id
  stage_name    = "${var.environment_name}-stage"
}

resource "aws_api_gateway_vpc_link" "gateway_vpc_link" {
  count       = var.api_type == "rest" && var.create_vpc_link ? 1 : 0
  name        = "${var.environment_name}-${var.name}-vpclink"
  description = "${var.environment_name}-${var.name} API Gateway VPC LINK"
  target_arns = [var.target_arn]
}

data "aws_iam_policy_document" "ip_resource_policy" {
  count       = var.api_type == "rest" && length(var.allowed_ips) > 0 ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = [aws_api_gateway_rest_api.rest_api[0].execution_arn]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.allowed_ips
    }
  }
}
resource "aws_api_gateway_rest_api_policy" "test" {
  count       = var.api_type == "rest" && length(var.allowed_ips) > 0 ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id
  policy      = data.aws_iam_policy_document.ip_resource_policy[0].json
}

#
#resource "aws_wafv2_web_acl_association" "rest_waf_association" {
#  count       = var.api_type == "rest" && length(var.web_acl_arn) > 0 ? 1 : 0
#  resource_arn  = aws_api_gateway_stage.rest_stage[var.name].arn
#  web_acl_arn   = var.web_acl_arn
#}