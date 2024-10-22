# Ubuntu | internal network load balancer (NLB) | Consul Enterprise primary

This example deploys Consul Enterprise aligned with HashiCorp Validated Design. This is the minimum configuration required to standup a highly-available Consul Enterprise cluster with:

* 3 redundancy zones each with one voter and one non-voter node
* Cloud auto-join for peer discovery
* End-to-end TLS

## Usage

To run this example, you need to execute:

```bash
$ terraform init
$ cp terraform.tfvars.example terraform.tfvars
# Update variable values
$ terraform plan
$ terraform apply
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.113 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | ~>2.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_default"></a> [default](#module\_default) | github.com/hashicorp/terraform-azurerm-consul-enterprise-hvd | init |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | (Required List(string)) List of availability zones to deploy supported resources to. Only works in select regions. | `list(string)` | n/a | yes |
| <a name="input_consul_agent"></a> [consul\_agent](#input\_consul\_agent) | Object containing the Consul Agent configuration. | <pre>object({<br/>    bootstrap_acls = optional(bool, true)<br/>    datacenter     = optional(string, "dc1")<br/>  })</pre> | n/a | yes |
| <a name="input_consul_fqdn"></a> [consul\_fqdn](#input\_consul\_fqdn) | (required string) Fully qualified domain name of the consul cluster. This name __must__ match a SAN entry in the TLS server certificate. | `string` | n/a | yes |
| <a name="input_consul_secrets"></a> [consul\_secrets](#input\_consul\_secrets) | Object containing the Azure Key Vault secrets necessary to inject Consul Agent TLS, Gossip encryption material, and ACL tokens. | <pre>object({<br/>    kind = string<br/>    azure_keyvault = optional(object({<br/>      id = optional(string)<br/>    }), {})<br/>  })</pre> | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | (required string) Unique environment name to prefix and disambiguate resources using. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (required string) Azure region for this consul deployment. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | (Required string) SSH public key to use when authenticating to VM instances. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (required string) The ID of the subnet in which resources should be deployed. | `string` | n/a | yes |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | (Required string) VNet ID where Consul resources will reside. | `string` | n/a | yes |
| <a name="input_cloud_init_config_rendered"></a> [cloud\_init\_config\_rendered](#input\_cloud\_init\_config\_rendered) | (Optional base64 string) To override the `azurerm_linux_virtual_machine_scale_set.consul.custom_data` provide a base64 rendered value from the `data.cloud_init` | `string` | `null` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | (Optional map) Map of common tags for taggable Azure resources. | `map(string)` | `{}` | no |
| <a name="input_consul_install_version"></a> [consul\_install\_version](#input\_consul\_install\_version) | (Optional string) Version of Consul to install, eg. '1.19.2+ent' | `string` | `"1.19.2+ent"` | no |
| <a name="input_consul_nodes"></a> [consul\_nodes](#input\_consul\_nodes) | (Optional number) Number of Consul instances. | `number` | `6` | no |
| <a name="input_consul_vm_size"></a> [consul\_vm\_size](#input\_consul\_vm\_size) | (Optional string) The size of VM instance to use for Consul agents. | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_create_consul_private_dns_record"></a> [create\_consul\_private\_dns\_record](#input\_create\_consul\_private\_dns\_record) | (Optional bool) Boolean to create a DNS record for consul in a private Azure DNS zone. `private_dns_zone_name` must also be provided when `true`. | `bool` | `false` | no |
| <a name="input_create_consul_public_dns_record"></a> [create\_consul\_public\_dns\_record](#input\_create\_consul\_public\_dns\_record) | (Optional bool) Boolean to create a DNS record for consul in a public Azure DNS zone. `public_dns_zone_name` must also be provided when `true`. | `bool` | `false` | no |
| <a name="input_create_lb"></a> [create\_lb](#input\_create\_lb) | (Optional bool) Boolean to create an Azure Load Balancer for Consul. | `bool` | `true` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | (Optional bool) Boolean to create a new Resource Group for this consul deployment. | `bool` | `true` | no |
| <a name="input_disk_params"></a> [disk\_params](#input\_disk\_params) | Disk parameters to use for the cluster nodes' block devices. | <pre>object({<br/>    root = object({<br/>      disk_type = optional(string, "Premium_LRS")<br/>      disk_size = optional(number, 32)<br/>    }),<br/>    data = object({<br/>      disk_type = optional(string, "Premium_LRS")<br/>      disk_size = optional(number, 1024)<br/>    })<br/>  })</pre> | <pre>{<br/>  "data": {},<br/>  "root": {}<br/>}</pre> | no |
| <a name="input_image_reference"></a> [image\_reference](#input\_image\_reference) | Azure platform image details to use for VMSS instances | <pre>object({<br/>    publisher = string,<br/>    offer     = string,<br/>    sku       = string,<br/>    version   = string<br/>  })</pre> | <pre>{<br/>  "offer": "0001-com-ubuntu-server-jammy",<br/>  "publisher": "Canonical",<br/>  "sku": "22_04-lts-gen2",<br/>  "version": "latest"<br/>}</pre> | no |
| <a name="input_load_balancer_internal"></a> [load\_balancer\_internal](#input\_load\_balancer\_internal) | (Optional bool) Whether the provisioned load balancer should be internal-facing or internet-facing. If internal facing, ensure NAT Gateway or another internet egress method has been configured in your vnet. | `bool` | `false` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | (Optional string) Name of existing private Azure DNS zone to create DNS record in. Required when `create_consul_private_dns_record` is `true`. | `string` | `null` | no |
| <a name="input_private_dns_zone_rg"></a> [private\_dns\_zone\_rg](#input\_private\_dns\_zone\_rg) | (Optional string) Name of Resource Group where `private_dns_zone_name` resides. Required when `create_consul_private_dns_record` is `true`. | `string` | `null` | no |
| <a name="input_public_dns_zone_name"></a> [public\_dns\_zone\_name](#input\_public\_dns\_zone\_name) | (Optional string) Name of existing public Azure DNS zone to create DNS record in. Required when `create_consul_public_dns_record` is `true`. | `string` | `null` | no |
| <a name="input_public_dns_zone_rg"></a> [public\_dns\_zone\_rg](#input\_public\_dns\_zone\_rg) | (Optional string) Name of Resource Group where `public_dns_zone_name` resides. Required when `create_consul_public_dns_record` is `true`. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional string) Name of Resource Group to use for Consul cluster resources | `string` | `"consul-ent-rg"` | no |
| <a name="input_snapshot_agent"></a> [snapshot\_agent](#input\_snapshot\_agent) | Configures the Consul snapshot agent to store backups to an Azure Storage Account. | <pre>object({<br/>    enabled               = bool<br/>    storage_account_name  = optional(string)<br/>    object_container_name = optional(string)<br/>    azure_environment     = optional(string, "AZURECLOUD")<br/>    interval              = optional(string, "30m")<br/>    retention             = optional(number, 336) # 1 week @ 30m interval<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_ssh_username"></a> [ssh\_username](#input\_ssh\_username) | (Optional string) Default username to add to VMSS instances. | `string` | `"azureuser"` | no |
| <a name="input_storage_account_type"></a> [storage\_account\_type](#input\_storage\_account\_type) | (Optional string) Redundancy type for the Consul Snapshot storage account. Must be one of LRS, GRS, or RAGRS. | `string` | `"GRS"` | no |
<!-- END_TF_DOCS -->
