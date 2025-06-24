#!/bin/bash

clear
echo "==================== NEXUS MULTI-NODE SETUP ===================="

read -p "How many Nexus nodes you want to run? " NODE_COUNT
if ! [[ "$NODE_COUNT" =~ ^[0-9]+$ ]]; then
  echo "❌ Invalid number."
  exit 1
fi

# Install dependencies
sudo apt update && sudo apt install -y build-essential pkg-config libssl-dev git protobuf-compiler curl
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
rustup target add riscv32i-unknown-none-elf

# Build nexus
cd ~
git clone https://github.com/nexus-xyz/nexus-cli
cd nexus-cli/clients/cli
cargo build --release
sudo cp target/release/nexus-network /usr/local/bin/

# Setup each node
mkdir -p ~/nexus-multi

for ((i = 1; i <= NODE_COUNT; i++)); do
  echo ""
  read -p "Enter Node ID for node$i: " NODE_ID
  NODE_DIR="$HOME/nexus-multi/node$i"
  mkdir -p "$NODE_DIR"
  echo "{ \"node_id\": \"$NODE_ID\" }" > "$NODE_DIR/config.json"

  SERVICE_NAME="nexus-node$i"
  SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}.service"

  # Create systemd service
  sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=Nexus Node $i
After=network-online.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$NODE_DIR
ExecStart=/usr/local/bin/nexus-network start --node-id $NODE_ID --headless
Restart=always
RestartSec=3
LimitNOFILE=65535
Environment="NEXUS_HOME=$NODE_DIR"

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable "$SERVICE_NAME"
  sudo systemctl start "$SERVICE_NAME"

  echo "✅ Node$i started as systemd service: $SERVICE_NAME"
done

echo ""
echo "=============================================================="
echo "🎉 All nodes set up using systemd."
echo "📄 To view logs: journalctl -u nexus-nodeX -f"
echo "🛑 To stop a node: sudo systemctl stop nexus-nodeX"
echo "🔁 To restart: sudo systemctl restart nexus-nodeX"
echo ""
