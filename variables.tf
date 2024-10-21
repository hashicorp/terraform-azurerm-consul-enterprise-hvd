#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------
variable "resource_group_name" {
  type        = string
  description = "Name of Resource Group to use for Consul cluster resources"
  default     = "consul-ent-rg"
}

variable "create_resource_group" {
  type        = bool
  description = "Boolean to create a new Resource Group for this consul deployment."
  default     = true
}

variable "region" {
  type        = string
  description = "Azure region for this consul deployment."

  validation {
    condition     = contains(["eastus", "westus", "centralus", "eastus2", "westus2", "westus3", "westeurope", "northeurope", "southeastasia", "eastasia", "australiaeast", "australiasoutheast", "uksouth", "ukwest", "canadacentral", "canadaeast", "southindia", "centralindia", "westindia", "japaneast", "japanwest", "koreacentral", "koreasouth", "francecentral", "southafricanorth", "uaenorth", "brazilsouth", "switzerlandnorth", "germanywestcentral", "norwayeast", "westcentralus"], var.region)
    error_message = "The location specified is not a valid Azure region."
  }
}

variable "environment_name" {
  type        = string
  description = "Unique environment name to prefix and disambiguate resources using."
}
variable "common_tags" {
  type        = map(string)
  description = "Map of common tags for taggable Azure resources."
  default     = {}
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to deploy supported resources to. Only works in select regions."
}

#------------------------------------------------------------------------------
# Consul
#------------------------------------------------------------------------------
variable "consul_install_version" {
  type        = string
  description = "Version of Consul to install, eg. '1.19.2+ent'"
  default     = "1.19.2+ent"
  # validation {
  #   condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\+ent$", var.consul_install_version))
  #   error_message = "consul_agent.version must be an Enterprise release in the format #.#.#+ent"
  # }
}

variable "consul_agent" {
  type = object({
    bootstrap_acls = optional(bool, true)
    datacenter     = optional(string, "dc1")
  })
  description = "Object containing the Consul Agent configuration."
}

variable "snapshot_agent" {
  type = object({
    enabled               = bool
    storage_account_name  = optional(string)
    object_container_name = optional(string)
    azure_environment     = optional(string, "AZURECLOUD")
    interval              = optional(string, "30m")
    retention             = optional(number, 336) # 1 week @ 30m interval
  })

  description = "Configures the Consul snapshot agent to store backups to an Azure Storage Account."
  default     = { enabled = false }
  sensitive   = true

  validation {
    condition     = var.snapshot_agent.enabled == (var.snapshot_agent.storage_account_name != null || var.snapshot_agent.object_container_name != null)
    error_message = "If snapshot_agent.enabled == true, the storage_account_name and object_container_name values must be set. If snapshot_agent.enabled == false, they must be left null."
  }

  validation {
    condition     = contains(["AZURECLOUD", "AZUREUSGOVERNMENT", "AZURECHINACLOUD", "AZUREGERMANCLOUD"], var.snapshot_agent.azure_environment)
    error_message = "snapshot_agent.azure_environment must be one of: AZURECLOUD, AZUREUSGOVERNMENT, AZURECHINACLOUD, AZUREGERMANCLOUD"
  }
}

variable "consul_nodes" {
  type        = number
  description = "Number of Consul instances."
  default     = 6
}

variable "consul_secrets" {
  type = object({
    kind = string
    azure_keyvault = optional(object({
      id = optional(string)
    }), {})
  })
  description = "Object containing the Azure Key Vault secrets necessary to inject Consul Agent TLS, Gossip encryption material, and ACL tokens."

  validation {
    condition     = contains(["azure-keyvault"], var.consul_secrets.kind)
    error_message = "Kind must be 'azure-keyvault'."
  }

  validation {
    condition     = var.consul_secrets.kind == "azure-keyvault" ? var.consul_secrets.azure_keyvault.id != null : true
    error_message = "No 'consul_secrets.azure_keyvault.id' provided."
  }
}

#------------------------------------------------------------------------------
# Compute
#------------------------------------------------------------------------------

variable "consul_vm_size" {
  type        = string
  description = "The size of VM instance to use for Consul agents."
  default     = "Standard_D2s_v3"
}

variable "disk_params" {
  type = object({
    root = object({
      disk_type = optional(string, "Premium_LRS")
      disk_size = optional(number, 32)
    }),
    data = object({
      disk_type = optional(string, "Premium_LRS")
      disk_size = optional(number, 1024)
    })
  })
  description = "Disk parameters to use for the cluster nodes' block devices."
  default = {
    root = {}
    data = {}
  }
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

variable "storage_account_type" {
  type        = string
  description = "Redundancy type for the Consul Snapshot storage account. Must be one of LRS, GRS, or RAGRS."
  default     = "GRS"
}



variable "image_reference" {
  type = object({
    publisher = string,
    offer     = string,
    sku       = string,
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  description = "Azure platform image details to use for VMSS instances"
}
#------------------------------------------------------------------------------
# Networking
#------------------------------------------------------------------------------
variable "vnet_id" {
  type        = string
  description = "VNet ID where Consul resources will reside."
}
variable "create_lb" {
  type        = bool
  description = "Boolean to create an Azure Load Balancer for Consul."
  default     = true
}
variable "load_balancer_internal" {
  type        = bool
  description = "Whether the provisioned load balancer should be internal-facing or internet-facing. If internal facing, ensure NAT Gateway or another internet egress method has been configured in your vnet."
  default     = false
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet in which resources should be deployed."
}

#------------------------------------------------------------------------------
# DNS
#------------------------------------------------------------------------------

variable "consul_fqdn" {
  type        = string
  description = "Fully qualified domain name of the consul cluster. This name __must__ match a SAN entry in the TLS server certificate."
}
variable "create_consul_public_dns_record" {
  type        = bool
  description = "Boolean to create a DNS record for consul in a public Azure DNS zone. `public_dns_zone_name` must also be provided when `true`."
  default     = false
}

variable "create_consul_private_dns_record" {
  type        = bool
  description = "Boolean to create a DNS record for consul in a private Azure DNS zone. `private_dns_zone_name` must also be provided when `true`."
  default     = false
}

variable "public_dns_zone_name" {
  type        = string
  description = "Name of existing public Azure DNS zone to create DNS record in. Required when `create_consul_public_dns_record` is `true`."
  default     = null
}

variable "public_dns_zone_rg" {
  type        = string
  description = "Name of Resource Group where `public_dns_zone_name` resides. Required when `create_consul_public_dns_record` is `true`."
  default     = null
}

variable "private_dns_zone_name" {
  type        = string
  description = "Name of existing private Azure DNS zone to create DNS record in. Required when `create_consul_private_dns_record` is `true`."
  default     = null
}

variable "private_dns_zone_rg" {
  type        = string
  description = "Name of Resource Group where `private_dns_zone_name` resides. Required when `create_consul_private_dns_record` is `true`."
  default     = null
}

