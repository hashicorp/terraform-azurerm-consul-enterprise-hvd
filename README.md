# Consul Enterprise HVD on Azure VMs

Terraform module aligned with HashiCorp Validated Designs (HVD) to deploy Consul Enterprise on Microsoft Azure using Azure Virtual Machines.

## Prerequisites

This module requires the following resources to already be deployed to an Azure subscription:

- Azure Virtual Network
- Azure Key Vault
- Azure Storage Account
- SSH Public Key
- [Consul Enterprise License](#secrets-management)
- [Gossip Encryption Key](#secrets-management)
- [Agent PKI - CA Cert](#secrets-management)
- [Agent PKI - Leaf Cert](#secrets-management)
- [Agent PKI - Leaf Key](#secrets-management)

## Examples

The `examples/prereqs` directory contains a reference deployment of the aforementioned prerequisite resources.

The `examples/consul` directory contains a reference root-level module which uses the `prereqs` state output to deploy this module.

## TLS

The certificate authority and leaf certificates for Consul server agents are expected to be generated via an outside authority (e.g. Vault, Consul CLI, Terraform TLS Provider, etc.).

Server certificates are expected to have the following Subject Alternate Names:

- `server.<dc>.consul` (Required - Should also be certificate CN)
- `localhost` (Optional - For local CLI/API access)
- `127.0.0.1` (Optional - See above)

Server certificates are **required** to define the following key usage values:

- `Digital Signature`
- `Key Encipherment`
- `Server Authentication`
- `Client Authentication`

## Secrets management

Use of Azure Key Vault is required for this module. Secrets are expected to conform to the following naming conventions:

| Key | Description |
|-----|-------------|
| `gossip-key` | Encryption key to use for Serf Gossip traffic. May be generated via `consul keygen` |
| `storage-account-key` | Azure storage account key, provided to the snapshot agent process for periodic backup |
| `consul-agent-cert` | Base64-encoded PEM certificate for server TLS |
| `consul-agent-key` | Base64-encoded PEM private key for the agent's TLS certificate |
| `consul-ca-cert` | Base64-encoded PEM certificate of `consul-agent-cert`'s signing certificate authority |
| `consul-license` | Consul Enterprise license |

## Deployment

Upon initial deployment, Consul servers will auto-join and form a fresh cluster. The ACL system is always enabled in deny-by-default mode. When `consul_agent.bootstrap_acls` is true (the default setting), the cluster is bootstrapped with basic policies and ACL tokens generated. An operator, or other automation, should then connect to the cluster to perform any post-deployment customization.

Azure Key Vault is required with this module. Review the [secrets management](#secrets-management) section for further information.

## ACL Bootstrapping

When the `consul_agent.bootstrap_acls` parameter is set to true cloud-init will attempt to:

1. Bootstrap the Consul ACL system, creating the initial management token
1. Write the management token to Azure Key Vault (via the `mgmt-token` secret)
1. Apply a minimal policy set:
    - Anonymous catalog read policy
    - Server agent registration policy
1. Create an ACL token for server agent registration
1. Write the server registration to Azure Key Vault (via the `agent-token` secret)
1. Apply the written agent token to the running servers

## VM image

This module performs all required software installation and configuration at boot time via cloud-init. Currently, a dpkg-based Linux distribution with the `apt` suite is expected. All testing is performed against Ubuntu 22.04 LTS.

Upon deployment, the following packages are installed:

- [Consul Enterprise](https://releases.hashicorp.com/consul/)
- Azure CLI
- unzip
- jq

### VM image reference

The VM Scale Set will attempt to use an Azure Platform Image for its base deployment. By default, this is configured to use Ubuntu 22.04 LTS. Alternative images may be provided by overriding the `image_reference` variable. See the [Azure Documentation](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage) for more information on discovering platform images.

## Module support

This open source software is maintained by the HashiCorp Technical Field Organization, independently of our enterprise products. While our Support Engineering team provides dedicated support for our enterprise offerings, this open source software is not included.

- For help using this open source software, please engage your account team.
- To report bugs/issues with this open source software, please open them directly against this code repository using the GitHub issues feature.

Please note that there is no official Service Level Agreement (SLA) for support of this software as a HashiCorp customer. This software falls under the definition of Community Software/Versions in your Agreement. We appreciate your understanding and collaboration in improving our open source projects.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.113.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >=2.3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.113.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | >=2.3.2 |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_security_group.consul_agents](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_security_group) | resource |
| [azurerm_dns_a_record.consul](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record) | resource |
| [azurerm_lb.consul](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.consul_servers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.consul_health](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.consul_tcp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_linux_virtual_machine_scale_set.consul](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_private_dns_a_record.consul](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone_virtual_network_link.consul](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_public_ip.consul_lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.consul](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.consul_kvso](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.consul_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.consul_iam](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_dns_zone.consul](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/dns_zone) | data source |
| [azurerm_private_dns_zone.consul](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_dns_zone) | data source |
| [azurerm_resource_group.consul](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [cloudinit_config.consul](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

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
| <a name="input_cloud_init_config_rendered"></a> [cloud\_init\_config\_rendered](#input\_cloud\_init\_config\_rendered) | (Optional base64 string) To override the `azurerm_linux_virtual_machine_scale_set.consul.custom_data` provide a base64gzip rendered value from the `data.cloud_init` | `string` | `null` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | (Optional map) Map of common tags for taggable Azure resources. | `map(string)` | `{}` | no |
| <a name="input_consul_config_template"></a> [consul\_config\_template](#input\_consul\_config\_template) | (Optional string) name of `*.tpl` file in the `./templates` folder local to the module decleration, to replace the root `server.hcl.tpl` | `string` | `null` | no |
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
