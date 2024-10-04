#!/usr/bin/env bash
set -eu

echo "Beginning Consul snapshot agent configuration"

# parse resource id for key vault name. 3-24 character string, containing only 0-9, a-z, A-Z, and not consecutive -
KEYVAULT=$(grep -oE '[a-zA-Z0-9-]{3,}$' <<< "${consul_secrets.azure_keyvault.id}")

az login --identity < /dev/null
trap "az logout" EXIT

echo -n "waiting for the leader to be established..."
until curl --fail --silent --show-error --unix-socket /run/consul/consul.sock http://localhost/v1/status/leader | grep -qE '(\.|:)+'  ; do
  echo -n "."
  sleep 5
done
echo "done"

echo -n "waiting for snapshot-token to be set in azure key vault..."
until az keyvault secret list --vault-name "$${KEYVAULT}" | jq -e '.[] | select(.name=="snapshot-token")' ; do
  echo -n "."
  sleep 10
done
echo "done"

SNAPSHOT_TOKEN=$(az keyvault secret show --vault-name "$${KEYVAULT}" --name snapshot-token | jq -er .value)
STORAGE_ACCOUNT_KEY=$(az keyvault secret show --vault-name "$${KEYVAULT}" --name storage-account-key | jq -er .value)

mkdir -p /etc/consul-snapshot.d
bash -c "cat > /etc/consul-snapshot.d/consul-snapshot.json" <<EOF
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

chown -R consul:consul /etc/consul-snapshot.d
chmod -R 660 /etc/consul-snapshot.d/*
systemctl daemon-reload && systemctl enable --now consul-snapshot.service

echo "Consul snapshot agent configuration - complete"