#!/usr/bin/env bash
export SHELLOPTS
set -eou pipefail

LOGFILE="/var/log/consul-cloud-init.log"
PRODUCT="consul"
CONSUL_VERSION="${consul_version}"
VERSION=$CONSUL_VERSION

CONSUL_DIR_BIN="/usr/bin"

CONSUL_DIR_HOME="/opt/consul/"
CONSUL_DIR_LICENSE="$${CONSUL_DIR_HOME}/license"
CONSUL_DIR_DATA="$${CONSUL_DIR_HOME}/data"
CONSUL_DIR_CONFIG="/etc/consul.d"
CONSUL_DIR_SNAPSHOT="/etc/consul-snapshot.d"
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
exit_script() {
  if [[ "$1" == 0 ]]; then
    log "INFO" "Vault custom_data script finished successfully!"
  else
    log "ERROR" "Vault custom_data script finished with error code $1."
  fi

  exit "$1"
}

function install_consul_snapshot_agent {

  #parse resource id for key vault name. 3-24 character string, containing only 0-9, a-z, A-Z, and not consecutive -

  log "INFO" "KV Secrets for $${PRODUCT} snapshot agent from vars"
  KEYVAULT=$(grep -oE '[a-zA-Z0-9-]{3,}$' <<< "${consul_secrets.azure_keyvault.id}")

  log "INFO" "Logging into Azure"
  az login --identity < /dev/null
  trap "az logout" EXIT

	log "INFO" "Waiting for the leader to be established..."
  until curl --fail --silent --show-error --unix-socket /run/consul/consul.sock http://localhost/v1/status/leader | grep -qE '(\.|:)+'  ; do
    echo -n "."
    sleep 5
  done
  log "INFO" "Leader established."
  log "INFO" "Waiting for snapshot-token to be set in Azure Key Vault..."
  until az keyvault secret list --vault-name "$${KEYVAULT}" | jq -e '.[] | select(.name=="snapshot-token")' ; do
    echo -n "."
    sleep 10
  done
	log "INFO" "Snapshot token established in Azure Key Vault."

	log "INFO" "Retrieving snapshot token and storage account key..."
  SNAPSHOT_TOKEN=$(az keyvault secret show --vault-name "$${KEYVAULT}" --name snapshot-token | jq -er .value)
  STORAGE_ACCOUNT_KEY=$(az keyvault secret show --vault-name "$${KEYVAULT}" --name storage-account-key | jq -er .value)

	mkdir -p $CONSUL_DIR_SNAPSHOT


  log "INFO" "Creating Consul snapshot configuration file..."
  bash -c "cat > $CONSUL_DIR_SNAPSHOT/consul-snapshot.json" <<EOF
{
  "snapshot_agent": {
    "http_addr": "unix:///run/consul/consul.sock",
    "token": "$${SNAPSHOT_TOKEN}",
    "snapshot": {
      "interval": "${snapshot_agent.interval}",
      "retain": ${snapshot_agent.retention},
      "deregister_after": "8h"
    },
    "backup_destinations": {
      "azure_blob_storage": [
        {
          "account_name": "${snapshot_agent.storage_account_name}",
          "account_key": "$${STORAGE_ACCOUNT_KEY}",
          "container_name": "${snapshot_agent.object_container_name}",
          "environment": "${snapshot_agent.azure_environment}"
        }
      ]
    }
  }
}
EOF

  log "INFO" "Creating Consul snapshot service file..."
  bash -c "cat > /etc/systemd/system/consul-snapshot.service" <<EOF
[Unit]
Description="HashiCorp Consul Snapshot Agent"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul-snapshot.d/consul-snapshot.json

[Service]
Type=simple
User=consul
Group=consul
ExecStart=/usr/local/bin/consul snapshot agent -config-file=/etc/consul-snapshot.d/consul-snapshot.json
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

  log "INFO" "Setting permissions for Consul snapshot directory..."
  chown -R $CONSUL_USER:$CONSUL_GROUP $CONSUL_DIR_SNAPSHOT
	chmod -R 750 $CONSUL_DIR_SNAPSHOT
  chmod -R 660 $CONSUL_DIR_SNAPSHOT/*

  log "INFO" "Reloading systemd and enabling Consul snapshot service..."
  systemctl daemon-reload && systemctl enable --now consul-snapshot.service

}

main() {
  log "INFO" "Beginning $${PRODUCT} snapshot agent install and configuration"
  install_consul_snapshot_agent
  log "INFO" "Completed $${PRODUCT} snapshot agent install and configuration"
}

main "$@"


