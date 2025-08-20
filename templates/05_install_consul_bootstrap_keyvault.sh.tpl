#!/usr/bin/env bash
## shellcheck disable=SC2034,SC2154
export SHELLOPTS
set -euo pipefail

# this script must be idempotent whenever acl/bootstrap request returns 403
# that way if bootstrap is inadvertantly left enabled it is non-distruptive and
# does not add to the complexity of the system

# shellcheck disable=SC2288,SC1083  # applied to terraform templating language
set +e

echo "Beginning Consul ACL system bootstrap"

read -r -d '' ANONYMOUS_DEFINITION <<'EOF'
partition_prefix "" {
  namespace_prefix "" {
    node_prefix "" {
      policy = "read"
    }
    service_prefix "" {
      policy = "read"
    }
  }
}
EOF

read -r -d '' AGENT_POLICY_DEFINITION <<EOF
partition "default" {
  node_prefix "" {
    policy = "write"
  }
  namespace_prefix "" {
    service_prefix "" {
      policy = "read"
    }
  }
}
EOF

read -r -d '' SNAPSHOT_POLICY_DEFINITION <<EOF
acl = "write"
key "consul-snapshot/lock" {
  policy = "write"
}
session_prefix "" {
  policy = "write"
}
service "consul-snapshot" {
  policy = "write"
}
EOF

set -e

# parse resource id for key vault name. 3-24 character string, containing only 0-9, a-z, A-Z, and not consecutive -
KEYVAULT=$(grep -oE '[a-zA-Z0-9-]{3,}$' <<< "${consul_secrets.azure_keyvault.id}")

SECRET_CONFIG="$(jq -ec . /etc/consul.d/secrets.json)"
az login --identity > /dev/null
trap "az logout" EXIT

echo -n "waiting for the leader to be established"
until curl --fail --silent --show-error --unix-socket /run/consul/consul.sock http://localhost/v1/status/leader | grep -qE '(\.|:)+'  ; do
  echo -n "."
  sleep 5
done

# 200 acls bootstrapped
# 403 acls previously bootstrapped
export CONSUL_HTTP_ADDR=unix:///run/consul/consul.sock
if RESPONSE="$(curl --fail --silent --show-error --request PUT --unix-socket /run/consul/consul.sock http://localhost/v1/acl/bootstrap)" ; then
  MGMT_TOKEN=$(echo "$${RESPONSE}" | jq -er .SecretID)
  az keyvault secret set --vault-name "$${KEYVAULT}" --name mgmt-token --value "$${MGMT_TOKEN}"

  export CONSUL_HTTP_TOKEN=$${MGMT_TOKEN}
  consul acl policy create -name anonymous-policy -description "Policy to Attach to Anonymous Token" -rules "$${ANONYMOUS_DEFINITION}"
  consul acl token update -accessor-id anonymous -append-policy-name anonymous-policy

  consul acl policy create -name server-agent-policy -description "Policy for Server Agents" -rules "$${AGENT_POLICY_DEFINITION}"
  AGENT_TOKEN=$(consul acl token create -policy-name server-agent-policy -description "Token for Server Agents" -format json | jq -er .SecretID)
  az keyvault secret set --vault-name "$${KEYVAULT}" --name agent-token --value "$${AGENT_TOKEN}" 1>/dev/null

  consul acl policy create -name snapshot-policy -description "Policy for Snapshot Agent" -rules "$${SNAPSHOT_POLICY_DEFINITION}"
  SNAPSHOT_TOKEN=$(consul acl token create -policy-name snapshot-policy -description "Token for Snapshot Agent" -format json | jq -er .SecretID)
  az keyvault secret set --vault-name "$${KEYVAULT}" --name snapshot-token --value "$${SNAPSHOT_TOKEN}" 1>/dev/null

  unset CONSUL_HTTP_TOKEN
else
  echo -n "waiting for agent-token to be set in azure key vault"
  until az keyvault secret list --vault-name "$${KEYVAULT}" | jq -e '.[] | select(.name=="agent-token")' ; do
    echo -n "."
    sleep 10
  done
  AGENT_TOKEN=$(az keyvault secret show --vault-name "$${KEYVAULT}" --name agent-token | jq -er .value)
fi

SECRET_CONFIG=$(echo "$${SECRET_CONFIG}" | jq -e --arg agent_token "$${AGENT_TOKEN}" '.acl.tokens.agent |= $agent_token')
echo "$${SECRET_CONFIG}" >/etc/consul.d/secrets.json
systemctl reload consul.service

echo "Consul ACL bootstrap - complete"
