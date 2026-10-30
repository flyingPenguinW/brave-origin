#!/usr/bin/env bash
set -e

###############################################################################
# BRAVE ORIGIN - Debloat & speed fix
# Platform: macOS
# Usage:   chmod +x setup_mac.sh && ./setup_mac.sh        (interactive menu)
#          ./setup_mac.sh --restore                        (undo, from backup)
#          (also works with: sudo ./setup_mac.sh)
# Levels:  1) Hard  2) Extreme  3) Custom  4) Restore original
# Verif:   brave://policy
# Note:    written for the default macOS bash 3.2 (no associative arrays).
###############################################################################

# Resolve the real user's home, so it also works when started with sudo.
REAL_USER="${SUDO_USER:-$(id -un)}"
REAL_HOME="$(dscl . -read "/Users/$REAL_USER" NFSHomeDirectory 2>/dev/null | sed 's/^NFSHomeDirectory: //')"
REAL_HOME="${REAL_HOME:-$HOME}"
BACKUP_DIR="$REAL_HOME/.brave-origin-backup"
LAUNCHER_APP="$REAL_HOME/Applications/Brave Origin.app"

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

###############################################################################
# Categories: what each level writes (one "Key|type|value" per line)
###############################################################################
CAT_IDS="services ai reader telemetry privacy sync passwords languages ui devtools search perf"

emit() {
  local id="$1" level="$2"
  [ "$level" = "s" ] && return 0
  case "$id" in
    services)
      echo 'BraveRewardsDisabled|bool|true'
      echo 'BraveWalletDisabled|bool|true'
      echo 'BraveVPNDisabled|bool|true'
      echo 'BraveNewsDisabled|bool|true'
      echo 'BraveTalkDisabled|bool|true'
      echo 'TorDisabled|bool|true'
      echo 'BravePlaylistEnabled|bool|false'
      echo 'BraveWaybackMachineEnabled|bool|false'
      ;;
    ai)
      if [ "$level" = "e" ]; then
        echo 'BraveAIChatEnabled|bool|false'
      fi
      ;;
    reader)
      if [ "$level" = "e" ]; then
        echo 'BraveSpeedreaderEnabled|bool|false'
      fi
      if [ "$level" = "h" ]; then
        echo 'BraveSpeedreaderEnabled|bool|true'
      fi
      ;;
    telemetry)
      echo 'BraveP3AEnabled|bool|false'
      echo 'BraveStatsPingEnabled|bool|false'
      echo 'BraveWebDiscoveryEnabled|bool|false'
      echo 'MetricsReportingEnabled|bool|false'
      echo 'UserFeedbackAllowed|bool|false'
      echo 'PrivacySandboxAdTopicsEnabled|bool|false'
      echo 'PrivacySandboxPromptEnabled|bool|false'
      echo 'PrivacySandboxSiteEnabledAdsEnabled|bool|false'
      echo 'PaymentMethodQueryEnabled|bool|false'
      echo 'AlternateErrorPagesEnabled|bool|false'
      echo 'NetworkPredictionOptions|integer|0'
      echo 'SearchSuggestEnabled|bool|false'
      ;;
    privacy)
      echo 'SafeBrowsingProtectionLevel|integer|1'
      if [ "$level" = "e" ]; then
        echo 'DnsOverHttpsMode|string|secure'
        echo 'DnsOverHttpsTemplates|string|https://dns.adguard-dns.com/dns-query'
      fi
      ;;
    sync)
      if [ "$level" = "e" ]; then
        echo 'SyncDisabled|bool|true'
        echo 'BrowserAddPersonEnabled|bool|false'
        echo 'BrowserGuestModeEnabled|bool|false'
      fi
      ;;
    passwords)
      echo 'PasswordManagerEnabled|bool|false'
      if [ "$level" = "e" ]; then
        echo 'AutofillAddressEnabled|bool|false'
        echo 'AutofillCreditCardEnabled|bool|false'
      fi
      if [ "$level" = "h" ]; then
        echo 'AutofillAddressEnabled|bool|true'
      fi
      ;;
    languages)
      if [ "$level" = "e" ]; then
        echo 'TranslateEnabled|bool|false'
        echo 'SpellcheckEnabled|bool|false'
        echo 'SpellcheckServiceEnabled|bool|false'
      fi
      if [ "$level" = "h" ]; then
        echo 'TranslateEnabled|bool|true'
        echo 'SpellcheckEnabled|bool|true'
        echo 'SpellcheckServiceEnabled|bool|false'
      fi
      ;;
    ui)
      echo 'ShowHomeButton|bool|false'
      echo 'HomepageLocation|string|about:blank'
      echo 'DefaultBrowserSettingEnabled|bool|false'
      if [ "$level" = "e" ]; then
        echo 'BookmarkBarEnabled|bool|false'
        echo 'NewTabPageLocation|string|about:blank'
      fi
      if [ "$level" = "h" ]; then
        echo 'BookmarkBarEnabled|bool|true'
      fi
      ;;
    devtools)
      if [ "$level" = "e" ]; then
        echo 'DeveloperToolsAvailability|integer|2'
      fi
      if [ "$level" = "h" ]; then
        echo 'DeveloperToolsAvailability|integer|1'
      fi
      ;;
    search)
      if [ "$level" = "e" ]; then
        echo 'ManagedSearchEngines|searchengines|-'
        echo 'DefaultSearchProviderEnabled|bool|true'
        echo 'DefaultSearchProviderName|string|Brave Search'
        echo 'DefaultSearchProviderSearchURL|string|https://search.brave.com/search?q={searchTerms}'
      fi
      ;;
    perf)
      echo 'BackgroundModeEnabled|bool|false'
      echo 'HighEfficiencyModeEnabled|bool|true'
      echo 'ComponentUpdatesEnabled|bool|true'
      echo 'HttpsUpgradesEnabled|bool|true'
      echo 'IncognitoModeAvailability|integer|0'
      echo 'DownloadRestrictions|integer|0'
      echo 'PromptForDownloadLocation|bool|true'
      echo 'PrintingEnabled|bool|true'
      ;;
  esac
  return 0
}

