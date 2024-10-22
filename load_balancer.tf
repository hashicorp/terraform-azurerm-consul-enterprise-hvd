# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "azurerm_public_ip" "consul_lb" {
  count = var.create_lb == true && var.load_balancer_internal == false ? 1 : 0

  name                = "${var.environment_name}-lb"
  location            = var.region
  zones               = var.availability_zones
  sku                 = "Standard"
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_lb" "consul" {
  count               = var.create_lb == true ? 1 : 0
  name                = "${var.environment_name}-consul"
  location            = var.region
  resource_group_name = local.resource_group_name
  sku                 = "Standard"

  dynamic "frontend_ip_configuration" {
    for_each = var.load_balancer_internal ? [1] : []
    content {
      name                          = "${var.environment_name}-consul-lb-ip"
      subnet_id                     = var.subnet_id
      private_ip_address_allocation = "Dynamic"
      zones                         = var.availability_zones
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.load_balancer_internal ? [] : [1]
    content {
      name                 = "${var.environment_name}-consul-lb-ip"
      public_ip_address_id = azurerm_public_ip.consul_lb[0].id
    }
  }
}

resource "azurerm_lb_backend_address_pool" "consul_servers" {
  count           = var.create_lb == true ? 1 : 0
  name            = "${var.environment_name}-consul-servers"
  loadbalancer_id = azurerm_lb.consul[0].id
}

resource "azurerm_lb_probe" "consul_health" {
  count               = var.create_lb == true ? 1 : 0
  name                = "${var.environment_name}-consul-probe"
  loadbalancer_id     = azurerm_lb.consul[0].id
  protocol            = "Https"
  port                = 8501
  request_path        = "/v1/status/leader"
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "consul_tcp" {
  count                          = var.create_lb == true ? 1 : 0
  name                           = "${var.environment_name}-consul-tcp"
  loadbalancer_id                = azurerm_lb.consul[0].id
  frontend_ip_configuration_name = azurerm_lb.consul[0].frontend_ip_configuration[0].name
  protocol                       = "Tcp"
  frontend_port                  = 8501
  backend_port                   = 8501
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.consul_servers[0].id]
  probe_id                       = azurerm_lb_probe.consul_health[0].id
}
