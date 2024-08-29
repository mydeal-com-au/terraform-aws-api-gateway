variable "name" {
  description = "Api Gateway name"
  default     = ""
}

variable "api_type" {
  description = "Type of the API. http or rest"
  type        = string
}

variable "api_description" {
  description = "Description for the API"
  type        = string
  default     = ""
}

variable "open_api_file" {
  description = "Path to the open api specification"
  default     = ""
  type        = string
}

variable "target_arn" {
  description = "Target ARN's to the vpc link"
  default     = ""
  type        = string
}

variable "environment_name" {
  description = "Name of the environment"
  default     = ""
  type        = string
}

variable "domains" {
  description = "Domains to be created for the API GATEWAY"
  default     = []
  type = list(object({
    domain            = string
    api_route_mapping = string
    zone_name         = string
  }))
}

variable "create_dns_record" {
  description = "When enabled, creates the route53 record for the custom domain"
  type        = bool
  default     = true
}

variable "routes" {
  description = "Routes to be created in the API"
  default     = []
  type = list(object({
    name             = string
    method           = string
    integration_type = string
    integration_uri  = string
    route_mapping    = string
    path_parameters  = optional(list(string))
    connection_type  = optional(string)
  }))

}

variable "create_vpc_link" {
  description = ""
  type        = bool
  default     = false
}

variable "target_type" {
  description = "The type of target for the rest api integration"
  type        = string
  default     = "alb"
}

variable "lambda_name" {
  description = "The integration lambda (if lambda integration type) for permissions"
  type        = string
  default     = ""
}

variable "vpc_link_target_id" {
  description = "ARN of the resource to attach for the VPC link load balancer target"
  type        = string
  default     = ""
}

variable "vpc_link_target_name" {
  description = "Name of the resource to attach for the VPC link load balancer target"
  type        = string
  default     = ""
}

variable "vpc_link_target_port" {
  description = "TCP Port of the resource to attach for the VPC link load balancer target"
  type        = number
  default     = 443
}

variable "vpc_link_target_health_check_path" {
  description = "VPC link load balancer target health check path"
  type        = string
  default     = "/"
}

variable "create_api_key" {
  description = "Boolean variable that's evaluate the creation of an api key"
  type        = bool
  default     = false
}

variable "tags" {
  default = {}
}

variable "allowed_ips" {
  description = "List of allowed IP's to access the API"
  type        = list(any)
  default     = []
}

variable "enable_custom_authorizer" {
  type    = bool
  default = false
}

variable "custom_authorizers" {
  description = "Custom authorizer variables"
  default     = []
  type = list(object({
    name                          = string
    runtime                       = string
    custom_authorizer_lambda_code = string
    jwks_uri                      = string
    audience                      = string
    token_issuer                  = string
  }))
}

variable "api_key_required" {
  type    = bool
  default = false
}

variable "alarm_sns_topics" {
  default     = []
  description = "Alarm topics to create and alert on API Gateway service metrics. Leaving empty disables all alarms."
}

variable "alarm_apigw_5xx_errors_threshold" {
  description = "Anomaly detection threshold for HTTP 500 errors"
  default     = 5
}

variable "alarm_apigw_4xx_errors_threshold" {
  description = "Anomaly detection threshold for HTTP 400 errors"
  default     = 9
}

variable "alarm_apigw_integration_latency_threshold" {
  description = "Anomaly detection threshold for Integration latency"
  default     = 9
}

variable "alarm_apigw_latency_threshold" {
  description = "Threshold for api gateway latency"
  default     = 15
}

variable "alarm_apigw_5xx_evaluation" {
  description = "Api Gateway 5xx evaluation periods"
  default     = 2
}

variable "alarm_apigw_5xx_datapoints" {
  description = "Api Gateway 5xx data points to evaluate"
  default     = 2
}

variable "alarm_apigw_4xx_evaluation" {
  description = "Api Gateway 4xx evaluation periods"
  default     = 2
}

variable "alarm_apigw_4xx_datapoints" {
  description = "Api Gateway 4xx data points to evaluate"
  default     = 2
}

variable "alarm_apigw_integration_latency_evaluation" {
  description = "Api Gateway integration latency evaluation periods"
  default     = 2
}

variable "alarm_apigw_integration_latency_datapoints" {
  description = "Api Gateway integration latency data points to evaluate"
  default     = 2
}

variable "alarm_apigw_latency_evaluation" {
  description = "Api Gateway latency evaluation periods"
  default     = 2
}

variable "alarm_apigw_latency_datapoints" {
  description = "Api Gateway latency data points to evaluate"
  default     = 2
}

variable "vpc_link_subnets" {
  description = "subnets for vpc link load balancer"
  default     = []
  type        = list(string)
}

variable "vpc_id" {
  description = "vpc for load balancer"
  default     = ""
  type        = string
}

variable "vpc_link_id" {
  description = "vpc link id for the api gateway integration"
  default     = ""
  type        = string
}


variable "binary_media_types" {
  description = "binary media types for the rest api"
  default     = []
  type        = list(string)
}

variable "web_acl_arn" {
  description = "regional waf acl arn, attached to the rest api endpoint"
  default     = ""
  type        = string
}

variable "attach_waf" {
  description = "attach waf to the rest api endpoint"
  default     = false
  type        = bool
}

variable "redeployment_sha" {
  default = ""
  type    = string
}
