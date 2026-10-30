#!/usr/bin/env bash
set -e

###############################################################################
# BRAVE ORIGIN - Complete debloat & speed fix + icon swap
# Platform: Linux
# Usage:   chmod +x setup.sh && ./setup.sh            (install)
#          ./setup.sh --restore                       (undo, from backup)
#          (also works with: sudo ./setup.sh)
# Icon:    Place BO.png in same folder (optional)
# Verif:   brave://policy
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POLICY_DIR="/etc/brave/policies/managed"
POLICY_FILE="$POLICY_DIR/brave-origin.json"

# Resolve the real user's home, so it also works when started with sudo
# (under sudo $HOME can be /root).
REAL_USER="${SUDO_USER:-$(id -un)}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
REAL_HOME="${REAL_HOME:-$HOME}"
LOCAL_APPS="$REAL_HOME/.local/share/applications"
LOCAL_DESKTOP="$LOCAL_APPS/brave-browser.desktop"
BACKUP_DIR="$REAL_HOME/.brave-origin-backup"

ask_yn() {
  local reply
  while true; do
    read -r -p "$1 [y/n]: " reply
    case "$reply" in
      [Yy]|[Yy][Ee][Ss]) return 0 ;;
      [Nn]|[Nn][Oo]) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

# --- Restore mode: ./setup.sh --restore ---
if [ "${1:-}" = "--restore" ]; then
  echo "=========================================="
  echo "  Brave Origin - Restore"
  echo "=========================================="
  echo ""
  if [ -d "$BACKUP_DIR" ]; then
    echo "[*] Using backup: $BACKUP_DIR"
  else
    echo "[!] No backup found in $BACKUP_DIR."
    echo "    Restore will just remove the files created by this script"
    echo "    (policy file and local desktop entry)."
  fi
  ask_yn "Restore Brave to its previous state?" || { echo "Aborted."; exit 0; }

  echo "[1] Policies..."
  if [ -f "$BACKUP_DIR/brave-origin.json" ]; then
    sudo cp -p "$BACKUP_DIR/brave-origin.json" "$POLICY_FILE"
  else
    sudo rm -f "$POLICY_FILE"
  fi

  echo "[2] Desktop entry..."
  if [ -f "$BACKUP_DIR/brave-browser.desktop" ]; then
    cp -p "$BACKUP_DIR/brave-browser.desktop" "$LOCAL_DESKTOP"
  else
    rm -f "$LOCAL_DESKTOP"
  fi
  update-desktop-database "$LOCAL_APPS" 2>/dev/null || true

  echo ""
  echo "Done. Restart Brave and check brave://policy"
  echo "Manual flags/settings (brave://flags, brave://settings) are not"
  echo "touched by this script - revert them by hand if you changed them."
  exit 0
fi

echo "=========================================="
echo "  Brave Origin - Linux Setup"
echo "  ☕ buymeacoffee.com/AilieIsQueen"
echo "=========================================="
echo ""

# --- Detect browser binary ---
BRAVE_BIN=""
for b in brave-browser brave-browser-stable brave-browser-beta brave-browser-nightly; do
  command -v "$b" &>/dev/null && BRAVE_BIN="$b" && break
done

if [ -z "$BRAVE_BIN" ]; then
  echo "[!] Brave not found in PATH. Install it first."
  exit 1
fi
echo "[*] Detected: $(command -v "$BRAVE_BIN")"

# --- 0. Backup ---
echo ""
echo "A backup lets you undo everything later with: ./setup.sh --restore"
if [ -d "$BACKUP_DIR" ]; then
  echo "[*] Backup already exists ($BACKUP_DIR) - keeping the original one."
elif ask_yn "Do you want to create a Brave backup? (strongly recommended)"; then
  mkdir -p "$BACKUP_DIR"
  if [ -f "$POLICY_FILE" ]; then
    sudo cp -p "$POLICY_FILE" "$BACKUP_DIR/brave-origin.json"
    sudo chown "$(id -u "$REAL_USER"):$(id -g "$REAL_USER")" "$BACKUP_DIR/brave-origin.json"
  fi
  if [ -f "$LOCAL_DESKTOP" ]; then
    cp -p "$LOCAL_DESKTOP" "$BACKUP_DIR/brave-browser.desktop"
  fi
  chown -R "$(id -u "$REAL_USER"):$(id -g "$REAL_USER")" "$BACKUP_DIR" 2>/dev/null || true
  echo "[*] Backup saved to $BACKUP_DIR"
else
  echo "[!] Continuing WITHOUT backup."
  ask_yn "Are you sure?" || { echo "Aborted."; exit 0; }
fi
echo ""

# --- 1. Deploy enterprise policies ---
echo "[1] Deploying system policies..."
sudo mkdir -p "$POLICY_DIR"

