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
echo -e "${YELLOW}              GitHub: https://github.com/HustleAirdrops${NC}"
echo -e "${YELLOW}              Telegram: https://t.me/Hustle_Airdrops${NC}"
echo -e "${GREEN}===============================================================================${NC}"

# Ask number of nodes
echo "📦 How many Nexus nodes do you want to run?"
read -p "🔢 Enter number: " NODE_COUNT
if ! [[ "$NODE_COUNT" =~ ^[0-9]+$ ]]; then
  echo "❌ Invalid input. Please enter digits only."
  exit 1
fi

# Install dependencies only if not already installed
echo "🔧 Checking and installing required packages..."
REQUIRED_PKGS=(build-essential pkg-config libssl-dev git protobuf-compiler curl)
for pkg in "${REQUIRED_PKGS[@]}"; do
  dpkg -s "$pkg" &>/dev/null || sudo apt install -y "$pkg"
done

# Install Rust if not installed
if ! command -v rustup &>/dev/null; then
  echo "🦀 Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Ensure cargo is sourced
source "$HOME/.cargo/env"
rustup target add riscv32i-unknown-none-elf

# Clone and build Nexus CLI if not already done or incomplete
if [ ! -d "$HOME/nexus-cli/clients/cli" ]; then
  echo "📥 Cloning Nexus CLI..."
  rm -rf "$HOME/nexus-cli" # remove broken or incomplete clone
  git clone https://github.com/nexus-xyz/nexus-cli "$HOME/nexus-cli"
fi

cd "$HOME/nexus-cli/clients/cli"
cargo build --release
sudo cp target/release/nexus-network /usr/local/bin/

# Setup directory
mkdir -p "$HOME/nexus-multi"

# Node setup loop
for ((i = 1; i <= NODE_COUNT; i++)); do
  echo ""
  read -p "🔑 Enter Node ID for node$i: " NODE_ID
  NODE_DIR="$HOME/nexus-multi/node$i"
  mkdir -p "$NODE_DIR"
  echo "{ \"node_id\": \"$NODE_ID\" }" > "$NODE_DIR/config.json"

  SERVICE_NAME="nexus-node$i"
  SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}.service"

  # If service already exists, back it up
  if [ -f "$SERVICE_PATH" ]; then
    echo "⚠️ Service $SERVICE_NAME already exists. Backing up..."
    sudo mv "$SERVICE_PATH" "$SERVICE_PATH.bak.$(date +%s)"
  fi

  # Create systemd service
  sudo tee "$SERVICE_PATH" > /dev/null <<EOF
[Unit]
Description=Nexus Node $i by Hustle Airdrops
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

  # Check status
  sleep 2
  STATUS=$(systemctl is-active "$SERVICE_NAME")
  if [ "$STATUS" == "active" ]; then
    echo "✅ Node$i started successfully as service: $SERVICE_NAME"
  else
    echo "❌ Node$i failed to start. Error log (last 20 lines):"
    journalctl -u "$SERVICE_NAME" --no-pager | tail -n 20
  fi

done

# Final Output
echo ""
echo "====================== ✅ ALL SET ======================"
echo "📄 To view logs for any node: journalctl -u nexus-nodeX -f"
echo "🛑 To stop a node:          sudo systemctl stop nexus-nodeX"
echo "🔁 To restart a node:       sudo systemctl restart nexus-nodeX"
echo ""
echo "🔥 Powered by Hustle Airdrops - Max Nodes, Max Rewards 🔥"
