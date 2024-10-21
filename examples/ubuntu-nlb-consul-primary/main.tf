# Copyright (c) HashiCorp, Inc.
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
    random = {
      source  = "hashicorp/random"
      version = "~>3.6"
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

# State output from the 'prereqs' upstream module. Configure as appropriate for your state storage backend.
data "terraform_remote_state" "prereqs" {
  backend = "local"

  config = {
    path = "../prereqs/terraform.tfstate"
  }
}

module "servers" {
  source = "../../"

  region             = var.region
  availability_zones = var.availability_zones
  subnet_id          = var.subnet_id
  environment_name   = var.environment_name
  consul_nodes       = var.consul_nodes # 3 Availability Zones * 2 nodes per zone

  ssh_public_key = var.ssh_public_key

  consul_secrets = var.consul_secrets

  consul_agent = var.consul_agent

  snapshot_agent = var.snapshot_agent
}
