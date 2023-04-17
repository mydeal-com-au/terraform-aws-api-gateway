resource "aws_apigatewayv2_api" "api" {
  count                      = var.api_type == 'http' ? 1 : 0
  name                       = var.name
  protocol_type              = "HTTP"
  #  cors_configuration         = try(var.cors_configuration, "")
  description                = try(var.description, "")
  route_key                  = try(var.route_key, "")
  target                     = try(var.target, "")
}

resource "aws_apigatewayv2_integration" "http_integration" {
  count                      = var.api_type == 'http' ? 1 : 0
  api_id             = aws_apigatewayv2_api.api[var.api_name].id
  integration_type   = var.integration_type
  integration_method = var.integration_method
  integration_uri    = var.integration_uri
}

resource "aws_apigatewayv2_route" "integration_route" {
  count                      = var.api_type == 'http' ? 1 : 0
  api_id    = aws_apigatewayv2_api.api[var.api_name].id
  route_key = var.route_key

  target = "integrations/${aws_apigatewayv2_integration.http_integration[var.name].id}"
}

resource "aws_apigatewayv2_stage" "stage" {
  count                      = var.api_type == 'http' ? 1 : 0
  api_id      = aws_apigatewayv2_api.api[var.name].id
  name        = "${var.environment_name}-stage"
  auto_deploy = true
}

resource "aws_apigatewayv2_domain_name" "domain_name" {
  count       = var.api_type == 'http' ? 1 : 0
  domain_name = "${var.name}.${var.domain_name}"

  domain_name_configuration {
    certificate_arn = var.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "domain_mapping" {
  count                      = var.api_type == 'http' ? 1 : 0
  api_id          = aws_apigatewayv2_api.api[var.api_name].id
  domain_name     = aws_apigatewayv2_domain_name.domain_name[var.name].id
  stage           = aws_apigatewayv2_stage.stage[var.api_name].id
  api_mapping_key = var.api_route_mapping
}

resource "aws_route53_record" "hosted_zone" {
  count                      = var.api_type == 'http' ? 1 : 0
  name    = aws_apigatewayv2_domain_name.domain_name[var.name].domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.domain_name[var.name].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.domain_name[var.name].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
