#!/usr/bin/env bash
set -e

###############################################################################
# BRAVE ORIGIN - Complete debloat & speed fix + icon swap
# Platform: macOS
# Usage:   chmod +x setup_mac.sh && sudo ./setup_mac.sh
# Icon:    Place BO.png in same folder (optional)
# Verif:   brave://policy
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=========================================="
echo "  Brave Origin - macOS Setup"
echo "  ☕ buymeacoffee.com/AilieIsQueen"
echo "=========================================="
echo ""

# --- Detect which channel is installed ---
BRAVE_BUNDLE=""
BROWSER="Brave Browser"
if [ -d "/Applications/Brave Browser.app" ]; then
  BRAVE_BUNDLE="com.brave.Browser"
elif [ -d "/Applications/Brave Browser Beta.app" ]; then
  BRAVE_BUNDLE="com.brave.Browser.beta"
  BROWSER="Brave Browser Beta"
elif [ -d "/Applications/Brave Browser Nightly.app" ]; then
  BRAVE_BUNDLE="com.brave.Browser.nightly"
  BROWSER="Brave Browser Nightly"
else
  echo "[!] Brave Browser not found in /Applications."
  exit 1
fi
echo "[*] Detected: $BROWSER ($BRAVE_BUNDLE)"

# --- Setup managed preferences ---
MANAGED_PREFS_DIR="/Library/Managed Preferences"
if [ ! -d "$MANAGED_PREFS_DIR" ]; then
  sudo mkdir -p "$MANAGED_PREFS_DIR"
  sudo chown root:wheel "$MANAGED_PREFS_DIR"
  sudo chmod 755 "$MANAGED_PREFS_DIR"
fi

# --- Apply policies ---
echo "[1] Deploying system policies..."

write_policy() {
  local key="$1"
  local type="$2"
  local val="$3"
  sudo /usr/libexec/PlistBuddy -c "Add :$key $type $val" /Library/Managed\ Preferences/$BRAVE_BUNDLE.plist 2>/dev/null || \
  sudo /usr/libexec/PlistBuddy -c "Set :$key $val" /Library/Managed\ Preferences/$BRAVE_BUNDLE.plist 2>/dev/null || true
}

sudo touch "/Library/Managed Preferences/$BRAVE_BUNDLE.plist"
sudo /usr/libexec/PlistBuddy -c "Save" /Library/Managed\ Preferences/$BRAVE_BUNDLE.plist 2>/dev/null || true

write_policy "BraveRewardsDisabled"       bool  true
write_policy "BraveWalletDisabled"        bool  true
write_policy "BraveVPNDisabled"           bool  true
write_policy "BraveAIChatEnabled"         bool  false
write_policy "BraveNewsDisabled"          bool  true
write_policy "BraveTalkDisabled"          bool  true
write_policy "TorDisabled"                bool  true
write_policy "BraveSpeedreaderEnabled"    bool  false
write_policy "BraveWaybackMachineEnabled" bool  false
write_policy "BravePlaylistEnabled"       bool  false
write_policy "BraveP3AEnabled"            bool  false
write_policy "BraveStatsPingEnabled"      bool  false
write_policy "BraveWebDiscoveryEnabled"   bool  false
write_policy "SyncDisabled"               bool  true
write_policy "BackgroundModeEnabled"      bool  false
write_policy "MetricsReportingEnabled"    bool  false
write_policy "ComponentUpdatesEnabled"    bool  true
write_policy "HighEfficiencyModeEnabled"  bool  true
write_policy "DnsOverHttpsMode"             string  "secure"
write_policy "DnsOverHttpsTemplates"        string  "https://dns.adguard-dns.com/dns-query"
write_policy "SafeBrowsingProtectionLevel"  integer 2
write_policy "AlternateErrorPagesEnabled"   bool    false
write_policy "NetworkPredictionOptions"     integer 0
write_policy "PrivacySandboxAdTopicsEnabled"       bool  false
write_policy "PrivacySandboxPromptEnabled"         bool  false
write_policy "PrivacySandboxSiteEnabledAdsEnabled" bool  false
write_policy "PaymentMethodQueryEnabled"           bool  false
write_policy "UserFeedbackAllowed"                 bool  false
write_policy "SearchSuggestEnabled"                bool  false
write_policy "SpellcheckEnabled"                   bool  false
write_policy "HttpsUpgradesEnabled"                bool  true
write_policy "PasswordManagerEnabled"     bool  false
write_policy "AutofillAddressEnabled"     bool  false
write_policy "AutofillCreditCardEnabled"  bool  false
write_policy "TranslateEnabled"           bool  false
write_policy "DeveloperToolsAvailability" integer 2
write_policy "IncognitoModeAvailability"    integer 0
write_policy "BrowserAddPersonEnabled"      bool    false
write_policy "BrowserGuestModeEnabled"      bool    false
write_policy "DefaultBrowserSettingEnabled" bool    false
write_policy "BookmarkBarEnabled"  bool    false
write_policy "ShowHomeButton"      bool    false
write_policy "HomepageLocation"    string  "about:blank"
write_policy "NewTabPageLocation"  string  "about:blank"
write_policy "DefaultSearchProviderEnabled"   bool    true
write_policy "DefaultSearchProviderName"      string  "Brave Search"
write_policy "DefaultSearchProviderSearchURL" string  "https://search.brave.com/search?q={searchTerms}"
write_policy "DownloadRestrictions"      integer 0
write_policy "PromptForDownloadLocation" bool    true
write_policy "PrintingEnabled" bool true

