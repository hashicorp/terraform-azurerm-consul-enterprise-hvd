# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

locals {
  cloudinit_config_rendered = var.cloud_init_config_rendered == null ? data.cloudinit_config.consul.rendered : var.cloud_init_config_rendered
  # avoiddep cycle between the VMSS and script template while staying DRY
  vmss_name = "${var.environment_name}-consul-agents"
}
resource "azurerm_linux_virtual_machine_scale_set" "consul" {
  name                = local.vmss_name
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  tags = merge(
    { "Name" = "${local.vmss_name}" },
    var.common_tags
  )
  instances     = var.consul_nodes
  sku           = var.consul_vm_size
  overprovision = false
  upgrade_mode  = "Manual"

  zones = var.availability_zones
  # zone_balance = false

  admin_username                  = var.ssh_username
  disable_password_authentication = true
  admin_ssh_key {
    public_key = var.ssh_public_key
    username   = var.ssh_username
  }

  source_image_reference {
    publisher = var.image_reference.publisher
    offer     = var.image_reference.offer
    sku       = var.image_reference.sku
    version   = var.image_reference.version
  }

  custom_data = local.cloudinit_config_rendered
  os_disk {
    caching                   = "ReadWrite"
    storage_account_type      = var.disk_params.root.disk_type
    disk_size_gb              = var.disk_params.root.disk_size
    write_accelerator_enabled = false # default ; TODO
  }

  data_disk {
    caching                   = "None"
    create_option             = "Empty"
    disk_size_gb              = var.disk_params.data.disk_size
    storage_account_type      = var.disk_params.data.disk_type
    lun                       = 10
    write_accelerator_enabled = false # default ; TODO
  }

  network_interface {
    name                          = "${var.environment_name}-consul-net"
    primary                       = true
    enable_accelerated_networking = false # default ; TODO
    ip_configuration {
      name                                   = "${var.environment_name}-consul-net-ip"
      primary                                = true
      subnet_id                              = var.subnet_id
      application_security_group_ids         = [azurerm_application_security_group.consul_agents.id]
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.consul_servers[0].id]
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.consul_iam.id]
  }

  boot_diagnostics {
    storage_account_uri = null # uses managed storage account
  }

  depends_on = [azurerm_role_assignment.consul_reader]
}


