# 🧅 Ultra-Low Resource Tor SOCKS5 Proxy

A fully automated, ultra-lightweight bash runner for Tor designed to consume minimal CPU (1%–3%) and RAM (~15MB–20MB). It automatically handles downloading, dynamic `torrc` configuration, disk usage monitoring, and automated background cleanup.

The proxy is configured to expose SOCKS5 across all interfaces on port **`0.0.0.0:port`**.

---

## ✨ Features

- **Dynamic Setup:** Automatically downloads the official Tor Expert Bundle if not present locally.
- **Ultra-Low Memory:** Tuned to run smoothly in limited-memory environments (15–20MB RAM).
- **Minimal CPU Overhead:** Prevents background circuit build loops to keep CPU usage between 1% and 3%.
- **Automated Cache & Log Cleanup:**
  - Deletes logs larger than 1MB hourly.
  - Automatically sweeps `.tmp` cache and cached descriptors.
  - Aggressive emergency cleanup if disk usage exceeds 80–85%.
- **Direct SOCKS5 Binding:** Exposes port `port` directly on `0.0.0.0`.

---

## ⚙️ Configuration Details

| Setting | Value | Description |
| :--- | :--- | :--- |
| **SOCKS Port** | `0.0.0.0:port` | Listens for incoming SOCKS5 connections on all interfaces |
| **Data Directory** | `./tor-data` | Stores Tor state and descriptor caches |
| **Max Memory In Queues** | `8 MB` | Strict memory queuing limit |
| **Circuit Lifetime** | `10s` | Quick circuit dirtiness turnover (`MaxCircuitDirtiness 10`) |
| **Process Priority** | `nice -n 19` | Lowest OS scheduling priority to preserve host resources |

---

## 🚀 Quick Start

### 1. Prerequisites
Ensure the following basic CLI utilities are installed on your Linux system:
```bash
sudo apt update && sudo apt install -y curl tar awk sed
