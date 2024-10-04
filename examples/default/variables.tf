# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
variable "region" {
  type        = string
  description = "The Azure region to deploy resources to."
}
variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to deploy supported resources to. Only works in select regions."
}
variable "subnet_id" {
  type        = string
  description = "The ID of the subnet in which resources should be deployed."
}
variable "environment_name" {
  type        = string
  description = "Unique environment name to prefix and disambiguate resources using."
}
variable "consul_nodes" {
  type        = number
  description = "Number of Consul instances."
  default     = 6
}
variable "ssh_username" {
  type        = string
  description = "Default username to add to VMSS instances."
  default     = "azureuser"
}
variable "ssh_public_key" {
  type        = string
  description = "SSH public key to use when authenticating to VM instances."
}
variable "storage_account_name" {
  type        = string
  description = "The name of the Azure Storage Account where Consul snapshots will be stored."
}
variable "object_container_name" {
  type        = string
  description = "The name of the container within the Azure Storage Account used to store Consul snapshots."
}
variable "consul_datacenter" {
  type        = string
  description = "The name of the Consul datacenter."
}
variable "consul_version" {
  type        = string
  description = "The version of Consul to be deployed."
}
variable "azure_keyvault_id" {
  type        = string
  description = "The ID of the Azure Key Vault for reading the installation secrets."
}