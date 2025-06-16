# 🚀 GitHub DevOps Bootstrap Script

A bash script to **instantly configure Git and GitHub access** on a fresh Linux system (VM, laptop, VPS, etc.).  
Designed for **DevOps engineers**, developers, or anyone setting up a new OS.

---

## 🎯 Purpose

This script:

- ✅ Installs Git, curl, jq, OpenSSH (if missing)
- ✅ Sets up your global Git username and email
- ✅ Generates a new SSH key (or uses your existing one)
- ✅ Offers to **automatically add the SSH key to your GitHub account** via API
- ✅ Configures Git to always use SSH (no password prompts)
- ✅ Tests SSH connection to GitHub to confirm success

---

## 🔐 Why It Matters

As a DevOps or developer, you often:

1. Reinstall or work on fresh Linux machines
2. Need to reconnect Git/GitHub quickly
3. Want a consistent, secure setup (no HTTPS password prompts)

This script helps you get there in **a single command**.

---

## ⚙️ Requirements

- Linux system (Debian/Ubuntu – others coming soon)
- `sudo` privileges (for installing packages)
- A GitHub account
- *(Optional)* A [GitHub Personal Access Token (PAT)](https://github.com/settings/tokens) with `admin:public_key` scope for automatic SSH key upload

---

## 📦 Installation

```bash
git clone https://github.com/your-user/devops-bootstrap.git
cd devops-bootstrap
chmod +x setup_git_github.sh
./setup_git_github.sh

