# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  type        = string
  description = "Azure region to deploy resources into."
}

variable "consul_datacenter" {
  type        = string
  description = "Name of the Consul datacenter to deploy."
  default     = "dc1"
}

variable "consul_license" {
  type        = string
  sensitive   = true
  description = "Full text of the Consul Enterprise license to apply to the deployed cluster. Will be stored in Azure Key Vault."
}

variable "ssh_username" {
  type        = string
  description = "Username to create for the default SSH user on the bastion host."
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key to authorize for connections to the bastion host."
}

variable "ssh_ingress_cidrs" {
  type        = list(string)
  description = "List of CIDR-notation address blocks to permit inbound SSH connections for the bastion host."
}
