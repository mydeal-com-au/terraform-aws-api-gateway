variable "api_type" {
  description = "Type of the API. http or rest"
  type        = string
}

variable "name" {
  description = "Api Gateway name"
  default     = ""
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  default     = ""
  type        = string
}

variable "api_name" {
  description = "Api Gateway name"
  default     = ""
  type        = string
}

variable "environment_name" {
  description = "Environment name"
  default     = ""
  type        = string
}


variable "zone_id" {
  description = "Hosted zone id"
  default     = ""
  type        = string
}

variable "api_route_mapping" {
  description = "Api routing path"
  default     = ""
  type        = string
}

variable "integration_uri" {
  description = "RI of the Lambda function for a Lambda proxy integration, when integration_type is AWS_PROXY."
  default     = ""
  type        = string
}

variable "http_description" {
  description = "Description of the API. Must be less than or equal to 1024 characters in length."
  default     = ""
  type        = string
}

variable "route_key" {
  description = "Part of quick create. Specifies any route key. Applicable for HTTP APIs."
  default     = ""
  type        = string
}

variable "target" {
  description = " Part of quick create. Quick create produces an API with an integration, a default catch-all route, and a default stage which is configured to automatically deploy changes."
  default     = ""
  type        = string
}


variable "integration_type" {
  description = "ntegration type of an integration. Valid values: AWS (supported only for WebSocket APIs), AWS_PROXY, HTTP (supported only for WebSocket APIs), HTTP_PROXY, MOCK (supported only for WebSocket APIs)."
  default     = ""
  type        = string
}

variable "integration_method" {
  description = " Integration's HTTP method. Must be specified if integration_type is not MOCK."
  default     = ""
  type        = string
}

variable "certificate_arn" {
  description = " ARN of an AWS-managed certificate that will be used by the endpoint for the domain name. AWS Certificate Manager is the only supported source. Use the aws_acm_certificate resource to configure an ACM certificate."
  default     = ""
  type        = string
}