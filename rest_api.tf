
resource "aws_api_gateway_rest_api" "rest_api" {
  count       = var.api_type == 'rest' ? 1 : 0
  name         = var.name
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  body = file("./assets/nonprod/api_gateway/open_api_dev.json")

}

resource "aws_api_gateway_domain_name" "rest_domain_name" {
  count       = var.api_type == 'rest' ? 1 : 0
  domain_name              = "${var.name}.${var.domain_name}"
  regional_certificate_arn = var.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "rest_api_mapping" {
  count       = var.api_type == 'rest' ? 1 : 0
  api_id      = aws_api_gateway_rest_api.rest_api[var.api_name].id
  domain_name = aws_api_gateway_domain_name.rest_domain_name[var.name].domain_name
  stage_name  = "${var.environment_name}-stage"
  depends_on = [aws_api_gateway_stage.rest_stage]
}

resource "aws_route53_record" "rest_api_records" {
  count       = var.api_type == 'rest' ? 1 : 0
  name     = aws_api_gateway_domain_name.rest_domain_name[var.name].domain_name
  type     = "A"
  zone_id  = var.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_api_gateway_domain_name.rest_domain_name[var.name].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.rest_domain_name[var.name].regional_zone_id
  }
}

data "aws_api_gateway_resource" "rest_resource" {
  count       = var.api_type == 'rest' ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.rest_api[var.api_name].id
  path        = "/${var.api_route_mapping}"
}


resource "aws_api_gateway_integration" "integration" {
  count       = var.api_type == 'rest' ? 1 : 0
  rest_api_id             = aws_api_gateway_rest_api.rest_api[var.api_name].id
  resource_id             = data.aws_api_gateway_resource.rest_resource[var.name].id
  http_method             = "GET"
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = var.integration_uri
  depends_on = [data.aws_api_gateway_resource.rest_resource]
}

resource "aws_api_gateway_deployment" "rest_deployment" {
  count       = var.api_type == 'rest' ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.rest_api[var.name].id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api[var.name].body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "rest_stage" {
  count       = var.api_type == 'rest' ? 1 : 0
  deployment_id = aws_api_gateway_deployment.rest_deployment[var.name].id
  rest_api_id   = aws_api_gateway_rest_api.rest_api[var.name].id
  stage_name    = "${var.environment_name}-stage"
}
#
resource "aws_wafv2_web_acl_association" "rest_waf_association" {
  count       = var.api_type == 'rest' && length(var.web_acl_arn) > 0 ? 1 : 0
  resource_arn  = aws_api_gateway_stage.rest_stage[var.name].arn
  web_acl_arn   = var.web_acl_arn
}