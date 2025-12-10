# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_version = "~>1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.113"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~>2.3"
    }
  }
}

provider "azurerm" {
  features {
    virtual_machine_scale_set {
      force_delete                 = true
      roll_instances_when_required = false
    }
  }
}

module "default" {
  source = "github.com/hashicorp/terraform-azurerm-consul-enterprise-hvd?ref=init"

  region                 = var.region
  availability_zones     = var.availability_zones
  vnet_id                = var.vnet_id
  subnet_id              = var.subnet_id
  environment_name       = var.environment_name
  consul_fqdn            = var.consul_fqdn
  consul_nodes           = var.consul_nodes
  consul_install_version = var.consul_install_version
  ssh_username           = var.ssh_username
  ssh_public_key         = var.ssh_public_key

  consul_secrets = var.consul_secrets
  consul_agent   = var.consul_agent
  snapshot_agent = var.snapshot_agent
}
