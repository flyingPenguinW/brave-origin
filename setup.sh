#!/usr/bin/env bash
set -e

###############################################################################
# BRAVE ORIGIN - Complete debloat & speed fix + icon swap
# Platform: Linux
# Usage:   chmod +x setup.sh && sudo ./setup.sh
# Icon:    Place BO.png in same folder (optional)
# Verif:   brave://policy
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POLICY_DIR="/etc/brave/policies/managed"
POLICY_FILE="$POLICY_DIR/brave-origin.json"

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

LOCAL_DESKTOP="$HOME/.local/share/applications/brave-browser.desktop"
mkdir -p "$HOME/.local/share/applications"

SYS_DESKTOP=$(ls /usr/share/applications/brave*.desktop 2>/dev/null | head -1)
if [ -n "$SYS_DESKTOP" ]; then
  cp "$SYS_DESKTOP" "$LOCAL_DESKTOP"
fi

if [ -f "$LOCAL_DESKTOP" ]; then
  sed -i 's|^Exec=brave-browser\( .*\)\?$|Exec=brave-browser --disable-features=AIChat,BraveVPN --enable-features=HighEfficiencyMode\1|' "$LOCAL_DESKTOP"
  sed -i 's|^Exec=brave-browser-stable\( .*\)\?$|Exec=brave-browser-stable --disable-features=AIChat,BraveVPN --enable-features=HighEfficiencyMode\1|' "$LOCAL_DESKTOP"
  update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
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
