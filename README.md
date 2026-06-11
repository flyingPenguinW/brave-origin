<div align="center">

# 🦁 Brave Origin

> **Turn Brave into Brave Origin — fully debloated, privacy-hardened, and actually fast.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-blue)](#)
[![Stars](https://img.shields.io/github/stars/AilieIsQueen/brave-origin?style=flat&color=gold)](#)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)](#)

</div>

---

## ✨ What It Does

Brave is great, but it ships with **Rewards, Wallet, VPN, Leo AI, News, Talk, Tor, Speedreader, Playlist, Wayback Machine, Web Discovery, telemetry** — a ton of features most people never touch. This project kills them all at the **system policy level**, meaning they don't just get hidden — they stop loading entirely. No background processes, no UI clutter, no wasted RAM.

| Before | After |
|--------|-------|
| 🧠 Leo AI in your sidebar | 🚫 Completely removed |
| 💰 Rewards / BAT ads | 🚫 Disabled at kernel level |
| 👛 Crypto Wallet + Web3 | 🚫 Gutted entirely |
| 🔒 VPN upsells everywhere | 🚫 Vanished |
| 📰 Brave News feed | 🚫 Gone |
| 🎙️ Brave Talk button | 🚫 Zapped |
| 🌐 Tor mode | 🚫 Removed |
| 📊 P3A / Stats / WDP telemetry | 🚫 Blocked |

...and **keeps Shields** (ad/tracker blocking) fully intact.

---

## 🚀 One-Click Setup

### 🐧 Linux

```bash
sudo mkdir -p /etc/brave/policies/managed/
sudo cp policies.json /etc/brave/policies/managed/
```

Or use the auto-deployer:

```bash
chmod +x setup.sh && sudo ./setup.sh
```

### 🪟 Windows

Right-click `setup.bat` → **Run as Administrator**.

### 🍎 macOS

```bash
chmod +x setup_mac.sh && sudo ./setup_mac.sh
```

### 🤖 Android

See [Android note](#android).

**Verify:** Open `brave://policy` — every switch should show **"Enabled"**.

---

## 📋 What Gets Disabled

### Brave Bloat
| Policy | Effect |
|--------|--------|
| `BraveRewardsDisabled` | Kills BAT rewards system |
| `BraveWalletDisabled` | Removes crypto wallet + Web3 |
| `BraveVPNDisabled` | Removes VPN button/prompts |
| `BraveAIChatEnabled = false` | Kills Leo AI assistant |
| `BraveNewsDisabled` | Removes News feed |
| `BraveTalkDisabled` | Removes Talk widget |
| `TorDisabled` | Removes Tor browsing |
| `BraveSpeedreaderEnabled = false` | Disables reader mode |
| `BraveWaybackMachineEnabled = false` | Disables 404 Wayback integration |
| `BravePlaylistEnabled = false` | Disables offline media save |

### Telemetry & Network
| Policy | Effect |
|--------|--------|
| `BraveP3AEnabled = false` | Stops anonymous usage pings |
| `BraveStatsPingEnabled = false` | Stops daily heartbeat |
| `BraveWebDiscoveryEnabled = false` | Stops URL collection for search index |
| `SyncDisabled` | Disables Brave Sync |
| `BackgroundModeEnabled = false` | Prevents background processes |
| `MetricsReportingEnabled = false` | Disables crash/metrics reporting |
| `NetworkPredictionOptions = 0` | **Enables** DNS prefetch + TCP preconnect (speed fix) |

### Features
| Policy | Effect |
|--------|--------|
| `PasswordManagerEnabled = false` | Disables built-in password manager |
| `AutofillAddressEnabled = false` | Disables address autofill |
| `AutofillCreditCardEnabled = false` | Disables credit card autofill |
| `TranslateEnabled = false` | Disables translation |
| `DeveloperToolsAvailability = 2` | Disables DevTools |
| `SpellcheckEnabled = false` | Disables spellcheck |
| `SearchSuggestEnabled = false` | Disables search suggestions |

### UI Tweaks
| Policy | Effect |
|--------|--------|
| `BookmarkBarEnabled = false` | Hides bookmark bar |
| `ShowHomeButton = false` | Hides home button |
| `HomepageLocation = about:blank` | Blank homepage |
| `NewTabPageLocation = about:blank` | Blank new tab (fastest) |
| `BookmarkBarEnabled = true` | Always show bookmarks bar |

### Search Engines
Restricted to **Brave Search · Google · DuckDuckGo** — no others allowed.

### RAM Savings
- `HighEfficiencyModeEnabled = true` (memory saver)
- `BackgroundModeEnabled = false`
- All feature backends unloaded instead of just hidden

---

## ⚡ Speed Fix

Pages loading slow? The culprit is usually `NetworkPredictionOptions`. This script sets it to **0** (full prediction), which re-enables:

- ✅ DNS prefetching
- ✅ TCP/SSL preconnection
- ✅ Prerendering

If pages are still slow, your secure DNS provider might be the bottleneck. Switch it in `brave://settings/privacy`:

| Provider | Template |
|----------|----------|
| **AdGuard** (default) | `https://dns.adguard-dns.com/dns-query` |
| **Cloudflare** (fast) | `https://cloudflare-dns.com/dns-query` |
| **Quad9** (secure) | `https://dns.quad9.net/dns-query` |

---

## 🧩 Post-Setup (Do These Once)

Open these in Brave and flip the switches:

```
brave://flags/#brave-sidebar            → Disabled
brave://flags/#enable-zero-copy          → Enabled
brave://flags/#enable-parallel-downloading → Enabled
brave://settings/appearance              → "Use system title bar and borders" ON
brave://settings/system                  → "Memory Saver" ON
```

---

## 📂 File Reference

| File | Platform | Purpose |
|------|----------|---------|
| `policies.json` | All | Complete policy definitions |
| `setup.sh` | Linux | Auto-deploy + desktop entry patch |
| `setup.bat` | Windows | Reg import + shortcut instructions |
| `setup_mac.sh` | macOS | Plist deployment + launcher app |
| `brave-origin.reg` | Windows | Manual registry import |

---

## 🤖 Android

Android Brave **does not support enterprise policies**. No amount of scripting can force it. However, you can still manually:

1. `brave://flags/#brave-sidebar` → **Disabled**
2. `brave://flags/#enable-parallel-downloading` → **Enabled**
3. Brave Settings → Rewards / Wallet / Leo → disable individually

For root users: create `/data/local/tmp/brave_flags` or modify the APK's `AndroidManifest.xml` to add `--disable-features=AIChat,BraveVPN`.

---

<div align="center">

## ☕ Support

If this saved you time and frustration, buy me a coffee:

[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-AilieIsQueen-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/AilieIsQueen)

**Your support keeps this project maintained and improving!**

---

**Brave Origin** — *Privacy without the bloat.*

</div>
