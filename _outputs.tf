output "api_gateway_domain_targets" {
  value       = { for domain in var.domains : domain.domain =>
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
