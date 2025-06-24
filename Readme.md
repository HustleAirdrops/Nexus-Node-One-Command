# 🚀 Nexus CLI: One-Command Installation Guide

Set up your Nexus node in **minutes** with a single command! This guide covers both VPS and local PC (WSL) setups.

---

## 1️⃣ (VPS Users Only) Start a Screen Session

Keep your node running even if you disconnect:

```bash
screen -S nexus
```

---

## 2️⃣ One-Command Installation

Copy & paste the command below to install and auto-run Nexus CLI:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/HustleAirdrops/Nexus-Node-One-Command/main/installation.sh)
```

✨ The script will handle the entire setup and automatically start your node.

> **⚠️ During installation, you will be prompted to enter your Node ID.**

### 🆔 How to Get Your Node ID

1. Open [https://app.nexus.xyz/nodes](https://app.nexus.xyz/nodes) 🌐
2. Login and copy your **Node ID** from the dashboard.
3. Paste it into the terminal when the script asks for it.

### (VPS Users Only) Detach from Screen

After installation, you can safely detach from the screen session (your node will keep running):

```bash
Ctrl + A, then D
```

---

## 3️⃣ Starting Your Node (Next Time)

Whenever you want to start your node again, use:

```bash
nexus-network start --node-id <Node_ID>
```

🔁 Replace `<Node_ID>` with your actual Node ID.

---

## 💬 Need Help?

- **Support:** [@Legend_Aashish](https://t.me/Legend_Aashish) 👨‍💻
- **Guides, Videos & Updates:** [@Hustle_Airdrops](https://t.me/Hustle_Airdrops) 📢
- **Stay ahead — [Join the channel now!](https://t.me/Hustle_Airdrops) 🚀**

---

✨ Happy Node Running! ✨
