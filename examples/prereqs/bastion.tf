# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Bastion Public IP
#------------------------------------------------------------------------------
resource "azurerm_public_ip" "bastion" {
  name                = "bastion-public-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.prereqs.name
  location            = azurerm_resource_group.prereqs.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

#------------------------------------------------------------------------------
# Bastion Network Interface
#------------------------------------------------------------------------------
resource "azurerm_network_interface" "bastion" {
  name                = "bastion-nic-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.prereqs.name
  location            = azurerm_resource_group.prereqs.location

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.net_wan.id
    public_ip_address_id          = azurerm_public_ip.bastion.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_application_security_group_association" "example" {
  network_interface_id          = azurerm_network_interface.bastion.id
  application_security_group_id = azurerm_application_security_group.bastion.id
}

#------------------------------------------------------------------------------
# VM
#------------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "bastion" {
  name                = "bastion-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.prereqs.name
  location            = azurerm_resource_group.prereqs.location
  size                = "Standard_B1s"
  admin_username      = var.ssh_username

  network_interface_ids = [
    azurerm_network_interface.bastion.id
  ]

  admin_ssh_key {
    username   = var.ssh_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}