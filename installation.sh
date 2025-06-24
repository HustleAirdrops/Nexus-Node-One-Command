#!/bin/bash

# ⛑️ Graceful exit on Ctrl+C
trap "echo -e '\n❌ Installation cancelled. Exiting safely.'; exit 1" INT

echo "🚀 Starting Nexus CLI Full Setup..."

# Step 1: Create and enter working dir
mkdir -p nexus-cli && cd nexus-cli

# Step 2: Install Rust silently with all default options
echo "🦀 Installing Rust with no prompts..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rust-init.sh
chmod +x rust-init.sh
RUSTUP_INIT_SKIP_PATH_CHECK=1 ./rust-init.sh -y

# Step 3: Load Rust environment
if [ -f "$HOME/.cargo/env" ]; then
    echo "🔁 Loading Rust environment..."
    source "$HOME/.cargo/env"
else
    echo "❌ Rust environment not found. Exiting."
    exit 1
fi

# Step 4: Add RISC-V target
echo "🎯 Adding RISC-V target..."
rustup target add riscv32i-unknown-none-elf

# Step 5: Update system
echo "🔄 Running apt update..."
sudo apt update

# Step 6: Install dependencies
echo "📦 Installing required packages..."
sudo apt install -y pkg-config libssl-dev protobuf-compiler

# Step 7: Install Nexus CLI with auto “yes” to terms
echo "⚙️ Installing Nexus CLI..."
curl https://cli.nexus.xyz/ | sh

# Step 8: Source all env files (for Termux/WSL/VPS)
for file in \
    "$HOME/.bashrc" \
    "$HOME/.zshrc" \
    "$HOME/.profile" \
    "$HOME/.cargo/env" \
    "/data/data/com.termux/files/home/.bashrc"
do
    [ -f "$file" ] && source "$file"
done

# Step 9: Get Node ID from user
read -p "📝 Enter your Node ID: " NODE_ID

# Step 10: Start Node
echo "🚀 Starting Nexus Node..."
nexus-network start --node-id "$NODE_ID"

echo "✅ Setup complete. Nexus Node running."
