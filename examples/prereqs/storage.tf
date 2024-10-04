# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "azurerm_storage_account" "cluster_snapshots" {
  name                     = "consul${random_string.context.result}"
  resource_group_name      = azurerm_resource_group.prereqs.name
  location                 = var.region
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "ZRS"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "consul_snapshots" {
  name                  = "${var.consul_datacenter}-snapshots"
  storage_account_name  = azurerm_storage_account.cluster_snapshots.name
  container_access_type = "private"
}