cat_info() {
  case "$1" in
    services) C_TITLE="Brave services"; C_EXT="Rewards, Wallet, VPN, News, Talk, Tor, Playlist, Wayback Machine OFF"; C_HARD="same as Extreme" ;;
    ai) C_TITLE="Leo AI"; C_EXT="Leo AI OFF, policy and AIChat feature flag"; C_HARD="Leo AI stays ON" ;;
    reader) C_TITLE="Speedreader"; C_EXT="Speedreader OFF"; C_HARD="Speedreader ON" ;;
    telemetry) C_TITLE="Telemetry and tracking"; C_EXT="P3A, stats ping, metrics, web discovery, feedback, Privacy Sandbox, prediction, search suggestions OFF"; C_HARD="same as Extreme" ;;
    privacy) C_TITLE="DNS and Safe Browsing"; C_EXT="DNS-over-HTTPS forced via AdGuard, no fallback, Safe Browsing Standard"; C_HARD="DNS-over-HTTPS not forced, you choose in browser settings, Safe Browsing Standard" ;;
    sync) C_TITLE="Sync and profiles"; C_EXT="Sync OFF for all profiles, adding profiles and guest mode blocked"; C_HARD="Sync allowed per profile, profiles and guest mode untouched" ;;
    passwords) C_TITLE="Passwords and autofill"; C_EXT="Password manager, address autofill, card autofill OFF"; C_HARD="Password manager OFF, address autofill ON, card autofill left to you" ;;
    languages) C_TITLE="Translate and spellcheck"; C_EXT="Translate and spellcheck OFF"; C_HARD="Translate and local spellcheck ON, Google spellcheck service stays OFF" ;;
    ui) C_TITLE="Interface"; C_EXT="Bookmarks bar hidden, no home button, homepage and new tab about:blank, no default-browser nag"; C_HARD="Bookmarks bar shown, no home button, homepage about:blank, new tab unchanged so extensions can replace it, no default-browser nag" ;;
    devtools) C_TITLE="Developer tools"; C_EXT="DevTools disabled"; C_HARD="DevTools enabled" ;;
    search) C_TITLE="Search engine"; C_EXT="Default search engine Brave Search, list restricted to Brave Search, Google, DuckDuckGo"; C_HARD="Search engine left to you, not overridden" ;;
    perf) C_TITLE="Performance and misc"; C_EXT="Background mode OFF so Brave quits when the last window closes, Memory Saver ON, HTTPS upgrades ON, incognito, printing and downloads allowed"; C_HARD="same as Extreme" ;;
  esac
}

