locals {
  os_image_map = {
    redhat8    = { publisher = "RedHat", offer = "RHEL" }
    redhat9    = { publisher = "RedHat", offer = "RHEL" }
    ubuntu2204 = { publisher = "Canonical", offer = "0001-com-ubuntu-server-jammy" }
    ubuntu2404 = { publisher = "Canonical", offer = "ubuntu-24_04-lts" }
  }

  vm_image_publisher = local.os_image_map[var.vm_os_image].publisher
  vm_image_offer     = local.os_image_map[var.vm_os_image].offer
  vm_image_sku = (
    var.vm_os_image == "redhat8" ? "810-gen2" :
    var.vm_os_image == "redhat9" ? "95_gen2" :
    var.vm_os_image == "ubuntu2204" ? "22_04-lts-gen2" :
    var.vm_os_image == "ubuntu2404" ? "ubuntu-pro" : null
  )
}

#------------------------------------------------------------------------------
# Custom VM image lookup
#------------------------------------------------------------------------------
data "azurerm_image" "custom" {
  count = var.vm_custom_image_name == null ? 0 : 1

  name                = var.vm_custom_image_name
  resource_group_name = var.vm_custom_image_rg_name
}

#------------------------------------------------------------------------------
# Latest OS image lookup
#------------------------------------------------------------------------------
data "azurerm_platform_image" "latest_os_image" {
  location  = var.region
  publisher = local.vm_image_publisher
  offer     = local.vm_image_offer
  sku       = local.vm_image_sku
}
