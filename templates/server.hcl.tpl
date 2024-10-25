server           = true
datacenter       = "${consul_datacenter}"
client_addr      = "0.0.0.0"
bootstrap_expect = ${node_count}
license_path     = "/etc/consul.d/consul.hclic"

retry_join = ["provider=azure subscription_id=${subscription_id} resource_group=${resource_group} vm_scale_set=${vm_scale_set}"]

tls {
  defaults {
    ca_file         = "/etc/consul.d/tls/ca.pem"
    cert_file       = "/etc/consul.d/tls/cert.pem"
    key_file        = "/etc/consul.d/tls/key.pem"
    verify_incoming = false
    verify_outgoing = true
  }

  internal_rpc {
    verify_incoming        = true
    verify_server_hostname = true
  }
}

acl {
  enabled                  = true
  default_policy           = "deny"
  down_policy              = "extend-cache"
  enable_token_persistence = true
}

auto_encrypt {
  allow_tls = true
}
telemetry {
  prometheus_retention_time = "480h"
  disable_hostname          = true
}
# Server performance config
limits {
  rpc_max_conns_per_client  = 100
  http_max_conns_per_client = 200
}

autopilot {
  redundancy_zone_tag = "availability_zone"
  min_quorum          = ${node_count}
}

connect {
  enabled = true
}

ports {
  http     = 8500
  https    = 8501
  grpc     = -1
  grpc_tls = 8503
}

addresses {
  http = "unix:///run/consul/consul.sock"
}

ui_config {
  enabled = true
}
