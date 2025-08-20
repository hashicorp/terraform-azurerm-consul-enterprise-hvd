#!/usr/bin/env bash
set -eu

echo "Beginning Consul Systemd unit installation"

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

mkdir /run/consul
chown -R consul:consul /run/consul /opt/consul/data
chmod 0770 /run/consul /opt/consul/data
systemctl daemon-reload && systemctl enable --now consul.service

echo "Consul Systemd unit generation - complete"
