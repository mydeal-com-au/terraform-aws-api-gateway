# terraform-aws-api-gateway

[![Lint Status](https://github.com/DNXLabs/terraform-aws-template/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-template/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-template)](https://github.com/DNXLabs/terraform-aws-template/blob/master/LICENSE)

<!--- BEGIN_TF_DOCS --->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_ips | List of allowed IP's to access the API | `list(any)` | `[]` | no |
| api\_description | Description for the API | `string` | `""` | no |
| api\_type | Type of the API. http or rest | `string` | n/a | yes |
| create\_api\_key | Boolean variable that's evaluate the creation of an api key | `bool` | `false` | no |
| create\_dns\_record | When enabled, creates the route53 record for the custom domain | `bool` | `true` | no |
| create\_vpc\_link | n/a | `bool` | `false` | no |
| custom\_authorizers | Custom authorizer variables | <pre>list(object({<br>    name                          = string<br>    custom_authorizer_lambda_code = string<br>  }))</pre> | `[]` | no |
| domains | Domains to be created for the API GATEWAY | <pre>list(object({<br>    domain            = string<br>    api_route_mapping = string<br>    zone_name         = string<br>  }))</pre> | `[]` | no |
| environment\_name | Name of the environment | `string` | `""` | no |
| name | Api Gateway name | `string` | `""` | no |
| open\_api\_file | Path to the open api specification | `string` | `""` | no |
| routes | Routes to be created in the API | <pre>list(object({<br>    name             = string<br>    method           = string<br>    integration_type = string<br>    integration_uri  = string<br>    route_mapping    = string<br>    path_parameters  = list(string)<br>    connection_type  = string<br>  }))</pre> | `[]` | no |
| tags | n/a | `map` | `{}` | no |
| target\_arn | Target ARN's to the vpc link | `string` | `""` | no |
| vpc\_link\_target\_id | ARN of the resource to attach for the VPC link load balancer target | `string` | `""` | no |
| vpc\_link\_target\_port | TCP Port of the resource to attach for the VPC link load balancer target | `number` | `443` | no |

## Outputs

| Name | Description |
|------|-------------|
| api\_gateway\_domain\_targets | Targets for creating DNS records manually |

<!--- END_TF_DOCS --->

## Authors

Module managed by [DNX Solutions](https://github.com/DNXLabs).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/DNXLabs/terraform-aws-template/blob/master/LICENSE) for full details.