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
CONSUL_DIR_TLS="/opt/consul/tls"
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

function generate_systemd_file {

  log "INFO" "Creating systemd service file for $${PRODUCT}"
  cat - <<'EOF' > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/server.hcl

[Service]
User=consul
Group=consul
LimitNOFILE=65535
ExecStart=/usr/local/bin/consul agent -config-dir /etc/consul.d -data-dir /opt/consul/data -bind '{{ GetInterfaceIP \"eth0\" }}'
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
RestartSec=10s
TimeoutStartSec=120
TimeoutStopSec=120
StartLimitInterval=30min
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

log "INFO" "Setting ownership and permissions for $${PRODUCT} systemd service files (/run/consul /opt/consul/data)"

mkdir /run/consul
chown -R $CONSUL_USER:$CONSUL_GROUP /run/consul
chmod 0770 /run/consul /opt/consul/data

log "INFO" "Restarting $${PRODUCT} AND enabling systemd service"
systemctl daemon-reload && systemctl enable --now consul.service

log "INFO" "$${PRODUCT} systemd service restarted and enabled"
}

main() {
  log "INFO" "create $${PRODUCT} systemd file"
  generate_systemd_file
  log "INFO" "$${PRODUCT} systemd file creation - complete"
}

main "$@"
