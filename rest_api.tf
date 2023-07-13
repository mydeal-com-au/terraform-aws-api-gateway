
resource "aws_api_gateway_rest_api" "rest_api" {
  count = var.api_type == "rest" ? 1 : 0
  name  = var.name
  endpoint_configuration {
    types = ["REGIONAL"]
  }

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

  depends_on = [aws_api_gateway_method.rest_method]
}

resource "aws_api_gateway_stage" "rest_stage" {
  count         = var.api_type == "rest" ? 1 : 0
  deployment_id = aws_api_gateway_deployment.rest_deployment[0].id
  rest_api_id   = aws_api_gateway_rest_api.rest_api[0].id
  stage_name    = "${var.environment_name}-stage"
}


data "aws_iam_policy_document" "ip_resource_policy" {
  count = var.api_type == "rest" && length(var.allowed_ips) > 0 ? 1 : 0
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

resource "aws_api_gateway_resource" "rest_resource" {
  for_each    = { for integration in var.routes : integration.name => integration if var.api_type == "rest" }
  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id
  parent_id   = aws_api_gateway_rest_api.rest_api[0].root_resource_id
  path_part   = each.value.api_route_mapping
}

resource "aws_api_gateway_method" "rest_method" {
  for_each      = { for integration in var.routes : integration.name => integration if var.api_type == "rest" }
  rest_api_id   = aws_api_gateway_rest_api.rest_api[0].id
  resource_id   = aws_api_gateway_resource.rest_resource[each.value.name].id
  http_method   = each.value.integration_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  for_each                = { for integration in var.routes : integration.name => integration if var.api_type == "rest" }
  rest_api_id             = aws_api_gateway_rest_api.rest_api[0].id
  resource_id             = aws_api_gateway_resource.rest_resource[each.value.name].id
  http_method             = each.value.integration_method
  integration_http_method = aws_api_gateway_method.rest_method[each.value.name].http_method
  type                    = each.value.integration_type
  uri                     = each.value.integration_uri

  connection_type = try(each.value.connection_type, "INTERNET")
  connection_id   = var.create_vpc_link ? aws_api_gateway_vpc_link.gateway_vpc_link[0].id : ""
}
resource "aws_lb" "integration_vpc_endpoint" {
  count       = var.api_type == "rest" && var.create_vpc_link ? 1 : 0
  name               = "api-gateway-integration"
  internal           = true
  load_balancer_type = "network"
  subnets            = [data.aws_subnets.private.ids]
}
resource "aws_api_gateway_vpc_link" "gateway_vpc_link" {
  count       = var.api_type == "rest" && var.create_vpc_link ? 1 : 0
  name        = "${var.environment_name}-${var.name}-vpclink"
  description = "${var.environment_name}-${var.name} API Gateway VPC LINK"
  target_arns = [aws_lb.integration_vpc_endpoint[0].arn]
}

resource "aws_api_gateway_integration" "api_gateway_integration" {
  for_each    = { for integration in var.routes : integration.name => integration if var.api_type == "rest" && integration.integration_type == "vpc_link"}
  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id
  resource_id = aws_api_gateway_resource.rest_resource[each.value.name].id
  http_method = aws_api_gateway_method.rest_method[each.value.name].http_method

  type                    = "HTTP_PROXY"
  uri                     = each.value.integration_uri
  integration_http_method = "ANY"

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.gateway_vpc_link[0].id
}

#resource "aws_lb_target_group" "vpc_integration_tg" {
#  for_each    = { for integration in var.routes : integration.name => integration if var.api_type == "rest" && integration.integration_type == "vpc_link"}
#  name        = "tf-example-lb-alb-tg"
#  target_type = "alb"
#  port        = 443
#  protocol    = "TCP"
#  vpc_id      = data.aws_vpc.current.id
#}

