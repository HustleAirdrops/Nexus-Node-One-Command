#!/bin/bash

# ⛑️ Ctrl+C safe exit
trap "echo -e '\n❌ Installation cancelled by user. Exiting safely.'; exit 1" INT

echo "🚀 Starting Nexus Node Full Setup..."

# Step 1: Create and enter dir
mkdir -p nexus-cli && cd nexus-cli

# Step 2: Install Rust silently
echo "🦀 Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rust-init.sh
chmod +x rust-init.sh
RUSTUP_INIT_SKIP_PATH_CHECK=1 ./rust-init.sh -y

# Step 3: Load Rust env
if [ -f "$HOME/.cargo/env" ]; then
    echo "🔁 Sourcing Rust env..."
    source "$HOME/.cargo/env"
else
    echo "❌ Rust env not found. Exiting."
    exit 1
fi

# Step 4: Add target
echo "🎯 Adding riscv32i target..."
rustup target add riscv32i-unknown-none-elf

# Step 5: System update
echo "🔄 Updating apt..."
sudo apt update

# Step 6: Install deps
echo "📦 Installing dependencies..."
sudo apt install -y pkg-config libssl-dev protobuf-compiler

# Step 7: Install Nexus CLI (auto-confirm)
echo "⚙️ Installing Nexus CLI..."
yes y | curl https://cli.nexus.xyz/ | sh

# Step 8: Inject Nexus path to .bashrc if missing
NEXUS_PATH='export PATH="$HOME/.nexus/bin:$PATH"'
if ! grep -Fxq "$NEXUS_PATH" "$HOME/.bashrc"; then
    echo "$NEXUS_PATH" >> "$HOME/.bashrc"
    echo "➕ Added Nexus CLI to PATH in ~/.bashrc"
fi

# Step 9: Source all env files
for file in \
    "$HOME/.bashrc" \
    "$HOME/.zshrc" \
    "$HOME/.profile" \
    "$HOME/.cargo/env" \
    "/data/data/com.termux/files/home/.bashrc"
do
    [ -f "$file" ] && source "$file"
done

# Step 10: Final check for CLI availability
if ! command -v nexus-network >/dev/null 2>&1; then
    echo -e "\n❌ Nexus CLI installed, but not found in this shell."
    echo ""
    echo "📌 Please do the following steps manually:"
    echo ""
    echo "1️⃣  Run this command to activate the environment:"
    echo "    👉  \033[1msource ~/.bashrc\033[0m"
    echo ""
    echo "2️⃣  Then run this to start your node (replace with your actual Node ID):"
    echo "    👉  \033[1mnexus-network start --node-id <your-node-id>\033[0m"
    echo ""
    echo "📎 You can find your Node ID at: https://beta.nexus.xyz/"
    echo ""
    echo "✅ After these steps, your node will start running."
    echo "👋 Exiting script now."
    exit 0
fi

# Step 11: Ask for node ID
read -p "📝 Enter your Node ID (from https://app.nexus.xyz/nodes): " NODE_ID

# Step 12: Start node
echo "🚀 Starting Node..."
nexus-network start --node-id "$NODE_ID"

echo "✅ Done. Nexus Node is running."
