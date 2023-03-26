resource "aws_apigatewayv2_api" "api" {
  for_each                   = { for api_gateway in var.apis : api_gateway.name => api_gateway }
  name                       = each.value.name
  protocol_type              = try(each.value.protocol_type, "HTTP")
  #  cors_configuration         = try(each.value.cors_configuration, "")
  description                = try(each.value.description, "")
  route_key                  = try(each.value.route_key, "")
  target                     = try(each.value.target, "")
}


resource "aws_apigatewayv2_integration" "http_integration" {
  for_each           = { for integration in var.integrations : integration.name => integration }
  api_id             = aws_apigatewayv2_api.api[each.value.api_name].id
  integration_type   = each.value.integration_type
  integration_method = each.value.integration_method
  integration_uri    = each.value.integration_uri
}

resource "aws_apigatewayv2_route" "integration_route" {
  for_each  = { for integration in var.integrations : integration.name => integration }
  api_id    = aws_apigatewayv2_api.api[each.value.api_name].id
  route_key = each.value.route_key

  target = "integrations/${aws_apigatewayv2_integration.http_integration[each.value.name].id}"
}

resource "aws_apigatewayv2_stage" "stage" {
  for_each    = { for api_gateway in var.apis : api_gateway.name => api_gateway }
  api_id      = aws_apigatewayv2_api.api[each.value.name].id
  name        = "${local.workspace.environment_name}-stage"
  auto_deploy = true
}

resource "aws_apigatewayv2_domain_name" "domain_name" {
  for_each    = { for domain in var.domains : domain.name => domain }
  domain_name = "${each.value.name}.${each.value.domain_name}"

  domain_name_configuration {
    certificate_arn = each.value.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "domain_mapping" {
  for_each        = { for domain in var.domains : domain.name => domain }
  api_id          = aws_apigatewayv2_api.api[each.value.api_name].id
  domain_name     = aws_apigatewayv2_domain_name.domain_name[each.value.name].id
  stage           = aws_apigatewayv2_stage.stage[each.value.api_name].id
  api_mapping_key = each.value.api_route_mapping
}

resource "aws_route53_record" "hosted_zone" {
  for_each    = { for domain in var.domains : domain.name => domain }
  name    = aws_apigatewayv2_domain_name.domain_name[each.value.name].domain_name
  type    = "A"
  zone_id = each.value.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.domain_name[each.value.name].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.domain_name[each.value.name].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}