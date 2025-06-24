#!/bin/bash

clear
echo "==================== 🚀 NEXUS MULTI-NODE SETUP BY HUSTLE AIRDROPS ===================="
echo "┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐"
echo "│  ██╗░░██╗██╗░░░██╗░██████╗████████╗██╗░░░░░███████╗  ░█████╗░██╗██████╗░██████╗░██████╗░░█████╗░██████╗░░██████╗  │"
echo "│  ██║░░██║██║░░░██║██╔════╝╚══██╔══╝██║░░░░░██╔════╝  ██╔══██╗██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝  │"
echo "│  ███████║██║░░░██║╚█████╗░░░░██║░░░██║░░░░░█████╗░░  ███████║██║██████╔╝██║░░██║██████╔╝██║░░██║██████╔╝╚█████╗░  │"
echo "│  ██╔══██║██║░░░██║░╚═══██╗░░░██║░░░██║░░░░░██╔══╝░░  ██╔══██║██║██╔══██╗██║░░██║██╔══██╗██║░░██║██╔═══╝░░╚═══██╗  │"
echo "│  ██║░░██║╚██████╔╝██████╔╝░░░██║░░░███████╗███████╗  ██║░░██║██║██║░░██║██████╔╝██║░░██║╚█████╔╝██║░░░░░██████╔╝  │"
echo "│  ╚═╝░░╚═╝░╚═════╝░╚═════╝░░░░╚═╝░░░╚══════╝╚══════╝  ╚═╝░░╚═╝╚═╝╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝░╚════╝░╚═╝░░░░░╚═════╝░  │"
echo "└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘"
echo ""
echo "🔗 GitHub: https://github.com/HustleAirdrops"
echo "💬 Telegram: https://t.me/Hustle_Airdrops"
echo ""


# Enable swap if not present
if ! swapon --show | grep -q '/swapfile'; then
  echo "💾 Creating 2G swapfile to prevent memory crashes..."
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  echo "✅ Swap enabled."
else
  echo "💾 Swap already active."
fi

read -p "🔢 How many Nexus nodes do you want to run? " NODE_COUNT
if ! [[ "$NODE_COUNT" =~ ^[0-9]+$ ]]; then
  echo "❌ Invalid input. Please enter digits only."
  exit 1
fi

echo "🔧 Checking and installing required packages..."
REQUIRED_PKGS=(build-essential pkg-config libssl-dev git git-all protobuf-compiler curl)
for pkg in "${REQUIRED_PKGS[@]}"; do
  dpkg -s "$pkg" &>/dev/null || sudo apt install -y "$pkg"
  sleep 1
done

if ! command -v rustup &>/dev/null; then
  echo "🦀 Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

source "$HOME/.cargo/env"
rustup target add riscv32i-unknown-none-elf

if [ ! -d "$HOME/nexus-cli/clients/cli" ]; then
  echo "📥 Cloning Nexus CLI..."
  rm -rf "$HOME/nexus-cli"
  git clone https://github.com/nexus-xyz/nexus-cli "$HOME/nexus-cli"
fi

cd "$HOME/nexus-cli/clients/cli" || exit
cargo build --release -j 2
sudo cp target/release/nexus-network /usr/local/bin/

mkdir -p "$HOME/nexus-multi"

for ((i = 1; i <= NODE_COUNT; i++)); do
  echo ""
  read -p "🔑 Enter Node ID for node$i: " NODE_ID
  NODE_DIR="$HOME/nexus-multi/node$i"
  mkdir -p "$NODE_DIR"
  echo "{ \"node_id\": \"$NODE_ID\" }" > "$NODE_DIR/config.json"

  SERVICE_NAME="nexus-node$i"
  SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME.service"

  if [ -f "$SERVICE_PATH" ]; then
    echo "⚠️ Service $SERVICE_NAME already exists. Backing it up..."
    sudo mv "$SERVICE_PATH" "$SERVICE_PATH.bak.$(date +%s)"
  fi

  sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=Nexus Node $i by Hustle Airdrops
After=network-online.target
StartLimitIntervalSec=200
StartLimitBurst=5

[Service]
Type=simple
User=$USER
WorkingDirectory=$NODE_DIR
ExecStart=/usr/local/bin/nexus-network start --node-id $NODE_ID --headless
Restart=on-failure
RestartSec=15
LimitNOFILE=65535
Environment="NEXUS_HOME=$NODE_DIR"

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable "$SERVICE_NAME"
  sudo systemctl start "$SERVICE_NAME"

  sleep 3
  STATUS=$(systemctl is-active "$SERVICE_NAME")
  if [ "$STATUS" == "active" ]; then
    echo "✅ Node$i started successfully as service: $SERVICE_NAME"
  else
    echo "❌ Node$i failed to start. Check error log below:"
    journalctl -u "$SERVICE_NAME" --no-pager | tail -n 20
  fi

done

echo ""
echo "====================== ✅ ALL SET ======================"
echo "📄 To view logs for any node: journalctl -u nexus-nodeX -f"
echo "🛑 To stop a node:          sudo systemctl stop nexus-nodeX"
echo "🔁 To restart a node:       sudo systemctl restart nexus-nodeX"
echo "❌ To delete all nodes:     sudo rm -rf ~/nexus-multi && sudo rm /etc/systemd/system/nexus-node* && sudo systemctl daemon-reload"
echo ""
echo "🔥 Powered by Hustle Airdrops - Max Nodes, Max Rewards 🔥"
