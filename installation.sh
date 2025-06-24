#!/bin/bash

# Clear the screen
clear

echo "==================== NEXUS CLI NODE SETUP ===================="
echo "🔐 Step 1: Log in to the Nexus Dashboard"
echo "👉 Open: https://app.nexus.xyz/nodes"
echo "   - Login with your email address (you will receive a link)"
echo "     OR"
echo "   - Login using your Web3 wallet (e.g. MetaMask)"
echo ""
echo "🧩 Step 2: Add a CLI Node"
echo "   - Click 'Add CLI Node'"
echo "   - Copy the numeric Node ID (e.g. 345677)"
echo "=============================================================="
echo ""

# Prompt user for Node ID (digits only)
while true; do
    read -p "Enter your numeric Node ID: " yournodeid
    if [[ "$yournodeid" =~ ^[0-9]+$ ]]; then
        echo "✅ Node ID accepted: $yournodeid"
        break
    else
        echo "❌ Invalid input. Please enter digits only (e.g. 345677)."
    fi
done

# Update and install required packages
sudo apt update && sudo apt upgrade -y
sudo apt install screen curl build-essential pkg-config libssl-dev git-all protobuf-compiler -y
sudo apt update

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
rustup target add riscv32i-unknown-none-elf

# Clone and build nexus-cli
git clone https://github.com/nexus-xyz/nexus-cli
cd nexus-cli/clients/cli
cargo build --release

# Copy the binary to system path
sudo cp target/release/nexus-network /usr/local/bin/
nexus-network --version

# Create systemd service for Nexus
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOF
[Unit]
Description=Nexus Proving
After=network-online.target

[Service]
Type=simple
User=$USER
ExecStart=/usr/local/bin/nexus-network start --node-id $yournodeid --headless
Restart=always
RestartSec=2
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

# Show service status and logs
echo ""
echo "✅ Nexus service has been started!"
echo "📄 Watching logs now: "
echo "=============================================================="
