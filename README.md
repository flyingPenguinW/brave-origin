<div align="center">

# 🦁 Brave Origin

> **Turn Brave into Brave Origin — fully debloated, privacy-hardened, and actually fast.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-blue)](#)
[![Stars](https://img.shields.io/github/stars/flyingPenguinW/brave-origin?style=flat&color=gold)](#)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)](#)

### ☕ [Buy Me a Coffee](https://buymeacoffee.com/AilieIsQueen)

</div>

---

## ✨ What It Does

Brave is great, but it ships with **Rewards, Wallet, VPN, Leo AI, News, Talk, Tor, Speedreader, Playlist, Wayback Machine, Web Discovery, telemetry** — a ton of features most people never touch. This project kills them all at the **system policy level**, meaning they don't just get hidden — they stop loading entirely. No background processes, no UI clutter, no wasted RAM.

| Feature | Effect |
|---------|--------|
| Leo AI | Disabled at root level |
| Brave Rewards / BAT | Disabled at root level |
| Crypto Wallet + Web3 | Disabled at root level |
| VPN upsells | Disabled at root level |
| Brave News feed | Disabled at root level |
| Brave Talk | Disabled at root level |
| Tor mode | Disabled at root level |
| Speedreader | Disabled at root level |
| Wayback Machine | Disabled at root level |
| Playlist | Disabled at root level |
| P3A / Stats / Web Discovery | Disabled at root level |
| Sync | Disabled at root level |

...and **keeps Shields** (ad/tracker blocking) fully intact.

---

## 🚀 One-Click Setup

Place **BO.png** (your custom icon) in the same folder as the script for automatic icon replacement.

### 🐧 Linux

```bash
chmod +x setup.sh && sudo ./setup.sh
```

### 🪟 Windows

- **Normal install:** Right-click `setup.bat` → **Run as Administrator**
- **Store install:** Run `setup.bat` as Admin — it will detect Store path and handle it

### 🍎 macOS

```bash
chmod +x setup_mac.sh && sudo ./setup_mac.sh
```

### 🤖 Android

See [Android note](#android).

**Verify:** Open `brave://policy` — every switch should show **"Enabled"**.

---

## 📋 Policy Reference

### Brave Bloat
| Policy | Effect |
|--------|--------|
| `BraveRewardsDisabled` | Disabled at root level |
| `BraveWalletDisabled` | Disabled at root level |
| `BraveVPNDisabled` | Disabled at root level |
| `BraveAIChatEnabled = false` | Disabled at root level |
| `BraveNewsDisabled` | Disabled at root level |
| `BraveTalkDisabled` | Disabled at root level |
| `TorDisabled` | Disabled at root level |
| `BraveSpeedreaderEnabled = false` | Disabled at root level |
| `BraveWaybackMachineEnabled = false` | Disabled at root level |
| `BravePlaylistEnabled = false` | Disabled at root level |

### Telemetry & Network
| Policy | Effect |
|--------|--------|
| `BraveP3AEnabled = false` | Disabled at root level |
| `BraveStatsPingEnabled = false` | Disabled at root level |
| `BraveWebDiscoveryEnabled = false` | Disabled at root level |
| `SyncDisabled` | Disabled at root level |
| `BackgroundModeEnabled = false` | Disabled at root level |
| `MetricsReportingEnabled = false` | Disabled at root level |
| `NetworkPredictionOptions = 0` | **Enabled** (DNS prefetch + preconnect — speed fix) |

### Features
| Policy | Effect |
|--------|--------|
| `PasswordManagerEnabled = false` | Disabled at root level |
| `AutofillAddressEnabled = false` | Disabled at root level |
| `AutofillCreditCardEnabled = false` | Disabled at root level |
| `TranslateEnabled = false` | Disabled at root level |
| `DeveloperToolsAvailability = 2` | Disabled at root level |
| `SpellcheckEnabled = false` | Disabled at root level |
| `SearchSuggestEnabled = false` | Disabled at root level |

### UI Tweaks
| Policy | Effect |
|--------|--------|
| `BookmarkBarEnabled = false` | Disabled at root level |
| `ShowHomeButton = false` | Disabled at root level |
| `HomepageLocation = about:blank` | Set to blank |
| `NewTabPageLocation = about:blank` | Set to blank |

### Search Engines
Restricted to **Brave Search · Google · DuckDuckGo** only.

### RAM Savings
| Policy | Effect |
|--------|--------|
| `HighEfficiencyModeEnabled = true` | Memory Saver enabled |
| `BackgroundModeEnabled = false` | Disabled at root level |
| All feature backends unloaded | RAM freed |

---

## ⚡ Speed Fix

Pages loading slow? `NetworkPredictionOptions` is set to **0** (full prediction) — this re-enables:

- ✅ DNS prefetching
- ✅ TCP/SSL preconnection
- ✅ Prerendering

If still slow, your secure DNS provider might be the bottleneck. Change in `brave://settings/privacy`:

| Provider | Template |
|----------|----------|
| **AdGuard** (default) | `https://dns.adguard-dns.com/dns-query` |
| **Cloudflare** (fast) | `https://cloudflare-dns.com/dns-query` |
| **Quad9** (secure) | `https://dns.quad9.net/dns-query` |

---

## 🧩 Post-Setup (Do These Once)

```
brave://flags/#brave-sidebar            → Disabled
brave://flags/#enable-zero-copy          → Enabled
brave://flags/#enable-parallel-downloading → Enabled
brave://settings/appearance              → "Use system title bar and borders" ON
brave://settings/system                  → "Memory Saver" ON
```

---

## 🎨 Custom Icon

Drop **BO.png** in the same folder as the script. The setup will:

| Platform | What happens |
|----------|-------------|
| **Linux** | Replaces `/usr/share/icons/hicolor/*/apps/brave-browser.png` — applies system-wide |
| **macOS** | Places the icon in the Brave Origin launcher app (open that instead of normal Brave) |
| **Windows (normal)** | Creates desktop shortcut with BO.ico — place a `BO.ico` file alongside the script |
| **Windows (Store)** | Creates desktop shortcut with BO.ico — same requirement |

**Note:** Windows shortcut icons require `.ico` format. [Convert BO.png to BO.ico](https://convertio.co/png-ico/) and place it in the folder.

---

## 📂 File Reference

| File | Platform | Purpose |
|------|----------|---------|
| `policies.json` | All | Complete policy definitions |
| `setup.sh` | Linux | Auto-deploy + icon swap + desktop entry patch |
| `setup.bat` | Windows | Reg import + shortcut (normal & Store) + icon |
| `setup_mac.sh` | macOS | Plist deployment + launcher app with custom icon |
| `brave-origin.reg` | Windows | Manual registry import |

---

## 🤖 Android

Android Brave **does not support enterprise policies**. However:

1. `brave://flags/#brave-sidebar` → **Disabled**
2. `brave://flags/#enable-parallel-downloading` → **Enabled**
3. Settings → Rewards / Wallet / Leo → disable individually

Root users: add `--disable-features=AIChat,BraveVPN` via `brave_app_flags`.

---

<div align="center">

### ☕ [Buy Me a Coffee](https://buymeacoffee.com/AilieIsQueen)

**Your support keeps this project maintained and improving!**

---

**Brave Origin** — *Privacy without the bloat.*

</div>