print_levels() {
  local W1=30 W2=20 W3=22
  dashes() { printf '%*s' "$1" '' | tr ' ' '-'; }
  sep()  { printf "  +%s+%s+%s+\n" "$(dashes $((W1+2)))" "$(dashes $((W2+2)))" "$(dashes $((W3+2)))"; }
  row()  { printf "  | %-${W1}s | %-${W2}s | %-${W3}s |\n" "$1" "$2" "$3"; }
  span() { printf "  | %-${W1}s | %-$((W2+W3+3))s |\n" "$1" "$2"; }
  grp()  { printf "  | %-$((W1+W2+W3+6))s |\n" "$1"; }

  echo "Debloat levels:"
  echo ""
  echo "  1) HARD     - same debloat, but keeps features you may actually use. (recommended)"
  echo "  2) EXTREME  - maximum lockdown, everything disabled."
  echo "  3) CUSTOM   - choose Hard / Extreme / Skip for each category."
  echo "  4) RESTORE  - back to the original Brave state (from backup)."
  echo ""
  sep
  row "Setting" "EXTREME" "HARD"
  sep
  grp "Same in both"
  span "Safe Browsing" "Standard (Enhanced shares more visited links)"
  sep
  grp "Disabled in both"
  row "Rewards/Wallet/VPN/News/Tor" "off" "off"
  row "Telemetry & tracking"        "off" "off"
  row "Password manager"            "off" "off"
  row "Search suggestions"          "off" "off"
  row "Background mode"             "off" "off"
  sep
  grp "Differences"
  row "Leo AI"                      "off"                "ON"
  row "Speedreader"                 "off"                "ON"
  row "Sync"                        "off (all profiles)" "ON"
  row "Add profile / guest mode"    "blocked"            "allowed"
  row "Address autofill"            "off"                "ON"
  row "Card autofill"               "off"                "Brave default"
  row "Translate & spellcheck"      "off"                "ON"
  row "Bookmarks bar"               "hidden"             "shown"
  row "New tab page"                "about:blank"        "unchanged"
  row "DevTools"                    "off"                "ON"
  row "DNS-over-HTTPS"              "forced (AdGuard)"   "your choice"
  row "Default search engine"       "Brave Search"       "your choice"
  sep
  echo ""
  echo "  Both levels: homepage = about:blank, Memory Saver ON, HTTPS upgrades ON."
  echo "  Policies lock the matching options in brave://settings"
  echo "  (\"managed by your organization\"). Option 4 undoes this."
  echo ""
}

###############################################################################
# Detect which channel is installed
###############################################################################
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

MANAGED_PREFS_DIR="/Library/Managed Preferences"
PLIST="$MANAGED_PREFS_DIR/$BRAVE_BUNDLE.plist"

write_search_engines() {
  sudo defaults write "$PLIST" ManagedSearchEngines -array \
    '<dict><key>name</key><string>Brave Search</string><key>keyword</key><string>search.brave.com</string><key>search_url</key><string>https://search.brave.com/search?q={searchTerms}</string><key>suggest_url</key><string>https://search.brave.com/api/suggest?q={searchTerms}</string><key>encoding</key><string>UTF-8</string><key>favicon_url</key><string>https://brave.com/favicon.ico</string></dict>' \
    '<dict><key>name</key><string>Google</string><key>keyword</key><string>google.com</string><key>search_url</key><string>https://www.google.com/search?q={searchTerms}</string><key>suggest_url</key><string>https://www.google.com/complete/search?output=chrome&amp;q={searchTerms}</string><key>encoding</key><string>UTF-8</string><key>favicon_url</key><string>https://www.google.com/favicon.ico</string></dict>' \
    '<dict><key>name</key><string>DuckDuckGo</string><key>keyword</key><string>duckduckgo.com</string><key>search_url</key><string>https://duckduckgo.com/?q={searchTerms}</string><key>suggest_url</key><string>https://duckduckgo.com/ac/?q={searchTerms}&amp;type=list</string><key>encoding</key><string>UTF-8</string><key>favicon_url</key><string>https://duckduckgo.com/favicon.ico</string></dict>'
}

