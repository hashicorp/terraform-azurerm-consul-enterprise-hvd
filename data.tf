# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "azurerm_client_config" "current" {}

data "cloudinit_config" "consul" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/jinja2"
    content      = templatefile("${path.module}/templates/00_init.yaml", local.install_vars)
  }

  part {
    content_type = "x-shellscript"
    content      = templatefile("${path.module}/templates/install_consul.sh.tpl", { consul_version = var.consul_install_version })
  }

  part {
    content_type = "x-shellscript"
    content      = templatefile("${path.module}/templates/install_consul_config.sh.tpl", local.install_vars)
  }
  part {
    content_type = "x-shellscript"
    content      = templatefile("${path.module}/templates/install_consul_secrets.sh.tpl", local.install_vars)
  }
  part {
    content_type = "x-shellscript"
    content      = templatefile("${path.module}/templates/install_systemd_config.sh.tpl", local.install_vars)
  }
  dynamic "part" {
    for_each = var.consul_agent.bootstrap_acls ? [1] : []
    content {
      content_type = "x-shellscript"
      content      = templatefile("${path.module}/templates/install_consul_bootstrap_keyvault.sh.tpl", local.install_vars)
    }
  }

  dynamic "part" {
    for_each = var.snapshot_agent.enabled ? [1] : []
    content {
      content_type = "x-shellscript"
      content      = templatefile("${path.module}/templates/install_snapshot_agent.sh.tpl", local.install_vars)
    }
  }
}

locals {
  install_vars = {
    consul_version = var.consul_install_version
    consul_agent   = var.consul_agent
    consul_config  = templatefile("${path.module}/templates/server.hcl.tpl", local.config_vars)
    consul_secrets = var.consul_secrets
    snapshot_agent = var.snapshot_agent
  }

  config_vars = {
    consul_datacenter = var.consul_agent.datacenter
    subscription_id   = data.azurerm_client_config.current.subscription_id
    resource_group    = local.resource_group_name
    vm_scale_set      = local.vmss_name
    node_count        = var.consul_nodes
  }
}
