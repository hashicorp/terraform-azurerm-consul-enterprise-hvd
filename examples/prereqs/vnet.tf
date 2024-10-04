# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "azurerm_virtual_network" "net" {
  name                = "vn-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.prereqs.name
  location            = azurerm_resource_group.prereqs.location

  address_space = ["10.0.100.0/24", "172.16.0.0/16"] # wan, lan
}

resource "azurerm_subnet" "net_wan" {
  name                 = "wan"
  resource_group_name  = azurerm_resource_group.prereqs.name
  virtual_network_name = azurerm_virtual_network.net.name
  address_prefixes     = ["10.0.100.0/24"]
}

resource "azurerm_subnet" "net_lan" {
  name                 = "lan"
  resource_group_name  = azurerm_resource_group.prereqs.name
  virtual_network_name = azurerm_virtual_network.net.name
  address_prefixes     = ["172.16.0.0/17"]
}

resource "azurerm_network_security_group" "net" {
  name                = "nsg-default-group"
  resource_group_name = azurerm_resource_group.prereqs.name
  location            = azurerm_resource_group.prereqs.location
}

resource "azurerm_subnet_network_security_group_association" "net_wan" {
  subnet_id                 = azurerm_subnet.net_wan.id
  network_security_group_id = azurerm_network_security_group.net.id
}

resource "azurerm_subnet_network_security_group_association" "net_lan" {
  subnet_id                 = azurerm_subnet.net_lan.id
  network_security_group_id = azurerm_network_security_group.net.id
}

resource "azurerm_application_security_group" "bastion" {
  location            = var.region
  name                = "asg-bastion-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.prereqs.name
}

resource "azurerm_network_security_rule" "bastion_ingress_ssh" {
  name                                       = "allow-bastion-ssh"
  resource_group_name                        = azurerm_resource_group.prereqs.name
  network_security_group_name                = azurerm_network_security_group.net.name
  description                                = "Allow TCP/22 (SSH) inbound to the bastion host from specified CIDR ranges."
  priority                                   = 1001
  direction                                  = "Inbound"
  access                                     = "Allow"
  protocol                                   = "Tcp"
  source_port_range                          = "*"
  destination_port_range                     = 22
  source_address_prefixes                    = var.ssh_ingress_cidrs
  destination_application_security_group_ids = [azurerm_application_security_group.bastion.id]
}
