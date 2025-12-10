# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

locals {
  resource_group_name = (
    var.create_resource_group == true ?
    azurerm_resource_group.consul[0].name : data.azurerm_resource_group.consul[0].name
  )
  resource_group_location = (
    var.create_resource_group == true ?
    azurerm_resource_group.consul[0].location : data.azurerm_resource_group.consul[0].location
  )
  resource_group_id = (
    var.create_resource_group == true ?
    azurerm_resource_group.consul[0].id : data.azurerm_resource_group.consul[0].id
  )
  consul_hostname_public  = var.create_consul_public_dns_record == true && var.public_dns_zone_name != null ? trimsuffix(substr(var.consul_fqdn, 0, length(var.consul_fqdn) - length(var.public_dns_zone_name) - 1), ".") : var.consul_fqdn
  consul_hostname_private = var.create_consul_private_dns_record == true && var.private_dns_zone_name != null ? trim(split(var.private_dns_zone_name, var.consul_fqdn)[0], ".") : var.consul_fqdn
}
