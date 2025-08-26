#!/usr/bin/env bash
## shellcheck disable=SC2034,SC2154
export SHELLOPTS
set -euo pipefail

LOGFILE="/var/log/consul-cloud-init.log"
PRODUCT="consul"
CONSUL_VERSION="${consul_version}"
VERSION=$CONSUL_VERSION
CONSUL_DIR_BIN="/usr/bin"
CONSUL_DIR_HOME="/opt/consul/"
CONSUL_DIR_LICENSE="$${CONSUL_DIR_HOME}/license"
CONSUL_DIR_DATA="$${CONSUL_DIR_HOME}/data"
CONSUL_DIR_CONFIG="/etc/consul.d"
CONSUL_DIR_TLS="$${CONSUL_DIR_CONFIG}/tls"
CONSUL_USER="consul"
CONSUL_GROUP="consul"

function log {
  local level="$1"
  local message="$2"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local log_entry="$timestamp [$level] - $message"

  echo "$log_entry" | tee -a "$LOGFILE"
}

function exit_script {
  if [[ "$1" == 0 ]]; then
    log "INFO" "Vault custom_data script finished successfully!"
  else
    log "ERROR" "Vault custom_data script finished with error code $1."
  fi

  exit "$1"
}

function retrieve_consul_secrets {
  log "INFO" "Retrieving $${PRODUCT} secrets from Azure Key Vault"
  # parse resource id for key vault name. 3-24 character string, containing only 0-9, a-z, A-Z, and not consecutive -
  KEYVAULT=$(grep -oE '[a-zA-Z0-9-]{3,}$' <<< "${consul_secrets.azure_keyvault.id}")
  SECRET_CONFIG='{}' ; SECRETS='[]'

	az login --identity
  trap "az logout" EXIT

	SECRETS=$(az keyvault secret list --vault-name "$${KEYVAULT}" | jq -re '[ .[].name ]')
  GOSSIP_KEY=$(az keyvault secret show --vault-name "$${KEYVAULT}" --name gossip-key | jq -r .value)
  SECRET_CONFIG=$(echo "$${SECRET_CONFIG}" | jq --arg key "$${GOSSIP_KEY}" '.encrypt += $key')
# the value with a new token that is permissioned against the cluster's [new] acl system
  if echo "$${SECRETS}" | jq -e '. as $s | "agent-token" | IN($s[])' >/dev/null 2>&1; then
    AGENT_TOKEN=$(az keyvault secret show --vault-name "$${KEYVAULT}" --name agent-token | jq -r .value)
    SECRET_CONFIG=$(echo "$${SECRET_CONFIG}" | jq --arg agent_token "$${AGENT_TOKEN}" '.acl.tokens.agent += $agent_token')
  fi

  log "INFO" "Retrieving $${PRODUCT} TLS certificates"
  az keyvault secret show --vault-name "$${KEYVAULT}" --name consul-agent-cert | jq -r .value | base64 -d >$CONSUL_DIR_TLS/cert.pem
  az keyvault secret show --vault-name "$${KEYVAULT}" --name consul-ca-cert | jq -r .value | base64 -d >$CONSUL_DIR_TLS/ca.pem

	(
		umask 007
		log "INFO" "Retrieving $${PRODUCT} agent key"
    az keyvault secret show --vault-name "$${KEYVAULT}" --name consul-agent-key | jq -r .value | base64 -d >$CONSUL_DIR_TLS/key.pem
    log "INFO" "Retrieving $${PRODUCT} license"
		az keyvault secret show --vault-name "$${KEYVAULT}" --name consul-license | jq -r .value  >$CONSUL_DIR_CONFIG/consul.hclic
    log "INFO" "Retrieving $${PRODUCT} secrets"
		echo "$${SECRET_CONFIG}" >$CONSUL_DIR_CONFIG/secrets.json
  )
	log "INFO" "Setting ownership for $${PRODUCT} configuration files"
  chown -R $CONSUL_USER:$CONSUL_GROUP $CONSUL_DIR_CONFIG

}

# if agent-token key exists in key vault during bootstrap event the bootstrap script will overwrite

main() {
  log "INFO" "Beginning $${PRODUCT} secrets retrieval"
  retrieve_consul_secrets
  log "INFO" "Consul secrets retrieval - complete"
}

main "$@"