write_policy() {
  local key="$1" type="$2" val="$3"
  case "$type" in
    searchengines) write_search_engines ;;
    bool)    sudo defaults write "$PLIST" "$key" -bool "$val" ;;
    integer) sudo defaults write "$PLIST" "$key" -int "$val" ;;
    string)  sudo defaults write "$PLIST" "$key" -string "$val" ;;
  esac
}

# Remove every value this script can write (any level), so switching levels
# leaves nothing stale. Other policies in the file are not touched.
delete_managed() {
  local id lv line key
  [ -f "$PLIST" ] || return 0
  for id in $CAT_IDS; do
    for lv in e h; do
      while IFS= read -r line; do
        [ -n "$line" ] || continue
        key="${line%%|*}"
        sudo defaults delete "$PLIST" "$key" 2>/dev/null || true
      done < <(emit "$id" "$lv")
    done
  done
}

fix_perms() {
  sudo chown root:wheel "$PLIST" 2>/dev/null || true
  sudo chmod 644 "$PLIST" 2>/dev/null || true
  sudo killall cfprefsd 2>/dev/null || true
}

###############################################################################
# Restore
###############################################################################
do_restore() {
  echo "=========================================="
  echo "  Brave Origin - Restore original values"
  echo "=========================================="
  echo ""
  if [ -d "$BACKUP_DIR" ]; then
    echo "[*] Using backup: $BACKUP_DIR"
  else
    echo "[!] No backup found in $BACKUP_DIR."
    echo "    Restore will just remove the values and the launcher app"
    echo "    created by this script."
  fi
  ask_yn "Restore Brave to its previous state?" || { echo "Aborted."; exit 0; }

  echo "[1] Policies..."
  delete_managed
  if [ -f "$BACKUP_DIR/$BRAVE_BUNDLE.plist" ]; then
    sudo cp -p "$BACKUP_DIR/$BRAVE_BUNDLE.plist" "$PLIST"
  fi
  fix_perms

  echo "[2] Launcher app..."
  rm -rf "$LAUNCHER_APP"
  if [ -d "$BACKUP_DIR/Brave Origin.app" ]; then
    mkdir -p "$REAL_HOME/Applications"
    cp -R "$BACKUP_DIR/Brave Origin.app" "$LAUNCHER_APP"
  fi

  echo ""
  echo "Done. Fully restart Brave and check brave://policy"
  echo "Manual flags/settings (brave://flags, brave://settings) are not"
  echo "touched by this script - revert them by hand if you changed them."
}

if [ "${1:-}" = "--restore" ]; then
  do_restore
  exit 0
fi

###############################################################################
# Start
###############################################################################
echo "=========================================="
echo "  Brave Origin - macOS Setup"
echo "  ☕ buymeacoffee.com/AilieIsQueen"
echo "=========================================="
echo ""
echo "[*] Detected: $BROWSER ($BRAVE_BUNDLE)"
echo ""

print_levels

LEVEL_NAME=""
while true; do
  read -r -p "Choose level [1-4]: " choice
  case "$choice" in
    1) for id in $CAT_IDS; do eval "LEVEL_$id=h"; done; LEVEL_NAME="Hard"; break ;;
    2) for id in $CAT_IDS; do eval "LEVEL_$id=e"; done; LEVEL_NAME="Extreme"; break ;;
    3)
      LEVEL_NAME="Custom"
      echo ""
      for id in $CAT_IDS; do
        cat_info "$id"
        echo "* $C_TITLE"
        echo "    h) Hard:    $C_HARD"
        echo "    e) Extreme: $C_EXT"
        echo "    s) Skip:    leave Brave default"
        while true; do
          read -r -p "  [h/e/s]: " lv
          case "$lv" in
            h|H) eval "LEVEL_$id=h"; break ;;
            e|E) eval "LEVEL_$id=e"; break ;;
            s|S) eval "LEVEL_$id=s"; break ;;
            *) echo "  Please answer h, e or s." ;;
          esac
        done
      done
      break
      ;;
    4) echo ""; do_restore; exit 0 ;;
    *) echo "Please enter 1, 2, 3 or 4." ;;
  esac
