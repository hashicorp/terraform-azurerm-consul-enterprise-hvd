# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "azurerm_user_assigned_identity" "consul_iam" {
  name                = var.environment_name
  resource_group_name = local.resource_group_name
  location            = var.region
}

// All Agents
resource "azurerm_role_assignment" "consul_reader" {
  scope                = local.resource_group_id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.consul_iam.principal_id
}

resource "azurerm_role_assignment" "consul_kvso" {
  scope                = var.consul_secrets.azure_keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_user_assigned_identity.consul_iam.principal_id
}
