#!/bin/bash

# TAKERMAN AI Server - Setup Grafana Configuration
# Creates Grafana datasources and dashboard provisioning

set -e

GRAFANA_CONFIG_DIR="/root/volumes/monitoring/grafana"
DATASOURCES_DIR="$GRAFANA_CONFIG_DIR/datasources"
DASHBOARDS_DIR="$GRAFANA_CONFIG_DIR/dashboards"
PROMETHEUS_CONFIG_DIR="/root/volumes/monitoring/prometheus/config"

# Create directories
mkdir -p "$DATASOURCES_DIR"
mkdir -p "$DASHBOARDS_DIR"
mkdir -p "$PROMETHEUS_CONFIG_DIR"

echo "Setting up Grafana configuration..."

# Create Prometheus datasource
cat > "$DATASOURCES_DIR/prometheus.yml" << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://monitoring_prometheus:9090
    isDefault: true
    editable: true
    jsonData:
      timeInterval: "15s"
      queryTimeout: "60s"
      httpMethod: "POST"
EOF

# Create dashboard provisioning config
cat > "$DASHBOARDS_DIR/dashboards.yml" << 'EOF'
apiVersion: 1

providers:
  - name: 'TAKERMAN AI Server'
    orgId: 1
    folder: 'TAKERMAN'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 30
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
      foldersFromFilesStructure: true
EOF

# Copy Prometheus config
if [ -f "/root/server/configs/prometheus.yml" ]; then
    cp /root/server/configs/prometheus.yml "$PROMETHEUS_CONFIG_DIR/prometheus.yml"
    echo "Prometheus configuration copied"
fi

echo "Grafana configuration setup complete!"
echo ""
echo "Access Grafana at: http://$(hostname -I | awk '{print $1}'):3001"
echo "Username: takerman"
echo "Password: Hakerman91!"
echo ""
echo "After logging in, you can:"
echo "1. Import community dashboards from grafana.com"
echo "2. Create custom dashboards for your AI workloads"
echo "3. Set up alerts and notifications"
echo ""
echo "Recommended Dashboard IDs to import:"
echo "  - 1860: Node Exporter Full"
echo "  - 11600: Docker Container & Host Metrics"
echo "  - 14574: NVIDIA GPU Metrics (if DCGM exporter installed)"
echo ""
