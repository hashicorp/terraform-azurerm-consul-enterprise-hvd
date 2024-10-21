# Deployment Customizations

On this page are various deployment customizations and their corresponding input variables that you may set to meet your requirements.

## Load Balancer

This module defaults to creating a load balancer (`create_lb = true`) that is internal (`load_balancer_internal = true`).

### Internal Load Balancer with Static (private) IP (default)

When using an internal load balancer you must set the static IP to an available IP address from our load balancer subnet.

```hcl
lb_private_ip = "<10.0.1.20>"
```

### External Load Balancer with Public IP

Here we must set the following boolean to false, and the module will automatically create and configure a Public IP for the load balancer frontend IP configuration.

```hcl
load_balancer_internal = false
```

## DNS

If you have an existing Azure DNS zone (public or private) that you would like this module to create a DNS record within for the Consul  FQDN, the following input variables may be set. This is completely optional; you are free to create your own DNS record for the Consul FQDN resolving to the Vault load balancer out-of-band from this module.

### Azure Private DNS Zone

If your load balancer is internal (`load_balancer_internal = true`) and a private, static IP is set (`lb_private_ip = "10.0.1.20"`), then the DNS record should be created in a private zone.

```hcl
create_vault_private_dns_record = true
private_dns_zone_name           = "<example.com>"
private_dns_zone_rg             = "<my-private-dns-zone-resource-group-name>"
```

### Azure Public DNS Zone

If your load balancer is external (`var.load_balancer_internal = false`), the module will automatically create a public IP address for the load balancer, and hence the DNS record should be created in a public zone.

```hcl
create_vault_public_dns_record  = true
public_dns_zone_name            = "<example.com>"
public_dns_zone_rg              = "<my-public-dns-zone-resource-group-name>"
```

## Custom VM Image

If a custom VM image is preferred over using a standard marketplace image, the following variable may be set:

```hcl

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
```



