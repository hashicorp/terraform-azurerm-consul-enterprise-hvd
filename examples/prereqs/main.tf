# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.113"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true # dev/test environment
    }
  }
}

resource "random_string" "context" {
  length  = 5
  special = false
  lower   = true
  numeric = false
  upper   = false
}

data "azurerm_client_config" "current" {}

# Grant the current OID the User Access Administrator role on the subscription to allow custom role management.
# resource "azurerm_role_assignment" "rpc" {
#   scope                = format("/subscriptions/%s", data.azurerm_client_config.current.subscription_id)
#   role_definition_name = "User Access Administrator" # Microsoft.Authorization/roleDefinitions/write required for custom role creation
#   principal_id         = data.azurerm_client_config.current.object_id
# }

# Grant the Key Vault Secrets Officer role on the current resource group to enable publishing secret versions
resource "azurerm_role_assignment" "kvso" {
  scope                = azurerm_resource_group.prereqs.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_resource_group" "prereqs" {
  location = var.region
  name     = "rg-${local.resource_suffix}"
}

locals {
  resource_suffix = "consul-${random_string.context.result}"
}