# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_version = ">=1.5.0"
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

module "servers" {
  source = "github.com/hashicorp/terraform-azurerm-consul-enterprise-hvd?ref=init"

  region             = var.region
  availability_zones = var.availability_zones
  subnet_id          = var.subnet_id
  environment_name   = var.environment_name
  consul_nodes       = var.consul_nodes

  ssh_username   = var.ssh_username
  ssh_public_key = var.ssh_public_key

  consul_secrets = {
    kind = "azure-keyvault"
    azure_keyvault = {
      id = var.azure_keyvault_id
    }
  }

  consul_agent = {
    bootstrap_acls = true
    datacenter     = var.consul_datacenter
    version        = var.consul_version
  }

  snapshot_agent = {
    enabled               = true
    storage_account_name  = var.storage_account_name
    object_container_name = var.object_container_name
  }
}