done
echo ""

# --- 0. Backup ---
echo "A backup lets you undo everything later with: ./setup_mac.sh --restore"
if [ -d "$BACKUP_DIR" ]; then
  echo "[*] Backup already exists ($BACKUP_DIR) - keeping the original one."
elif ask_yn "Do you want to create a Brave backup? (strongly recommended)"; then
  mkdir -p "$BACKUP_DIR"
  if [ -f "$PLIST" ]; then
    sudo cp -p "$PLIST" "$BACKUP_DIR/$BRAVE_BUNDLE.plist"
    sudo chown -R "$(id -u "$REAL_USER"):$(id -g "$REAL_USER")" "$BACKUP_DIR"
  fi
  if [ -d "$LAUNCHER_APP" ]; then
    cp -R "$LAUNCHER_APP" "$BACKUP_DIR/Brave Origin.app"
  fi
  chown -R "$(id -u "$REAL_USER"):$(id -g "$REAL_USER")" "$BACKUP_DIR" 2>/dev/null || true
  echo "[*] Backup saved to $BACKUP_DIR"
else
  echo "[!] Continuing WITHOUT backup."
  ask_yn "Are you sure?" || { echo "Aborted."; exit 0; }
fi
echo ""

# --- Setup managed preferences ---
if [ ! -d "$MANAGED_PREFS_DIR" ]; then
  sudo mkdir -p "$MANAGED_PREFS_DIR"
  sudo chown root:wheel "$MANAGED_PREFS_DIR"
  sudo chmod 755 "$MANAGED_PREFS_DIR"
fi

# --- 1. Apply policies ---
echo "[1] Deploying system policies ($LEVEL_NAME)..."

delete_managed

for id in $CAT_IDS; do
  level="$(eval echo "\$LEVEL_$id")"
  while IFS='|' read -r key type val; do
    [ -n "$key" ] || continue
    write_policy "$key" "$type" "$val"
  done < <(emit "$id" "$level")
done

fix_perms
echo "    -> Policies applied to $BRAVE_BUNDLE"

# --- 2. Create Brave Origin launcher app ---
echo "[2] Creating Brave Origin launcher app..."

DISABLE_FEATURES="BraveVPN"
[ "$LEVEL_ai" = "e" ] && DISABLE_FEATURES="AIChat,BraveVPN"
FLAGS="--disable-features=$DISABLE_FEATURES --enable-features=HighEfficiencyMode"

rm -rf "$LAUNCHER_APP"
mkdir -p "$LAUNCHER_APP/Contents/MacOS"
mkdir -p "$LAUNCHER_APP/Contents/Resources"

cat > "$LAUNCHER_APP/Contents/MacOS/Brave Origin" << LAUNCHER_EOF
#!/bin/bash
BROWSER_APP=""

for app in "/Applications/Brave Browser.app" "/Applications/Brave Browser Beta.app" "/Applications/Brave Browser Nightly.app"; do
  if [ -d "\$app" ]; then
    BROWSER_APP="\$app"
    break
  fi
done

exec "\$BROWSER_APP/Contents/MacOS/\$(basename "\$BROWSER_APP" .app)" \\
  $FLAGS \\
  "\$@"
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
  <string>app</string>
</dict>
</plist>
PLIST_EOF

chown -R "$(id -u "$REAL_USER"):$(id -g "$REAL_USER")" "$LAUNCHER_APP" 2>/dev/null || true

echo ""
echo "=========================================="
echo "  DONE ($LEVEL_NAME)"
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
echo "  brave://settings/security            -> Use secure DNS (choose a provider)"
echo "      DoH (DNS-over-HTTPS) encrypts the website lookups your browser makes,"
echo "      so your ISP and the local network can't see which sites you visit."
echo "      It does not hide your IP and does not block ads."
echo "      (Extreme level: DNS is forced to AdGuard and locked, nothing to do.)"
echo ""
echo "Verify: brave://policy"
echo "Undo:   ./setup_mac.sh --restore   (or run again and choose 4) Restore)"
echo ""
