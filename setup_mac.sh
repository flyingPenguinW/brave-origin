#!/usr/bin/env bash
set -e

###############################################################################
# BRAVE ORIGIN - Complete debloat & speed fix for Brave Browser
# Platform: macOS
# Usage:   chmod +x setup_mac.sh && sudo ./setup_mac.sh
# Verif:   brave://policy
###############################################################################

echo "=========================================="
echo "  Brave Origin - macOS Setup"
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

# --- Setup managed preferences directory ---
MANAGED_PREFS_DIR="/Library/Managed Preferences"
if [ ! -d "$MANAGED_PREFS_DIR" ]; then
  sudo mkdir -p "$MANAGED_PREFS_DIR"
  sudo chown root:wheel "$MANAGED_PREFS_DIR"
  sudo chmod 755 "$MANAGED_PREFS_DIR"
  echo "[*] Created $MANAGED_PREFS_DIR"
fi

# --- Apply policies via PlistBuddy ---
echo "[1] Applying system policies..."

write_policy() {
  local key="$1"
  local type="$2"
  local val="$3"
  sudo /usr/libexec/PlistBuddy -c "Add :$key $type $val" /Library/Managed\ Preferences/$BRAVE_BUNDLE.plist 2>/dev/null || \
  sudo /usr/libexec/PlistBuddy -c "Set :$key $val" /Library/Managed\ Preferences/$BRAVE_BUNDLE.plist 2>/dev/null || true
}

# Create the plist file
sudo /usr/libexec/PlistBuddy -c "Save" /Library/Managed\ Preferences/$BRAVE_BUNDLE.plist 2>/dev/null || \
sudo touch "/Library/Managed Preferences/$BRAVE_BUNDLE.plist"

# ---- Brave bloat features ----
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

# ---- Telemetry ----
write_policy "BraveP3AEnabled"            bool  false
write_policy "BraveStatsPingEnabled"      bool  false
write_policy "BraveWebDiscoveryEnabled"   bool  false
write_policy "SyncDisabled"               bool  true

# ---- Background / RAM saving ----
write_policy "BackgroundModeEnabled"      bool  false
write_policy "MetricsReportingEnabled"    bool  false
write_policy "ComponentUpdatesEnabled"   bool    true
write_policy "HighEfficiencyModeEnabled"  bool  true

# ---- Privacy hardening ----
write_policy "DnsOverHttpsMode"             string  "secure"
write_policy "DnsOverHttpsTemplates"        string  "https://dns.adguard-dns.com/dns-query"
write_policy "SafeBrowsingProtectionLevel"  integer 2
write_policy "AlternateErrorPagesEnabled"   bool    false
write_policy "PrivacySandboxAdTopicsEnabled"       bool  false
write_policy "PrivacySandboxPromptEnabled"         bool  false
write_policy "PrivacySandboxSiteEnabledAdsEnabled" bool  false
write_policy "PaymentMethodQueryEnabled"           bool  false
write_policy "UserFeedbackAllowed"                 bool  false
write_policy "SearchSuggestEnabled"                bool  false
write_policy "SpellcheckEnabled"                   bool  false
write_policy "HttpsUpgradesEnabled"                bool  true

# ---- SPEED FIX: re-enable network prediction ----
write_policy "NetworkPredictionOptions"   integer 0

# ---- Autofill / passwords / translate ----
write_policy "PasswordManagerEnabled"     bool  false
write_policy "AutofillAddressEnabled"     bool  false
write_policy "AutofillCreditCardEnabled"  bool  false
write_policy "TranslateEnabled"           bool  false

# ---- Developer tools ----
write_policy "DeveloperToolsAvailability" integer 2

# ---- Browser modes ----
write_policy "IncognitoModeAvailability"    integer 0
write_policy "BrowserAddPersonEnabled"      bool    false
write_policy "BrowserGuestModeEnabled"      bool    false
write_policy "DefaultBrowserSettingEnabled" bool    false

# ---- UI tweaks ----
write_policy "BookmarkBarEnabled"  bool    false
write_policy "ShowHomeButton"      bool    false
write_policy "HomepageLocation"    string  "about:blank"
write_policy "NewTabPageLocation"  string  "about:blank"

# ---- Search engine ----
write_policy "DefaultSearchProviderEnabled"   bool    true
write_policy "DefaultSearchProviderName"      string  "Brave Search"
write_policy "DefaultSearchProviderSearchURL" string  "https://search.brave.com/search?q={searchTerms}"

# ---- Downloads ----
write_policy "DownloadRestrictions"      integer 0
write_policy "PromptForDownloadLocation" bool    true

write_policy "PrintingEnabled" bool true

# Save
sudo /usr/libexec/PlistBuddy -c "Save" "/Library/Managed Preferences/$BRAVE_BUNDLE.plist" 2>/dev/null

# Fix permissions
sudo chown root:wheel "/Library/Managed Preferences/$BRAVE_BUNDLE.plist" 2>/dev/null
sudo chmod 644 "/Library/Managed Preferences/$BRAVE_BUNDLE.plist" 2>/dev/null

# Flush cfprefs
sudo killall cfprefsd 2>/dev/null || true

echo "    -> Policies applied to $BRAVE_BUNDLE"

# --- 2. Create an app launcher with debloat flags ---
echo "[2] Creating Brave Origin launcher..."

LAUNCHER_APP="$HOME/Applications/Brave Origin.app"
mkdir -p "$LAUNCHER_APP/Contents/MacOS"
mkdir -p "$LAUNCHER_APP/Contents/Resources"

cat > "$LAUNCHER_APP/Contents/MacOS/Brave Origin" << EOF
#!/bin/bash
exec /Applications/$BROWSER.app/Contents/MacOS/$BROWSER \\
  --disable-features=AIChat,BraveVPN \\
  --enable-features=HighEfficiencyMode \\
  "\$@"
EOF

chmod +x "$LAUNCHER_APP/Contents/MacOS/Brave Origin"

# Create Info.plist for the launcher
cat > "$LAUNCHER_APP/Contents/Info.plist" << EOF
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
  <string>brave</string>
</dict>
</plist>
EOF

# Try to copy Brave's icon
if [ -f "/Applications/$BROWSER.app/Contents/Resources/app.icns" ]; then
  cp "/Applications/$BROWSER.app/Contents/Resources/app.icns" "$LAUNCHER_APP/Contents/Resources/brave.icns"
fi

echo "    -> $LAUNCHER_APP"
echo "    (Open this app instead of Brave for flags to take effect)"

echo ""
echo "=========================================="
echo "  DONE"
echo "=========================================="
echo ""
echo "[*] Fully restart Brave."
echo "[*] Verify at brave://policy"
echo ""
echo "--- POST-SETUP (do these once in Brave) ---"
echo ""
echo "  Fix SLOW LOADING:"
echo "    brave://settings/privacy"
echo "      -> If still slow: change DNS to"
echo "         https://cloudflare-dns.com/dns-query"
echo ""
echo "  brave://flags/#brave-sidebar"
echo "      -> Disabled"
echo ""
echo "  brave://settings/appearance"
echo "      -> 'Use system title bar and borders' ON"
echo ""
echo "  brave://flags/#enable-zero-copy"
echo "      -> Enabled"
echo ""
echo "  brave://flags/#enable-parallel-downloading"
echo "      -> Enabled"
echo ""
echo "  brave://settings/system"
echo "      -> 'Memory Saver' ON"
echo ""
