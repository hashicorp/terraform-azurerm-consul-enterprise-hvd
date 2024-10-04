# Default Example

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.113 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | ~>2.3 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_servers"></a> [servers](#module\_servers) | github.com/hashicorp-services/terraform-azurerm-consul-enterprise | main |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones to deploy supported resources to. Only works in select regions. | `list(string)` | n/a | yes |
| <a name="input_azure_keyvault_id"></a> [azure\_keyvault\_id](#input\_azure\_keyvault\_id) | The ID of the Azure Key Vault for reading the installation secrets. | `string` | n/a | yes |
| <a name="input_consul_datacenter"></a> [consul\_datacenter](#input\_consul\_datacenter) | The name of the Consul datacenter. | `string` | n/a | yes |
| <a name="input_consul_nodes"></a> [consul\_nodes](#input\_consul\_nodes) | Number of Consul instances. | `number` | `6` | no |
| <a name="input_consul_version"></a> [consul\_version](#input\_consul\_version) | The version of Consul to be deployed. | `string` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Unique environment name to prefix and disambiguate resources using. | `string` | n/a | yes |
| <a name="input_object_container_name"></a> [object\_container\_name](#input\_object\_container\_name) | The name of the container within the Azure Storage Account used to store Consul snapshots. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The Azure region to deploy resources to. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key to use when authenticating to VM instances. | `string` | n/a | yes |
| <a name="input_ssh_username"></a> [ssh\_username](#input\_ssh\_username) | Default username to add to VMSS instances. | `string` | `"azureuser"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the Azure Storage Account where Consul snapshots will be stored. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet in which resources should be deployed. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->