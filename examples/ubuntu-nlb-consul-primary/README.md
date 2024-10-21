# Consul Enterprise on Azure Virtual Machines - Root Example Module

This directory contains a reference implementation of a root-level module which deploys the Consul Enterprise on Azure Virtual Machines Terraform module for HashiCorp Validated Designs.

The use of the accompanying `examples/prereqs` module is expected, as the `prereqs` module's outputs are loaded via remote state resource and passed as inputs to the downstream `terraform-azurerm-consul-enterprise` module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.113 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | ~>2.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_servers"></a> [servers](#module\_servers) | github.com/hashicorp-services/terraform-azurerm-consul-enterprise | main |

## Resources

| Name | Type |
|------|------|
| [terraform_remote_state.prereqs](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
