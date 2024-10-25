# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_version = "~> 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.113.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">=2.3.2"
    }

  }
}
