#!/usr/bin/env bash
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

function generate_consul_config {
  REGION=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/compute/location?api-version=2023-07-01&format=text")
  AVAILABILITY_ZONE=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/compute/zone?api-version=2023-07-01&format=text")

	sudo bash -c "cat > /etc/consul.d/server.hcl" <<EOF
${consul_config}

node_meta {
  availability_zone = "$${REGION}-$${AVAILABILITY_ZONE}"
}
EOF

 log "INFO" "Consul configuration file generated successfully at /etc/consul.d/server.hcl"
 sudo chmod 600 $CONSUL_DIR_CONFIG/server.hcl
 sudo chown consul:consul $CONSUL_DIR_CONFIG/server.hcl
}


main() {
  log "INFO" "Generating Consul configuration file"
  generate_consul_config
}

main "$@"

