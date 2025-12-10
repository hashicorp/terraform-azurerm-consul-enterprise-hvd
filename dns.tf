# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# DNS Zone lookup
#------------------------------------------------------------------------------
data "azurerm_dns_zone" "consul" {
  count = var.create_consul_public_dns_record == true && var.public_dns_zone_name != null ? 1 : 0

  name                = var.public_dns_zone_name
  resource_group_name = var.public_dns_zone_rg
}

data "azurerm_private_dns_zone" "consul" {
  count = var.create_consul_private_dns_record == true && var.private_dns_zone_name != null ? 1 : 0

  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_rg
}

#------------------------------------------------------------------------------
# DNS A Record
#------------------------------------------------------------------------------
resource "azurerm_dns_a_record" "consul" {
  count = var.create_consul_public_dns_record == true && var.public_dns_zone_name != null && var.create_lb == true ? 1 : 0

  name                = local.consul_hostname_public
  resource_group_name = var.public_dns_zone_rg
  zone_name           = data.azurerm_dns_zone.consul[0].name
  ttl                 = 300
  records             = var.load_balancer_internal == true ? [azurerm_lb.consul[0].private_ip_address] : null
  target_resource_id  = var.load_balancer_internal == false ? azurerm_public_ip.consul_lb[0].id : null
  tags                = var.common_tags
}

resource "azurerm_private_dns_a_record" "consul" {
  count = var.create_consul_private_dns_record == true && var.private_dns_zone_name != null ? 1 : 0

  name                = local.consul_hostname_private
  resource_group_name = var.private_dns_zone_rg
  zone_name           = data.azurerm_private_dns_zone.consul[0].name
  ttl                 = 300
  records             = var.load_balancer_internal == true ? [azurerm_lb.consul[0].private_ip_address] : null
  tags                = var.common_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "consul" {
  count = var.create_consul_private_dns_record == true && var.private_dns_zone_name != null ? 1 : 0

  name                  = "${var.environment_name}-consul-priv-dns-zone-vnet-link"
  resource_group_name   = var.private_dns_zone_rg
  private_dns_zone_name = data.azurerm_private_dns_zone.consul[0].name
  virtual_network_id    = var.vnet_id
  tags                  = var.common_tags
}
