#!/usr/bin/env bash
set -eu

REGION=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/compute/location?api-version=2023-07-01&format=text")
AVAILABILITY_ZONE=$(curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/compute/zone?api-version=2023-07-01&format=text")

echo "Beginning Consul configuration file generation"

mkdir -p /etc/consul.d

bash -c "cat > /etc/consul.d/server.hcl" <<EOF
${consul_config}

node_meta {
  availability_zone = "$${REGION}-$${AVAILABILITY_ZONE}"
}
EOF

chown consul:consul /etc/consul.d/server.hcl

echo "Consul configuration file generation - complete"