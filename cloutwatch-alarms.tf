resource "aws_cloudwatch_metric_alarm" "apigw_5xx_errors" {
  count = length(var.alarm_sns_topics) > 0 ? 1 : 0

  alarm_name                = "${var.environment_name}-apigw-${var.name}-5xx-errors"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = "1"
  datapoints_to_alarm       = "1"
  alarm_description         = "Number of 5xx errors at ${var.name} API Gateway above threshold"
  alarm_actions             = var.alarm_sns_topics
  ok_actions                = var.alarm_sns_topics
  insufficient_data_actions = []
  treat_missing_data        = "ignore"
  threshold_metric_id       = "e1"

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 3)"
    label       = "5xx Errors (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "5XXError"
      namespace   = "AWS/ApiGateway"
      period      = 300
      stat        = "Sum"

      dimensions = {
         ApiName = var.api_type == "http" ? aws_apigatewayv2_api.api[0].name : aws_api_gateway_rest_api.rest_api[0].name
         Stage = var.api_type == "http" ? aws_apigatewayv2_stage.stage[0].name : aws_api_gateway_stage.rest_stage[0].stage_name
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "apigw_4xx_errors" {
  count = length(var.alarm_sns_topics) > 0 ? 1 : 0

  alarm_name                = "${var.environment_name}-apigw-${var.name}-4xx-errors"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = "2"
  datapoints_to_alarm       = "2"
  alarm_description         = "Number of 400 errors at ${var.name} API Gateway above threshold"
  alarm_actions             = var.alarm_sns_topics
  ok_actions                = var.alarm_sns_topics
  insufficient_data_actions = []
  treat_missing_data        = "ignore"
  threshold_metric_id       = "e1"

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 3)"
    label       = "4xx Errors (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "4XXError"
      namespace   = "AWS/ApiGateway"
      period      = 300
      stat        = "Sum"

      dimensions = {
         ApiName = var.api_type == "http" ? aws_apigatewayv2_api.api[0].name : aws_api_gateway_rest_api.rest_api[0].name
         Stage = var.api_type == "http" ? aws_apigatewayv2_stage.stage[0].name : aws_api_gateway_stage.rest_stage[0].stage_name
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "apigw_integration_latency" {
  count = length(var.alarm_sns_topics) > 0 ? 1 : 0

  alarm_name                = "${var.environment_name}-apigw-${var.name}-integration-latency"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = var.alarm_apigw_integration_latency_evaluation
  datapoints_to_alarm       = var.alarm_apigw_integration_latency_datapoints
  alarm_description         = "Integration latency in ${var.name} API Gateway above threshold"
  alarm_actions             = var.alarm_sns_topics
  ok_actions                = var.alarm_sns_topics
  insufficient_data_actions = []
  treat_missing_data        = "ignore"
  threshold_metric_id       = "e1"

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 3)"
    label       = "IntegrationLatency (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "IntegrationLatency"
      namespace   = "AWS/ApiGateway"
      period      = 300
      stat        = "Maximum"

      dimensions = {
         ApiName = var.api_type == "http" ? aws_apigatewayv2_api.api[0].name : aws_api_gateway_rest_api.rest_api[0].name
         Stage = var.api_type == "http" ? aws_apigatewayv2_stage.stage[0].name : aws_api_gateway_stage.rest_stage[0].stage_name
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "apigw_latency" {
  count = length(var.alarm_sns_topics) > 0 ? 1 : 0

  alarm_name                = "${var.environment_name}-apigw-${var.name}-latency"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = var.alarm_apigw_latency_evaluation
  datapoints_to_alarm       = var.alarm_apigw_latency_datapoints
  alarm_description         = "Latency in ${var.name} API Gateway above threshold"
  alarm_actions             = var.alarm_sns_topics
  ok_actions                = var.alarm_sns_topics
  insufficient_data_actions = []
  treat_missing_data        = "ignore"
  threshold_metric_id       = "e1"

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 3)"
    label       = "Latency (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "Latency"
      namespace   = "AWS/ApiGateway"
      period      = 300
      stat        = "Maximum"

      dimensions = {
         ApiName = var.api_type == "http" ? aws_apigatewayv2_api.api[0].name : aws_api_gateway_rest_api.rest_api[0].name
         Stage = var.api_type == "http" ? aws_apigatewayv2_stage.stage[0].name : aws_api_gateway_stage.rest_stage[0].stage_name
      }
    }
  }
}