sudo tee "$POLICY_FILE" > /dev/null <<'POLICY_EOF'
{
  "_note": "Brave Origin - debloat + speed fix",
  "BraveRewardsDisabled": true,
  "BraveWalletDisabled": true,
  "BraveVPNDisabled": true,
  "BraveAIChatEnabled": false,
  "BraveNewsDisabled": true,
  "BraveTalkDisabled": true,
  "TorDisabled": true,
  "BraveSpeedreaderEnabled": false,
  "BraveWaybackMachineEnabled": false,
  "BravePlaylistEnabled": false,
  "BraveP3AEnabled": false,
  "BraveStatsPingEnabled": false,
  "BraveWebDiscoveryEnabled": false,
  "SyncDisabled": true,
  "BackgroundModeEnabled": false,
  "MetricsReportingEnabled": false,
  "ComponentUpdatesEnabled": true,
  "DnsOverHttpsMode": "secure",
  "DnsOverHttpsTemplates": "https://dns.adguard-dns.com/dns-query",
  "SafeBrowsingProtectionLevel": 2,
  "AlternateErrorPagesEnabled": false,
  "NetworkPredictionOptions": 0,
  "PrivacySandboxAdTopicsEnabled": false,
  "PrivacySandboxPromptEnabled": false,
  "PrivacySandboxSiteEnabledAdsEnabled": false,
  "PaymentMethodQueryEnabled": false,
  "UserFeedbackAllowed": false,
  "SearchSuggestEnabled": false,
  "SpellcheckEnabled": false,
  "SpellcheckServiceEnabled": false,
  "HttpsUpgradesEnabled": true,
  "PasswordManagerEnabled": false,
  "AutofillAddressEnabled": false,
  "AutofillCreditCardEnabled": false,
  "TranslateEnabled": false,
  "HighEfficiencyModeEnabled": true,
  "DeveloperToolsAvailability": 2,
  "IncognitoModeAvailability": 0,
  "BrowserAddPersonEnabled": false,
  "BrowserGuestModeEnabled": false,
  "DefaultBrowserSettingEnabled": false,
  "BookmarkBarEnabled": false,
  "ShowHomeButton": false,
  "HomepageLocation": "about:blank",
  "NewTabPageLocation": "about:blank",
  "ManagedSearchEngines": [
    {"name": "Brave Search",      "keyword": "search.brave.com",        "search_url": "https://search.brave.com/search?q={searchTerms}",      "suggest_url": "https://search.brave.com/api/suggest?q={searchTerms}",      "encoding": "UTF-8", "favicon_url": "https://brave.com/favicon.ico"},
    {"name": "Google",            "keyword": "google.com",              "search_url": "https://www.google.com/search?q={searchTerms}",      "suggest_url": "https://www.google.com/complete/search?output=chrome&q={searchTerms}", "encoding": "UTF-8", "favicon_url": "https://www.google.com/favicon.ico"},
    {"name": "DuckDuckGo",        "keyword": "duckduckgo.com",          "search_url": "https://duckduckgo.com/?q={searchTerms}",            "suggest_url": "https://duckduckgo.com/ac/?q={searchTerms}&type=list",      "encoding": "UTF-8", "favicon_url": "https://duckduckgo.com/favicon.ico"}
  ],
  "DefaultSearchProviderEnabled": true,
  "DefaultSearchProviderName": "Brave Search",
  "DefaultSearchProviderSearchURL": "https://search.brave.com/search?q={searchTerms}",
  "DownloadRestrictions": 0,
  "PromptForDownloadLocation": true,
  "PrintingEnabled": true
}
POLICY_EOF

sudo chmod 644 "$POLICY_FILE"
echo "    -> $POLICY_FILE"

# --- 2. Patch the Brave desktop entry with debloat + speed flags ---
echo "[2] Patching desktop entry..."

mkdir -p "$LOCAL_APPS"

SYS_DESKTOP=$(ls /usr/share/applications/brave*.desktop 2>/dev/null | head -1)
if [ -n "$SYS_DESKTOP" ]; then
  cp "$SYS_DESKTOP" "$LOCAL_DESKTOP"
fi

if [ -f "$LOCAL_DESKTOP" ]; then
  sed -i 's|^Exec=brave-browser\( .*\)\?$|Exec=brave-browser --disable-features=AIChat,BraveVPN --enable-features=HighEfficiencyMode\1|' "$LOCAL_DESKTOP"
  sed -i 's|^Exec=brave-browser-stable\( .*\)\?$|Exec=brave-browser-stable --disable-features=AIChat,BraveVPN --enable-features=HighEfficiencyMode\1|' "$LOCAL_DESKTOP"
  update-desktop-database "$LOCAL_APPS" 2>/dev/null || true
  echo "    -> $LOCAL_DESKTOP"
else
  cat > "$LOCAL_DESKTOP" << EOF
[Desktop Entry]
Version=1.0
Name=Brave Browser
Comment=Brave Browser (debloated)
Exec=$(command -v "$BRAVE_BIN") --disable-features=AIChat,BraveVPN --enable-features=HighEfficiencyMode %U
Icon=brave-browser
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;
StartupNotify=true
EOF
  echo "    -> created $LOCAL_DESKTOP"
fi
chown "$(id -u "$REAL_USER"):$(id -g "$REAL_USER")" "$LOCAL_DESKTOP" 2>/dev/null || true

# --- 4. Flush DNS (speed helper) ---
command -v resolvectl &>/dev/null && sudo resolvectl flush-caches 2>/dev/null || true

echo ""
echo "=========================================="
echo "  DONE"
echo "  ☕ buymeacoffee.com/AilieIsQueen"
echo "=========================================="
echo ""
echo "Manual steps (do once in Brave):"
echo ""
echo "  brave://flags/#brave-sidebar        -> Disabled"
echo "  brave://flags/#enable-zero-copy      -> Enabled"
echo "  brave://flags/#enable-parallel-downloading -> Enabled"
echo "  brave://settings/appearance          -> Use system title bar and borders ON"
echo "  brave://settings/system              -> Memory Saver ON"
echo ""
echo "Verify: brave://policy"
echo ""
