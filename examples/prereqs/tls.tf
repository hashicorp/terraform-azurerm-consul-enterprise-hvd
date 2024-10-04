# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "tls_private_key" "agent_ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "agent_ca" {
  private_key_pem       = tls_private_key.agent_ca.private_key_pem
  validity_period_hours = 87600 # 10y
  is_ca_certificate     = true
  set_subject_key_id    = true

  subject {
    common_name = "Consul Agent TF Testing CA"
  }

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing"
  ]
}

resource "tls_private_key" "agent_leaf" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "agent_leaf" {
  private_key_pem = tls_private_key.agent_leaf.private_key_pem

  subject {
    common_name = "server.${var.consul_datacenter}.consul"
  }

  dns_names    = ["server.${var.consul_datacenter}.consul", "localhost"]
  ip_addresses = ["127.0.0.1"]
}

resource "tls_locally_signed_cert" "leaf_cert" {
  cert_request_pem   = tls_cert_request.agent_leaf.cert_request_pem
  ca_private_key_pem = tls_private_key.agent_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.agent_ca.cert_pem

  validity_period_hours = 8760 # 1y
  set_subject_key_id    = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
    "server_auth",
  ]
}