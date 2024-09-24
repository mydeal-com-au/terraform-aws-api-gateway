resource "aws_api_gateway_authorizer" "rest_authorizer" {
  for_each = { for custom_authorizer in var.custom_authorizers : custom_authorizer.name => custom_authorizer if var.api_type == "rest" }

  name                           = each.value.name
  type                           = try(each.value.query_param, "") != "" ? "REQUEST" : "TOKEN"
  identity_source                = try(each.value.query_param, "") != "" ? "method.request.querystring.${each.value.query_param}" : "method.request.header.Authorization"
  rest_api_id                    = aws_api_gateway_rest_api.rest_api[0].id
  authorizer_uri                 = aws_lambda_function.authorizer[each.value.name].invoke_arn
  authorizer_credentials         = aws_iam_role.invocation_role[each.value.name].arn
  identity_validation_expression = try(each.value.query_param, "") != "" ? null : "^Bearer [-0-9a-zA-z\\.]*$"
}

resource "aws_iam_role" "invocation_role" {
  for_each           = { for custom_authorizer in var.custom_authorizers : custom_authorizer.name => custom_authorizer if var.api_type == "rest" }
  name               = "api_gateway_auth_invocation-${each.value.name}"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "lambda.amazonaws.com",
                    "apigateway.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "invocation_policy" {
  for_each = { for custom_authorizer in var.custom_authorizers : custom_authorizer.name => custom_authorizer if var.api_type == "rest" }
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.authorizer[each.value.name].arn]
  }
}

resource "aws_iam_role_policy" "invocation_policy" {
  for_each = { for custom_authorizer in var.custom_authorizers : custom_authorizer.name => custom_authorizer if var.api_type == "rest" }
  name     = "auth-custom-authorizer-${each.value.name}-policy"
  role     = aws_iam_role.invocation_role[each.value.name].id
  policy   = data.aws_iam_policy_document.invocation_policy[each.value.name].json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  for_each           = { for custom_authorizer in var.custom_authorizers : custom_authorizer.name => custom_authorizer if var.api_type == "rest" }
  name               = "custom-authorizer-lambda-${each.value.name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_lambda_function" "authorizer" {
  for_each         = { for custom_authorizer in var.custom_authorizers : custom_authorizer.name => custom_authorizer if var.api_type == "rest" }
  filename         = each.value.custom_authorizer_lambda_code
  function_name    = "api_gateway_authorizer-${each.value.name}-lambda"
  role             = aws_iam_role.lambda[each.value.name].arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256(each.value.custom_authorizer_lambda_code)
  runtime          = each.value.runtime

  environment {
    variables = try(each.value.variables, {
      JWKS_URI     = each.value.jwks_uri
      AUDIENCE     = each.value.audience
      TOKEN_ISSUER = each.value.token_issuer
    })
  }
}

data "aws_iam_policy" "lambda_base_role" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_default_role_policy" {
  for_each   = { for custom_authorizer in var.custom_authorizers : custom_authorizer.name => custom_authorizer if var.api_type == "rest" }
  role       = aws_iam_role.lambda[each.value.name].name
  policy_arn = data.aws_iam_policy.lambda_base_role.arn
}
