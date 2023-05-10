resource "aws_apigatewayv2_integration" "http_integration" {
  for_each           = {for integration in var.integrations: integration.name => integration if var.api_type == "http"}
  api_id             = aws_apigatewayv2_api.api[0].id
  integration_type   = each.value.integration_type
  integration_method = each.value.integration_method
  integration_uri    = each.value.integration_uri
}
resource "aws_apigatewayv2_route" "integration_route" {
  for_each           = {for integration in var.integrations: integration.name => integration if var.api_type == "http"}
  api_id    = aws_apigatewayv2_api.api[0].id
  route_key = "ANY /${each.value.api_route_mapping}"

  target = "integrations/${aws_apigatewayv2_integration.http_integration[each.value.name].id}"
}


resource "aws_api_gateway_resource" "rest_resource" {
  for_each           = {for integration in var.integrations: integration.name => integration if var.api_type == "rest"}
  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id
  parent_id   = aws_api_gateway_rest_api.rest_api[0].root_resource_id
  path_part   = "${each.value.api_route_mapping}"
}

resource "aws_api_gateway_method" "rest_method" {
  for_each           = {for integration in var.integrations: integration.name => integration if var.api_type == "rest"}
  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id
  resource_id   = aws_api_gateway_resource.rest_resource[each.value.name].id
  http_method   = each.value.integration_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  for_each           = {for integration in var.integrations: integration.name => integration if var.api_type == "rest"}
  rest_api_id             = aws_api_gateway_rest_api.rest_api[0].id
  resource_id             = aws_api_gateway_resource.rest_resource[each.value.name].id
  http_method             = each.value.integration_method
  integration_http_method = aws_api_gateway_method.rest_method[each.value.name].http_method
  type                    = "HTTP_PROXY"
  uri                     = each.value.integration_uri

  connection_type         = try(each.value.connection_type, "INTERNET")
  connection_id           = var.create_vpc_link ? aws_api_gateway_vpc_link.gateway_vpc_link[0].id : ""
}