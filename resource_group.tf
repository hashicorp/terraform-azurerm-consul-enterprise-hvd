# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "azurerm_resource_group" "consul" {
  count = var.create_resource_group == true ? 1 : 0

  name     = var.resource_group_name
  location = var.region

  tags = merge(
    { "Name" = var.resource_group_name },
    var.common_tags
  )
}

data "azurerm_resource_group" "consul" {
  count = var.create_resource_group == true ? 0 : 1

  name = var.resource_group_name
}
