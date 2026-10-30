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

Brave includes optional services such as **Rewards, Wallet, VPN, News, Talk, Tor, Playlist and Wayback Machine**. This project uses managed policies to disable selected features and telemetry. The effect depends on whether your Brave version supports each policy; reduced RAM use or faster browsing is not guaranteed.

It also covers features you may actually use (**Leo AI, Speedreader, sync, DevTools, autofill...**). That is why there are two levels, and you choose what stays:

- **Hard** (recommended) - removes the bloat and telemetry, keeps the useful features.
- **Extreme** - stricter preset that also disables optional browser features.
- **Custom** - pick Hard / Extreme / Skip per category.

Summary of the presets (the scripts show a similar comparison):

**Same in both:** Safe Browsing = Standard (Enhanced shares more visited links).

**Disabled in both levels**

| Setting | Extreme | Hard |
|---|---|---|
| Rewards / Wallet / VPN / News / Tor | off | off |
| Telemetry & tracking | off | off |
| Password manager | off | off |
| Search suggestions | off | off |
| Background mode | off | off |

**Differences**

| Setting | Extreme | Hard |
|---|---|---|
| Leo AI | off | **User settings** (available, not forced on) |
| Speedreader | off | **ON** |
| Sync | off (all profiles) | **User settings** (choose per profile) |
| Add profile / guest mode | blocked | **User settings** (not restricted by this script) |
| Address autofill | off | **ON** |
| Card autofill | off | **User settings** |
| Translate & spellcheck | off | **ON** |
| Bookmarks bar | hidden | **shown** |
| New tab page | about:blank | **unchanged** |
| DevTools | off | **ON** |
| DNS-over-HTTPS | forced (AdGuard) | **your choice** (not locked) |
| Default search engine | Brave Search | **your choice** (not overridden) |

**Both levels also:** homepage = `about:blank`, Memory Saver ON, HTTPS upgrades ON. Shields (ad/tracker blocking) stay fully intact.

---

## 🚀 One-Click Setup

All three scripts (Linux, Windows, macOS) work the same way: they show a menu, offer a backup, and write the policies for the level you choose.

### 🐧 Linux

```bash
chmod +x setup.sh && ./setup.sh
```

### 🪟 Windows

- **Normal install:** Right-click `setup.bat` → **Run as Administrator**
- **Store install:** Run `setup.bat` as Admin — it will detect Store path and handle it

### 🍎 macOS

```bash
chmod +x setup_mac.sh && ./setup_mac.sh
```

### Debloat levels

The scripts show this menu:

1. **Hard** - same debloat, but keeps features you may actually use (recommended)
2. **Extreme** - stricter preset that also disables optional browser features
3. **Custom** - choose Hard / Extreme / Skip per category
4. **Restore** - back to the original Brave state (from backup)

The comparison of what each level does is in the "What It Does" section at the top.

Policies lock the matching options in `brave://settings` ("managed by your organization"). Use **Restore** to undo.

### Backup & restore

Before changing anything the script offers to back up your current Brave policies (strongly recommended). An existing backup is never overwritten, so running the script again keeps your original state.

| Platform | Backup location | Restore |
|---|---|---|
| Linux | `~/.brave-origin-backup` (policy file + desktop entry) | `./setup.sh --restore` |
| Windows | `%USERPROFILE%\.brave-origin-backup` (registry export of the Brave policy key) | `setup.bat /restore` |
| macOS | `~/.brave-origin-backup` (managed plist + launcher app) | `./setup_mac.sh --restore` |

You can also run the script again and choose **4) Restore**. Without a backup, restore only removes the policy values created by the script (other policies are left alone).

Manual flags and settings in `brave://flags` / `brave://settings` are not touched by the scripts - revert them by hand if you changed them.

### 🤖 Android

