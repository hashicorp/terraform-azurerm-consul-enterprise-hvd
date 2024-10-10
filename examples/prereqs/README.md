# Consul Enterprise on Azure Virtual Machines - Prerequisite Example Module

This module contains a baseline reference for the prerequisite resources needed to deploy the Consul Enterprise on Azure Virtual Machines Terraform module for HashiCorp Validated Designs.

Note that the resources deployed in the 'prereqs' module are **NOT** intended for production use, and only serve as a baseline example of the necessary resources and expected format for conveying those resources to the downstream HVD deployment module.

The outputs of this module are intended to be used as input variables in the HVD module. Please see the root module in the `examples/consul` directory for guidance on referencing these variables from remote state.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.113 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.6 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~>4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.116.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_security_group.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_security_group) | resource |
| [azurerm_key_vault.servers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.agent_tls_ca_cert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.agent_tls_cert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.agent_tls_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.consul_license](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.servers_gossip_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.storage_account_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_linux_virtual_machine.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_application_security_group_association.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_application_security_group_association) | resource |
| [azurerm_network_security_group.net](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.bastion_ingress_ssh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.prereqs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.kvso](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.cluster_snapshots](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.consul_snapshots](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_subnet.net_lan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.net_wan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.net_lan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.net_wan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.net](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_id.gossip_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_string.context](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_cert_request.agent_leaf](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request) | resource |
| [tls_locally_signed_cert.leaf_cert](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/locally_signed_cert) | resource |
| [tls_private_key.agent_ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_private_key.agent_leaf](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.agent_ca](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_consul_datacenter"></a> [consul\_datacenter](#input\_consul\_datacenter) | Name of the Consul datacenter to deploy. | `string` | `"dc1"` | no |
| <a name="input_consul_license"></a> [consul\_license](#input\_consul\_license) | Full text of the Consul Enterprise license to apply to the deployed cluster. Will be stored in Azure Key Vault. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Azure region to deploy resources into. | `string` | n/a | yes |
| <a name="input_ssh_ingress_cidrs"></a> [ssh\_ingress\_cidrs](#input\_ssh\_ingress\_cidrs) | List of CIDR-notation address blocks to permit inbound SSH connections for the bastion host. | `list(string)` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key to authorize for connections to the bastion host. | `string` | n/a | yes |
| <a name="input_ssh_username"></a> [ssh\_username](#input\_ssh\_username) | Username to create for the default SSH user on the bastion host. | `string` | `"azureuser"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_datacenter"></a> [datacenter](#output\_datacenter) | Name of the Consul datacenter to deploy in the downstream module. |
| <a name="output_key_vault_servers_id"></a> [key\_vault\_servers\_id](#output\_key\_vault\_servers\_id) | ID of the created Azure Key Vault. |
| <a name="output_lan_subnet_id"></a> [lan\_subnet\_id](#output\_lan\_subnet\_id) | ID of the generated 'LAN' subnet. |
| <a name="output_object_container_name"></a> [object\_container\_name](#output\_object\_container\_name) | Name of the object container within the generated storage account. |
| <a name="output_region"></a> [region](#output\_region) | Azure region in which resources were deployed |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | SSH public key deployed to the bastion instance. May be used for server VMs in the downstream module. |
| <a name="output_ssh_username"></a> [ssh\_username](#output\_ssh\_username) | SSH username deployed to the bastion instance. May be used for server VMs in the downstream module. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Description of the storage account, used by the downstream module for snapshot storage. |
| <a name="output_wan_subnet_id"></a> [wan\_subnet\_id](#output\_wan\_subnet\_id) | ID of the generated 'WAN' subnet. |
<!-- END_TF_DOCS -->
