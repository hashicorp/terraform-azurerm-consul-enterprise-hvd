# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "azurerm_application_security_group" "consul_agents" {
  location            = var.region
  name                = "asg-${var.environment_name}"
  resource_group_name = azurerm_resource_group.consul.name
}
