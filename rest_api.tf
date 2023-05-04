
resource "aws_api_gateway_rest_api" "rest_api" {
  count       = var.api_type == "rest" ? 1 : 0
  name         = var.name
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