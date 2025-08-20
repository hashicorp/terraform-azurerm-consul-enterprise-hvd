#!/usr/bin/env bash
## shellcheck disable=SC2034,SC2154
export SHELLOPTS
set -euo pipefail

echo "Beginning Consul secrets retrieval"

# parse resource id for key vault name. 3-24 character string, containing only 0-9, a-z, A-Z, and not consecutive -
KEYVAULT=$(grep -oE '[a-zA-Z0-9-]{3,}$' <<< "${consul_secrets.azure_keyvault.id}")

SECRET_CONFIG='{}' ; SECRETS='[]'
az login --identity
trap "az logout" EXIT

mkdir -p /etc/consul.d/tls

SECRETS=$(az keyvault secret list --vault-name "$${KEYVAULT}" | jq -re '[ .[].name ]')

GOSSIP_KEY=$(az keyvault secret show --vault-name "$${KEYVAULT}" --name gossip-key | jq -r .value)
SECRET_CONFIG=$(echo "$${SECRET_CONFIG}" | jq --arg key "$${GOSSIP_KEY}" '.encrypt += $key')

# if agent-token key exists in key vault during bootstrap event the bootstrap script will overwrite
# the value with a new token that is permissioned against the cluster's [new] acl system
if echo "$${SECRETS}" | jq -e '. as $s | "agent-token" | IN($s[])' >/dev/null 2>&1; then
  AGENT_TOKEN=$(az keyvault secret show --vault-name "$${KEYVAULT}" --name agent-token | jq -r .value)
  SECRET_CONFIG=$(echo "$${SECRET_CONFIG}" | jq --arg agent_token "$${AGENT_TOKEN}" '.acl.tokens.agent += $agent_token')
fi

  az keyvault secret show --vault-name "$${KEYVAULT}" --name consul-agent-cert | jq -r .value | base64 -d >/etc/consul.d/tls/cert.pem
  az keyvault secret show --vault-name "$${KEYVAULT}" --name consul-ca-cert | jq -r .value | base64 -d >/etc/consul.d/tls/ca.pem

(
  umask 007
  az keyvault secret show --vault-name "$${KEYVAULT}" --name consul-agent-key | jq -r .value | base64 -d >/etc/consul.d/tls/key.pem
  az keyvault secret show --vault-name "$${KEYVAULT}" --name consul-license | jq -r .value  >/etc/consul.d/consul.hclic
  echo "$${SECRET_CONFIG}" >/etc/consul.d/secrets.json
)
chown -R consul:consul /etc/consul.d
echo "Consul secrets retrieval - complete"