sudo /usr/libexec/PlistBuddy -c "Save" "/Library/Managed Preferences/$BRAVE_BUNDLE.plist" 2>/dev/null
sudo chown root:wheel "/Library/Managed Preferences/$BRAVE_BUNDLE.plist" 2>/dev/null
sudo chmod 644 "/Library/Managed Preferences/$BRAVE_BUNDLE.plist" 2>/dev/null
sudo killall cfprefsd 2>/dev/null || true
echo "    -> Policies applied to $BRAVE_BUNDLE"

# --- 2. Create Brave Origin launcher app ---
echo "[2] Creating Brave Origin launcher app..."

LAUNCHER_APP="$HOME/Applications/Brave Origin.app"
mkdir -p "$LAUNCHER_APP/Contents/MacOS"
mkdir -p "$LAUNCHER_APP/Contents/Resources"

cat > "$LAUNCHER_APP/Contents/MacOS/Brave Origin" << 'LAUNCHER_EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
BROWSER_APP=""

for app in "/Applications/Brave Browser.app" "/Applications/Brave Browser Beta.app" "/Applications/Brave Browser Nightly.app"; do
  if [ -d "$app" ]; then
    BROWSER_APP="$app"
    break
  fi
done

exec "$BROWSER_APP/Contents/MacOS/$(basename "$BROWSER_APP" .app)" \
  --disable-features=AIChat,BraveVPN \
  --enable-features=HighEfficiencyMode \
  "$@"
LAUNCHER_EOF

chmod +x "$LAUNCHER_APP/Contents/MacOS/Brave Origin"

cat > "$LAUNCHER_APP/Contents/Info.plist" << PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>Brave Origin</string>
  <key>CFBundleIdentifier</key>
  <string>com.brave.origin</string>
  <key>CFBundleName</key>
  <string>Brave Origin</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleIconFile</key>
  <string>BO</string>
</dict>
</plist>
PLIST_EOF

# --- 3. Swap icon if BO.png exists ---
echo "[3] Checking for custom icon..."
if [ -f "$SCRIPT_DIR/BO.png" ]; then
  echo "    Found BO.png — converting and applying to launcher..."

  # Convert BO.png to BO.icns using iconutil
  ICONSET="$SCRIPT_DIR/BO.iconset"
  mkdir -p "$ICONSET"

  for size in 16 32 64 128 256 512; do
    sips -z "$size" "$size" "$SCRIPT_DIR/BO.png" --out "$ICONSET/icon_${size}x${size}.png" &>/dev/null || true
    sips -z "$((size*2))" "$((size*2))" "$SCRIPT_DIR/BO.png" --out "$ICONSET/icon_${size}x${size}@2x.png" &>/dev/null || true
  done

  iconutil -c icns "$ICONSET" -o "$LAUNCHER_APP/Contents/Resources/BO.icns" 2>/dev/null || {
    echo "    [!] Icon conversion failed. Copying PNG as fallback..."
    cp "$SCRIPT_DIR/BO.png" "$LAUNCHER_APP/Contents/Resources/BO.png"
  }

  rm -rf "$ICONSET"

  # Also try to replace Brave's app icon (requires SIP disabled or sudo)
  if [ -f "/Applications/$BROWSER.app/Contents/Resources/app.icns" ]; then
    echo "    Attempting system Brave icon swap..."
    sudo cp "$LAUNCHER_APP/Contents/Resources/BO.icns" "/Applications/$BROWSER.app/Contents/Resources/app.icns" 2>/dev/null && \
    echo "    System Brave icon replaced!" || \
    echo "    [!] System icon swap blocked by SIP. Launcher app has the custom icon instead."
  fi

  echo "    Icon applied to Brave Origin launcher."
else
  echo "    No BO.png found — skipping icon swap."
  echo "    (Place BO.png next to this script to auto-apply.)"
fi

echo ""
echo "=========================================="
echo "  DONE"
echo "  ☕ buymeacoffee.com/AilieIsQueen"
echo "=========================================="
echo ""
echo "Open 'Brave Origin' from your Applications folder"
echo "(instead of normal Brave) for the flags to take effect."
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
