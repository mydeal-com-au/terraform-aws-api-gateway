resource "aws_cloudwatch_metric_alarm" "apigw_5xx_errors" {
  count = length(var.alarm_sns_topics) > 0 ? 1 : 0

  alarm_name                = "${var.environment_name}-apigw-${var.name}-5xx-errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = var.alarm_apigw_5xx_errors_threshold
  evaluation_periods        = var.alarm_apigw_5xx_evaluation
  datapoints_to_alarm       = var.alarm_apigw_5xx_datapoints
  alarm_description         = "Number of 5xx errors at ${var.name} API Gateway above threshold"
  alarm_actions             = var.alarm_sns_topics
  ok_actions                = var.alarm_sns_topics
  insufficient_data_actions = []
  treat_missing_data        = "ignore"

  metric_name = "5XXError"
  namespace   = "AWS/ApiGateway"
  period      = var.alarm_apigw_5xx_period
  statistic   = var.alarm_apigw_5xx_statistic

  dimensions = {
    ApiName = var.api_type == "http" ? aws_apigatewayv2_api.api[0].name : aws_api_gateway_rest_api.rest_api[0].name
    Stage   = var.api_type == "http" ? aws_apigatewayv2_stage.stage[0].name : aws_api_gateway_stage.rest_stage[0].stage_name
  }
  
  
}

resource "aws_cloudwatch_metric_alarm" "apigw_4xx_errors" {
  count = length(var.alarm_sns_topics) > 0 ? 1 : 0

  alarm_name                = "${var.environment_name}-apigw-${var.name}-4xx-errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = var.alarm_apigw_4xx_errors_threshold
  evaluation_periods        = var.alarm_apigw_4xx_evaluation
  datapoints_to_alarm       = var.alarm_apigw_4xx_datapoints
  alarm_description         = "Number of 400 errors at ${var.name} API Gateway above threshold"
  alarm_actions             = var.alarm_sns_topics
  ok_actions                = var.alarm_sns_topics
  insufficient_data_actions = []
  treat_missing_data        = "ignore"

  metric_name = "4XXError"
  namespace   = "AWS/ApiGateway"
  period      = var.alarm_apigw_4xx_period
  statistic   = var.alarm_apigw_4xx_statistic

  dimensions = {
    ApiName = var.api_type == "http" ? aws_apigatewayv2_api.api[0].name : aws_api_gateway_rest_api.rest_api[0].name
    Stage   = var.api_type == "http" ? aws_apigatewayv2_stage.stage[0].name : aws_api_gateway_stage.rest_stage[0].stage_name
  }
}

resource "aws_cloudwatch_metric_alarm" "apigw_integration_latency" {
  count = length(var.alarm_sns_topics) > 0 ? 1 : 0

  alarm_name                = "${var.environment_name}-apigw-${var.name}-integration-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = var.alarm_apigw_integration_latency_threshold
  evaluation_periods        = var.alarm_apigw_integration_latency_evaluation
  datapoints_to_alarm       = var.alarm_apigw_integration_latency_datapoints
  alarm_description         = "Integration latency in ${var.name} API Gateway above threshold"
  alarm_actions             = var.alarm_sns_topics
  ok_actions                = var.alarm_sns_topics
  insufficient_data_actions = []
  treat_missing_data        = "ignore"

  metric_name = "IntegrationLatency"
  namespace   = "AWS/ApiGateway"
  period      = var.alarm_apigw_integration_latency_period
  statistic   = var.alarm_apigw_integration_latency_statistic

  dimensions = {
    ApiName = var.api_type == "http" ? aws_apigatewayv2_api.api[0].name : aws_api_gateway_rest_api.rest_api[0].name
    Stage   = var.api_type == "http" ? aws_apigatewayv2_stage.stage[0].name : aws_api_gateway_stage.rest_stage[0].stage_name
  }
}

resource "aws_cloudwatch_metric_alarm" "apigw_latency" {
  count = length(var.alarm_sns_topics) > 0 ? 1 : 0

  alarm_name                = "${var.environment_name}-apigw-${var.name}-latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = var.alarm_apigw_latency_threshold
  evaluation_periods        = var.alarm_apigw_latency_evaluation
  datapoints_to_alarm       = var.alarm_apigw_latency_datapoints
  alarm_description         = "Latency in ${var.name} API Gateway above threshold"
  alarm_actions             = var.alarm_sns_topics
  ok_actions                = var.alarm_sns_topics
  insufficient_data_actions = []
  treat_missing_data        = "ignore"

  metric_name = "Latency"
  namespace   = "AWS/ApiGateway"
  period      = var.alarm_apigw_latency_period
  statistic   = var.alarm_apigw_latency_statistic

  dimensions = {
    ApiName = var.api_type == "http" ? aws_apigatewayv2_api.api[0].name : aws_api_gateway_rest_api.rest_api[0].name
    Stage   = var.api_type == "http" ? aws_apigatewayv2_stage.stage[0].name : aws_api_gateway_stage.rest_stage[0].stage_name
  }
}
