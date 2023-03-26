resource "aws_api_gateway_rest_api" "rest_api" {
  for_each     = { for api_gateway in var.apis : api_gateway.name => api_gateway }
  name         = each.value.name
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  body = file("./assets/nonprod/api_gateway/open_api_dev.json")

}

resource "aws_api_gateway_domain_name" "rest_domain_name" {
  for_each        = { for domain in var.domains : domain.name => domain }
  domain_name     = "${each.value.name}.${each.value.domain_name}"
  regional_certificate_arn = each.value.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "rest_api_records" {
  for_each = { for domain in var.domains : domain.name => domain }
  name     = aws_api_gateway_domain_name.rest_domain_name[each.value.name].domain_name
  type     = "A"
  zone_id  = each.value.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_api_gateway_domain_name.rest_domain_name[each.value.name].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.rest_domain_name[each.value.name].regional_zone_id
  }
}

data "aws_api_gateway_resource" "rest_resource" {
  for_each = { for domain in var.domains : domain.name => domain }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.api_name].id
  path        = "/${each.value.api_route_mapping}"
}


resource "aws_api_gateway_integration" "integration" {
  for_each = { for domain in var.domains : domain.name => domain }
  rest_api_id             = aws_api_gateway_rest_api.rest_api[each.value.api_name].id
  resource_id             = data.aws_api_gateway_resource.rest_resource[each.value.name].id
  http_method             = "GET"
  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = each.value.integration_uri
  depends_on = [data.aws_api_gateway_resource.rest_resource]
}