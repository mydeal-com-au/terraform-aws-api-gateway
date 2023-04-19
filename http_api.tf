resource "aws_apigatewayv2_api" "api" {
  count                      = var.api_type == 'http' ? 1 : 0
  name                       = var.name
  protocol_type              = "HTTP"
  description                = try(var.description, "")
  route_key                  = try(var.route_key, "")
  target                     = try(var.target, "")
}

resource "aws_apigatewayv2_integration" "http_integration" {
  for_each           = {for integration in var.integrations: integration.name => integration if var.api_type == 'http'}
  api_id             = aws_apigatewayv2_api.api[0].id
  integration_type   = each.value.integration_type
  integration_method = each.value.integration_method
  integration_uri    = each.value.integration_uri
}
resource "aws_apigatewayv2_route" "integration_route" {
  for_each           = {for integration in var.integrations: integration.name => integration if var.api_type == 'http'}
  api_id    = aws_apigatewayv2_api.api[0].id
  route_key = each.value.route_key

  target = "integrations/${aws_apigatewayv2_integration.http_integration[each.value.name].id}"
}

resource "aws_apigatewayv2_stage" "stage" {
  count       = var.api_type == 'http' ? 1 : 0
  api_id      = aws_apigatewayv2_api.api[0].id
  name        = "${var.environment_name}-stage"
  auto_deploy = true
}

resource "aws_apigatewayv2_domain_name" "domain_name" {
  for_each           = {for domain in var.domains: domain.domain => domain if var.api_type == 'http'}
  domain_name = "${each.value.domain}"

  domain_name_configuration {
    certificate_arn = each.value.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "domain_mapping" {
  for_each           = {for domain in var.domains: domain.domain => domain if var.api_type == 'http'}
  api_id          = aws_apigatewayv2_api.api[0].id
  domain_name     = aws_apigatewayv2_domain_name.domain_name[each.value.domain].id
  stage           = aws_apigatewayv2_stage.stage[0].id
  api_mapping_key = each.value.api_route_mapping
}

resource "aws_route53_record" "hosted_zone" {
  for_each           = {for domain in var.domains: domain.domain => domain if var.api_type == 'http'}
  name    = aws_apigatewayv2_domain_name.domain_name[each.value.domain].domain_name
  type    = "A"
  zone_id = each.value.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.domain_name[each.value.domain].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.domain_name[each.value.domain].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
