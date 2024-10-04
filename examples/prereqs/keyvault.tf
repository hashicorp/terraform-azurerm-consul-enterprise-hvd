# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "azurerm_key_vault" "servers" {
  name                = "kv-servers-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.prereqs.name
  location            = azurerm_resource_group.prereqs.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                  = "standard"
  enable_rbac_authorization = true
}

resource "random_id" "gossip_key" {
  byte_length = 32
}

resource "azurerm_key_vault_secret" "servers_gossip_key" {
  depends_on = [azurerm_role_assignment.kvso]

  name         = "gossip-key"
  value        = random_id.gossip_key.b64_std
  key_vault_id = azurerm_key_vault.servers.id
}

resource "azurerm_key_vault_secret" "agent_tls_key" {
  depends_on = [azurerm_role_assignment.kvso]

  name         = "consul-agent-key"
  value        = base64encode(tls_private_key.agent_leaf.private_key_pem)
  key_vault_id = azurerm_key_vault.servers.id
  tags = {
    "file-encoding" = "base64"
  }
}

resource "azurerm_key_vault_secret" "agent_tls_cert" {
  depends_on = [azurerm_role_assignment.kvso]

  name         = "consul-agent-cert"
  value        = base64encode(tls_locally_signed_cert.leaf_cert.cert_pem)
  key_vault_id = azurerm_key_vault.servers.id
  tags = {
    "file-encoding" = "base64"
  }
}

resource "azurerm_key_vault_secret" "agent_tls_ca_cert" {
  depends_on = [azurerm_role_assignment.kvso]

  name         = "consul-ca-cert"
  value        = base64encode(tls_self_signed_cert.agent_ca.cert_pem)
  key_vault_id = azurerm_key_vault.servers.id
  tags = {
    "file-encoding" = "base64"
  }
}

resource "azurerm_key_vault_secret" "storage_account_key" {
  depends_on = [azurerm_role_assignment.kvso]

  name         = "storage-account-key"
  value        = azurerm_storage_account.cluster_snapshots.primary_access_key
  key_vault_id = azurerm_key_vault.servers.id
}

resource "azurerm_key_vault_secret" "consul_license" {
  depends_on = [azurerm_role_assignment.kvso]

  name         = "consul-license"
  value        = var.consul_license
  key_vault_id = azurerm_key_vault.servers.id
}