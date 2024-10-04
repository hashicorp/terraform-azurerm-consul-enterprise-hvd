# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "region" {
  description = "Azure region in which resources were deployed"
  value       = var.region
}

output "datacenter" {
  description = "Name of the Consul datacenter to deploy in the downstream module."
  value       = var.consul_datacenter
}

output "key_vault_servers_id" {
  description = "ID of the created Azure Key Vault."
  value       = azurerm_key_vault.servers.id
}

output "lan_subnet_id" {
  description = "ID of the generated 'LAN' subnet."
  value       = azurerm_subnet.net_lan.id
}

output "wan_subnet_id" {
  description = "ID of the generated 'WAN' subnet."
  value       = azurerm_subnet.net_wan.id
}

output "ssh_username" {
  description = "SSH username deployed to the bastion instance. May be used for server VMs in the downstream module."
  value       = var.ssh_username
}

output "ssh_public_key" {
  description = "SSH public key deployed to the bastion instance. May be used for server VMs in the downstream module."
  value       = var.ssh_public_key
}

output "storage_account_name" {
  description = "Description of the storage account, used by the downstream module for snapshot storage."
  value       = azurerm_storage_account.cluster_snapshots.name
}

output "object_container_name" {
  description = "Name of the object container within the generated storage account."
  value       = azurerm_storage_container.consul_snapshots.name
}

output "ssh_public_ip" {
  description = "Public IP of the bastion host for SSH access."
  value       = azurerm_public_ip.bastion.ip_address
}