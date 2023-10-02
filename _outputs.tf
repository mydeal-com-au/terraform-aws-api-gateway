output "api_gateway_domain_targets" {
  value = { for domain in var.domains : domain.domain =>
    {
      name = (var.api_type == "http"
        ? try(aws_apigatewayv2_domain_name.domain_name[domain.domain].domain_name_configuration[0].target_domain_name, "")
      : try(aws_api_gateway_domain_name.rest_domain_name[domain.domain].regional_domain_name, ""))
      zone_id = (var.api_type == "http"
        ? try(aws_apigatewayv2_domain_name.domain_name[domain.domain].domain_name_configuration[0].hosted_zone_id, "")
      : try(aws_api_gateway_domain_name.rest_domain_name[domain.domain].regional_zone_id, ""))
    }
  }
  description = "Targets for creating DNS records manually"
}

output "api_gateway_rest_api_id" {
  value       = aws_api_gateway_rest_api.rest_api[0].id
  description = "id of rest api"
}

output "api_gateway_rest_api_root_resource_id" {
  value       = aws_api_gateway_rest_api.rest_api[0].root_resource_id
  description = "root resource id of rest api"
}

output "api_gateway_rest_api_vpc_link_id" {
  value       = aws_api_gateway_vpc_link.gateway_vpc_link[0].id
  description = "vpc link id of rest api"
}

output "api_gateway_authorizer_id" {
  value       = aws_api_gateway_authorizer.rest_authorizer[var.custom_authorizers[0].name].id
  description = "authorizer id of rest api"
}
