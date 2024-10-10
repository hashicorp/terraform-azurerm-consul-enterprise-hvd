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

  region             = data.terraform_remote_state.prereqs.outputs.region
  availability_zones = ["1", "2", "3"]
  subnet_id          = data.terraform_remote_state.prereqs.outputs.lan_subnet_id
  environment_name   = "test"
  consul_nodes       = 6 # 3 Availability Zones * 2 nodes per zone

  ssh_username   = data.terraform_remote_state.prereqs.outputs.ssh_username
  ssh_public_key = data.terraform_remote_state.prereqs.outputs.ssh_public_key

  consul_secrets = {
    kind = "azure-keyvault"
    azure_keyvault = {
      id = data.terraform_remote_state.prereqs.outputs.key_vault_servers_id
    }
  }

  consul_agent = {
    bootstrap_acls = true
    datacenter     = data.terraform_remote_state.prereqs.outputs.datacenter
    version        = "1.19.2+ent"
  }

  snapshot_agent = {
    enabled               = true
    storage_account_name  = data.terraform_remote_state.prereqs.outputs.storage_account_name
    object_container_name = data.terraform_remote_state.prereqs.outputs.object_container_name
  }
}