See [Android note](#android).

**Verify:** Open `brave://policy` — the policies of the level you chose should be listed with status **OK** (see the [Policy Reference](#-policy-reference) for the values).

---

## 📋 Policy Reference

Two tables cover the presets: shared settings appear once, and only the differences have Extreme / Hard columns. Each row describes the feature first; the policy name and exact value are included for troubleshooting.

**How to read the tables:**

- **Off / On:** the script writes a managed value. The value in backticks is what it writes, not necessarily the feature's on/off state: a policy named `SyncDisabled` disables sync when its value is `true`.
- **User settings:** the script does **not** set that policy. Your profile's preference or Brave's default applies, unless another policy controls it. This does not mean the feature is forced on. For example, Hard leaves Leo available but does not enable it if you previously turned it off.
- **Custom:** applies these settings only for the categories you select. Skip omits that category's policies; it does not restore values previously overwritten by the script.

### Shared settings — Hard and Extreme

| Setting / policy | Applied in both levels |
|---|---|
| Safe Browsing · `SafeBrowsingProtectionLevel` | Standard protection (`1`) |
| Rewards · `BraveRewardsDisabled` | Off (`true`) |
| Wallet · `BraveWalletDisabled` | Off (`true`) |
| VPN · `BraveVPNDisabled` | Off (`true`) |
| News · `BraveNewsDisabled` | Off (`true`) |
| Talk · `BraveTalkDisabled` | Off (`true`) |
| Tor windows · `TorDisabled` | Off (`true`) |
| Playlist · `BravePlaylistEnabled` | Off (`false`) |
| Wayback Machine · `BraveWaybackMachineEnabled` | Off (`false`) |
| P3A telemetry · `BraveP3AEnabled` | Off (`false`) |
| Usage statistics ping · `BraveStatsPingEnabled` | Off (`false`) |
| Web Discovery · `BraveWebDiscoveryEnabled` | Off (`false`) |
| Metrics reporting · `MetricsReportingEnabled` | Off (`false`) |
| User feedback · `UserFeedbackAllowed` | Off (`false`) |
| Ad Topics · `PrivacySandboxAdTopicsEnabled` | Off (`false`) |
| Privacy Sandbox prompt · `PrivacySandboxPromptEnabled` | Off (`false`) |
| Site-suggested ads · `PrivacySandboxSiteEnabledAdsEnabled` | Off (`false`) |
| Websites checking for saved payment methods · `PaymentMethodQueryEnabled` | Off (`false`) |
| Alternate error pages · `AlternateErrorPagesEnabled` | Off (`false`) |
| Search suggestions · `SearchSuggestEnabled` | Off (`false`) |
| Password manager · `PasswordManagerEnabled` | Off (`false`) |
| Online spellcheck service · `SpellcheckServiceEnabled` | Off (`false`); separate from local spellcheck |
| Background mode · `BackgroundModeEnabled` | Off (`false`); do not keep background apps running after the last window closes |
| Home button · `ShowHomeButton` | Hidden (`false`) |
| Default-browser checks · `DefaultBrowserSettingEnabled` | Off (`false`); does not change your OS default browser |
| Home button destination · `HomepageLocation` | Blank page (`about:blank`); not the new tab or startup page |
| Network prediction · `NetworkPredictionOptions` | Allowed on any network (`0`); not disabled by these presets |
| Memory Saver · `HighEfficiencyModeEnabled` | On (`true`) |
| Component updates · `ComponentUpdatesEnabled` | Allowed (`true`) |
| HTTPS upgrades · `HttpsUpgradesEnabled` | On (`true`) |
| Private windows · `IncognitoModeAvailability` | Allowed (`0`) |
| Download restrictions · `DownloadRestrictions` | No policy restriction (`0`); Safe Browsing remains on |
| Download location prompt · `PromptForDownloadLocation` | On (`true`) |
| Printing · `PrintingEnabled` | Allowed (`true`) |

### Differences — what Hard keeps or leaves to you

| Setting / policy | Extreme | Hard |
|---|---|---|
| Leo AI · `BraveAIChatEnabled` | Off (`false`) | On (`true`) |
| Speedreader · `BraveSpeedreaderEnabled` | Off (`false`) | On (`true`) |
| Sync · `SyncDisabled` | Off for all profiles (`true`) | On (`true`) |
| Adding profiles · `BrowserAddPersonEnabled` | Blocked (`false`) | On (`true`) |
| Guest mode · `BrowserGuestModeEnabled` | Blocked (`false`) | On (`true`) |
| Address autofill · `AutofillAddressEnabled` | Off (`false`) | On (`true`) |
| Card autofill · `AutofillCreditCardEnabled` | Off (`false`) | On (`true`) |
| Translation · `TranslateEnabled` | Off (`false`) | On (`true`) |
| Local spellcheck · `SpellcheckEnabled` | Off (`false`) | On (`true`) |
| Bookmarks bar · `BookmarkBarEnabled` | Hidden (`false`) | Shown (`true`) |
| New tab page · `NewTabPageLocation` | Blank page (`about:blank`) | Default |
| DevTools · `DeveloperToolsAvailability` | Blocked (`2`) | Allowed (`1`) |
| Secure DNS mode · `DnsOverHttpsMode` | DoH only (`secure`), no unencrypted fallback | **User settings** |
| Secure DNS provider · `DnsOverHttpsTemplates` | AdGuard DoH¹ | **User settings** |
| Managed default search · `DefaultSearchProviderEnabled` | Enabled (`true`) | **User settings** |
| Default search name · `DefaultSearchProviderName` | Brave Search (`Brave Search`) | **User settings** |
| Default search URL · `DefaultSearchProviderSearchURL` | Brave Search URL² | **User settings** |
| Managed search engines · `ManagedSearchEngines` | Brave Search, Google, DuckDuckGo | **User settings** |

¹ AdGuard DoH template: `https://dns.adguard-dns.com/dns-query`. In Hard, choose your provider at `brave://settings/security`.

² Brave Search URL: `https://search.brave.com/search?q={searchTerms}`. Hard leaves both your default engine and your engine list untouched.

The scripts write these policies in each platform's native format. For manual presets, use `policies.json` / `brave-origin.reg` for Extreme, or `policies-hard.json` / `brave-origin-hard.reg` for Hard. Importing a preset directly does not run the backup or menu.

---

## ⚡ Speed Fix

Pages loading slow? `NetworkPredictionOptions` is set to **0** (full prediction) — this re-enables:

- ✅ DNS prefetching
- ✅ TCP/SSL preconnection
- ✅ Prerendering

If still slow, your secure DNS provider might be the bottleneck:

- **Hard:** DNS is not locked. Change it in Brave settings (search for "secure DNS"; usually `brave://settings/security`).
- **Extreme:** the provider is forced by policy (AdGuard) and cannot be changed in settings. Edit `DnsOverHttpsTemplates` in `setup.sh` / `setup.bat` / `setup_mac.sh` and run it again.

| Provider | Template |
|----------|----------|
| **AdGuard** (default in Extreme) | `https://dns.adguard-dns.com/dns-query` |
| **Cloudflare** (fast) | `https://cloudflare-dns.com/dns-query` |
| **Quad9** (secure) | `https://dns.quad9.net/dns-query` |

---

## 🧩 Post-Setup (Do These Once)

```
brave://flags/#brave-news-sidebar          → Disabled
brave://flags/#enable-parallel-downloading → Enabled
brave://settings/appearance                → "Use system title bar and borders" ON
brave://settings/system                    → "Memory Saver" ON
Optional:
brave://settings/security                  → "Use secure DNS" → choose a provider (Hard only)
brave://flags/#enable-zero-copy            → Enabled - faster browsing. Problems may occur on older GPUs. If you get problems or artifacts leave default.
```

> **DoH (DNS-over-HTTPS)** encrypts the website lookups your browser makes, so your ISP and the local network can't see which sites you visit. It does not hide your IP and does not block ads.

---

## 🎨 Replacing the Brave Logo

The setup scripts do **not** touch the Brave icon. If you want to use a custom logo, do it manually per platform:

### Linux
```bash
# Replace the system Brave icon (256x256 is the app menu size)
sudo cp /path/to/your-logo.svg /usr/share/icons/hicolor/scalable/apps/brave-browser.svg
# Or for PNG:
# sudo cp /path/to/your-logo.png /usr/share/icons/hicolor/256x256/apps/brave-browser.png
sudo gtk-update-icon-cache /usr/share/icons/hicolor/
```

### macOS
Replace the app icon in the `.app` bundle:
```bash
# Convert your .png to .icns first
sudo cp /path/to/your-logo.icns /Applications/Brave\ Browser.app/Contents/Resources/app.icns
# Clear icon cache
sudo rm -rf /Library/Caches/com.apple.iconservices.store
```

### Windows
Create a desktop shortcut and point its icon to your `.ico` file:
1. Convert your logo to `.ico` (e.g. [convertio.co](https://convertio.co/png-ico/))
2. Right-click the Brave shortcut → **Properties** → **Change Icon** → browse to your `.ico`
3. For Store installs, create a shortcut from `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\Application\brave.exe`

---

## 📂 File Reference

| File | Platform | Purpose |
|------|----------|---------|
| `policies.json` | All | Complete policy definitions (Extreme) |
| `policies-hard.json` | All | Complete policy definitions (Hard) |
| `setup.sh` | Linux | Menu, backup/restore, policy deploy + desktop entry patch |
| `setup.bat` | Windows | Menu, backup/restore, registry policies + shortcut flags (normal & Store) |
| `setup_mac.sh` | macOS | Menu, backup/restore, plist deployment + launcher app with flags |
| `brave-origin.reg` | Windows | Manual registry import (Extreme) |
| `brave-origin-hard.reg` | Windows | Manual registry import (Hard) |

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
