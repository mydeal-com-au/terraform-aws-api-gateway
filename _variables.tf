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
  default = ""
}

variable "open_api_file" {
  description = "Path to the open api specification"
  default = ""
  type    = string
}

variable "target_arn" {
  description = "Target ARN's to the vpc link"
  default =  ""
  type    = string
}

variable "environment_name" {
  description = "Name of the environment"
  default = ""
  type    = string
}

variable "domains" {
  description = "Domains to be created for the API GATEWAY"
  default = []
  type = list(object({
    domain = string
    api_route_mapping = string
    certificate_arn = string
    zone_id = string
  }))
}

variable "integrations" {
  description = "Integrations to be created in the API GATEWAY"
  default = []
  type = list(object({
    name = string
    integration_type = string
    integration_method = string
    integration_uri = string
    api_route_mapping = string
    connection_type   = string
  }))
}

variable "create_vpc_link" {
  description = ""
  type = bool
  default = false
}

variable "create_api_key" {
  description = "Boolean variable that's evaluate the creation of an api key"
  type = bool
  default = false
}

variable "tags" {
  default = {}
}

variable "allowed_ips" {
  description = "List of allowed IP's to access the API"
  type = list
  default = []
}