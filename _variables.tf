variable "name" {
  description = "Api Gateway name"
  default     = ""
  type        = string
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

variable "routes" {
  description = "Routes to be created in the API"
  default     = []
  type = list(object({
    name             = string
    method           = string
    integration_type = string
    integration_uri  = string
    route_mapping    = string
    connection_type  = string
  }))

  validation {
    condition = length([
      for route in var.routes : true
      if contains(["HTTP", "HTTP_PROXY", "AWS_PROXY", "VPC_LINK"], route.integration_type)
    ]) == length(var.routes)
    error_message = "The integration_type must be HTTP, or HTTP_PROXY or VPC_LINK or AWS_PROXY."
  }
}

variable "create_vpc_link" {
  description = ""
  type        = bool
  default     = false
}

variable "create_api_key" {
  description = "Boolean variable that's evaluate the creation of an api key"
  type        = bool
  default     = false
}

variable "tags" {
  default = {}
  type    = map(string)
}

variable "allowed_ips" {
  description = "List of allowed IP's to access the API"
  type        = list(any)
  default     = []
}

variable "custom_authorizers" {
  description = "Custom authorizer variables"
  default     = []
  type = list(object({
    name                          = string
    custom_authorizer_lambda_code = string
  }))

}