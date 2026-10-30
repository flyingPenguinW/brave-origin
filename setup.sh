#!/usr/bin/env bash
set -e

###############################################################################
# BRAVE ORIGIN - Debloat & speed fix
# Platform: Linux
# Usage:   chmod +x setup.sh && ./setup.sh            (interactive menu)
#          ./setup.sh --restore                       (undo, from backup)
#          (also works with: sudo ./setup.sh)
# Levels:  1) Hard  2) Extreme  3) Custom  4) Restore original
# Verif:   brave://policy
###############################################################################

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
}

if [ "${1:-}" = "--restore" ]; then
  do_restore
  exit 0
fi

###############################################################################
# Categories: what each level does
###############################################################################
CAT_IDS=(services ai reader telemetry privacy sync passwords languages ui devtools search perf)

declare -A CAT_TITLE CAT_EXT CAT_HARD
CAT_TITLE[services]="Brave services"
CAT_EXT[services]="Rewards, Wallet, VPN, News, Talk, Tor, Playlist, Wayback Machine OFF"
CAT_HARD[services]="same as Extreme"

CAT_TITLE[ai]="Leo AI"
CAT_EXT[ai]="Leo AI OFF (policy + AIChat feature flag)"
CAT_HARD[ai]="Leo AI stays ON"

CAT_TITLE[reader]="Speedreader"
CAT_EXT[reader]="Speedreader OFF"
CAT_HARD[reader]="Speedreader ON"

CAT_TITLE[telemetry]="Telemetry & tracking"
CAT_EXT[telemetry]="P3A, stats ping, metrics, web discovery, feedback, Privacy Sandbox, prediction, search suggestions OFF"
CAT_HARD[telemetry]="same as Extreme"

CAT_TITLE[privacy]="DNS & Safe Browsing"
CAT_EXT[privacy]="DNS-over-HTTPS forced via AdGuard (no fallback), Safe Browsing Standard"
CAT_HARD[privacy]="DNS-over-HTTPS not forced (you choose in browser settings), Safe Browsing Standard"

CAT_TITLE[sync]="Sync & profiles"
CAT_EXT[sync]="Sync OFF for all profiles, adding profiles and guest mode blocked"
CAT_HARD[sync]="Sync allowed (per profile), profiles and guest mode untouched"

CAT_TITLE[passwords]="Passwords & autofill"
CAT_EXT[passwords]="Password manager, address autofill, card autofill OFF"
CAT_HARD[passwords]="Password manager OFF, address autofill ON, card autofill left to you"

CAT_TITLE[languages]="Translate & spellcheck"
CAT_EXT[languages]="Translate and spellcheck OFF"
CAT_HARD[languages]="Translate and local spellcheck ON (Google spellcheck service stays OFF)"

CAT_TITLE[ui]="Interface"
CAT_EXT[ui]="Bookmarks bar hidden, no home button, homepage/new tab = about:blank, no default-browser nag"
CAT_HARD[ui]="Bookmarks bar shown, no home button, homepage = about:blank, new tab unchanged (extensions can replace it), no default-browser nag"

CAT_TITLE[devtools]="Developer tools"
CAT_EXT[devtools]="DevTools disabled"
CAT_HARD[devtools]="DevTools enabled"

CAT_TITLE[search]="Search engine"
CAT_EXT[search]="Default Brave Search; list: Brave, Google, DuckDuckGo"
CAT_HARD[search]="Search engine left to you, not overridden"

CAT_TITLE[perf]="Performance & misc"
CAT_EXT[perf]="Background mode OFF (Brave quits when last window closes), Memory Saver ON, HTTPS upgrades ON, incognito/printing/downloads allowed"
CAT_HARD[perf]="same as Extreme"

# Print policy entries (one JSON "key": value per line) for a category + level.
# Level: e = extreme, h = hard, s = skip (nothing written, Brave default).
emit() {
  local id="$1" level="$2"
  [ "$level" = "s" ] && return 0
  case "$id" in
    services)
      echo '"BraveRewardsDisabled": true'
      echo '"BraveWalletDisabled": true'
      echo '"BraveVPNDisabled": true'
      echo '"BraveNewsDisabled": true'
      echo '"BraveTalkDisabled": true'
      echo '"TorDisabled": true'
      echo '"BravePlaylistEnabled": false'
      echo '"BraveWaybackMachineEnabled": false'
      ;;
    ai)
      [ "$level" = "e" ] && echo '"BraveAIChatEnabled": false'
      ;;
    reader)
      [ "$level" = "e" ] && echo '"BraveSpeedreaderEnabled": false'
      [ "$level" = "h" ] && echo '"BraveSpeedreaderEnabled": true'
      ;;
    telemetry)
      echo '"BraveP3AEnabled": false'
      echo '"BraveStatsPingEnabled": false'
      echo '"BraveWebDiscoveryEnabled": false'
      echo '"MetricsReportingEnabled": false'
      echo '"UserFeedbackAllowed": false'
      echo '"PrivacySandboxAdTopicsEnabled": false'
      echo '"PrivacySandboxPromptEnabled": false'
      echo '"PrivacySandboxSiteEnabledAdsEnabled": false'
      echo '"PaymentMethodQueryEnabled": false'
      echo '"AlternateErrorPagesEnabled": false'
      echo '"NetworkPredictionOptions": 0'
      echo '"SearchSuggestEnabled": false'
      ;;
    privacy)
      if [ "$level" = "e" ]; then
        echo '"DnsOverHttpsMode": "secure"'
        echo '"DnsOverHttpsTemplates": "https://dns.adguard-dns.com/dns-query"'
      fi
      echo '"SafeBrowsingProtectionLevel": 1'
      ;;
    sync)
      if [ "$level" = "e" ]; then
        echo '"SyncDisabled": true'
        echo '"BrowserAddPersonEnabled": false'
        echo '"BrowserGuestModeEnabled": false'
      fi
      ;;
    passwords)
      echo '"PasswordManagerEnabled": false'
      if [ "$level" = "e" ]; then
        echo '"AutofillAddressEnabled": false'
        echo '"AutofillCreditCardEnabled": false'
      else
        echo '"AutofillAddressEnabled": true'
      fi
      ;;
    languages)
      if [ "$level" = "e" ]; then
        echo '"TranslateEnabled": false'
        echo '"SpellcheckEnabled": false'
        echo '"SpellcheckServiceEnabled": false'
      else
        echo '"TranslateEnabled": true'
        echo '"SpellcheckEnabled": true'
        echo '"SpellcheckServiceEnabled": false'
      fi
      ;;
    ui)
      [ "$level" = "e" ] && echo '"BookmarkBarEnabled": false'
      [ "$level" = "h" ] && echo '"BookmarkBarEnabled": true'
      echo '"ShowHomeButton": false'
      echo '"HomepageLocation": "about:blank"'
      [ "$level" = "e" ] && echo '"NewTabPageLocation": "about:blank"'
      echo '"DefaultBrowserSettingEnabled": false'
      ;;
    devtools)
      [ "$level" = "e" ] && echo '"DeveloperToolsAvailability": 2'
      [ "$level" = "h" ] && echo '"DeveloperToolsAvailability": 1'
      ;;
    search)
      if [ "$level" = "e" ]; then
        echo '"ManagedSearchEngines": [{"name": "Brave Search", "keyword": "search.brave.com", "search_url": "https://search.brave.com/search?q={searchTerms}", "suggest_url": "https://search.brave.com/api/suggest?q={searchTerms}", "encoding": "UTF-8", "favicon_url": "https://brave.com/favicon.ico"}, {"name": "Google", "keyword": "google.com", "search_url": "https://www.google.com/search?q={searchTerms}", "suggest_url": "https://www.google.com/complete/search?output=chrome&q={searchTerms}", "encoding": "UTF-8", "favicon_url": "https://www.google.com/favicon.ico"}, {"name": "DuckDuckGo", "keyword": "duckduckgo.com", "search_url": "https://duckduckgo.com/?q={searchTerms}", "suggest_url": "https://duckduckgo.com/ac/?q={searchTerms}&type=list", "encoding": "UTF-8", "favicon_url": "https://duckduckgo.com/favicon.ico"}]'
        echo '"DefaultSearchProviderEnabled": true'
        echo '"DefaultSearchProviderName": "Brave Search"'
        echo '"DefaultSearchProviderSearchURL": "https://search.brave.com/search?q={searchTerms}"'
      fi
      ;;
    perf)
      echo '"BackgroundModeEnabled": false'
      echo '"HighEfficiencyModeEnabled": true'
      echo '"ComponentUpdatesEnabled": true'
      echo '"HttpsUpgradesEnabled": true'
      echo '"IncognitoModeAvailability": 0'
      echo '"DownloadRestrictions": 0'
      echo '"PromptForDownloadLocation": true'
      echo '"PrintingEnabled": true'
      ;;
  esac
  return 0
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
# Start
###############################################################################
echo "=========================================="
echo "  Brave Origin - Linux Setup"
echo "  ☕ buymeacoffee.com/AilieIsQueen"
echo "=========================================="
echo ""

print_levels

declare -A LEVEL
LEVEL_NAME=""
while true; do
  read -r -p "Choose level [1-4]: " choice
  case "$choice" in
    1) for id in "${CAT_IDS[@]}"; do LEVEL[$id]=h; done; LEVEL_NAME="Hard"; break ;;
    2) for id in "${CAT_IDS[@]}"; do LEVEL[$id]=e; done; LEVEL_NAME="Extreme"; break ;;
    3)
      LEVEL_NAME="Custom"
      echo ""
      for id in "${CAT_IDS[@]}"; do
        echo "* ${CAT_TITLE[$id]}"
        echo "    h) Hard:    ${CAT_HARD[$id]}"
        echo "    e) Extreme: ${CAT_EXT[$id]}"
        echo "    s) Skip:    leave Brave default"
        while true; do
          read -r -p "  [h/e/s]: " lv
          case "$lv" in
            e|E) LEVEL[$id]=e; break ;;
            h|H) LEVEL[$id]=h; break ;;
            s|S) LEVEL[$id]=s; break ;;
            *) echo "  Please answer e, h or s." ;;
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
echo "[1] Deploying system policies ($LEVEL_NAME)..."
sudo mkdir -p "$POLICY_DIR"

ENTRIES=()
for id in "${CAT_IDS[@]}"; do
  while IFS= read -r line; do
    [ -n "$line" ] && ENTRIES+=("$line")
  done < <(emit "$id" "${LEVEL[$id]}")
done

{
  echo "{"
  echo "  \"_note\": \"Brave Origin - $LEVEL_NAME debloat\","
  last=$(( ${#ENTRIES[@]} - 1 ))
  for i in "${!ENTRIES[@]}"; do
    if [ "$i" -lt "$last" ]; then
      echo "  ${ENTRIES[$i]},"
    else
      echo "  ${ENTRIES[$i]}"
    fi
  done
  echo "}"
} | sudo tee "$POLICY_FILE" > /dev/null

sudo chmod 644 "$POLICY_FILE"
echo "    -> $POLICY_FILE"

# --- 2. Patch the Brave desktop entry with feature flags ---
echo "[2] Patching desktop entry..."

DISABLE_FEATURES="BraveVPN"
[ "${LEVEL[ai]}" = "e" ] && DISABLE_FEATURES="AIChat,BraveVPN"
FLAGS="--disable-features=$DISABLE_FEATURES --enable-features=HighEfficiencyMode"

mkdir -p "$LOCAL_APPS"

SYS_DESKTOP=$(ls /usr/share/applications/brave*.desktop 2>/dev/null | head -1)
if [ -n "$SYS_DESKTOP" ]; then
  cp "$SYS_DESKTOP" "$LOCAL_DESKTOP"
  sed -i 's|^\(Exec=[^ ]*brave-browser[^ ]*\)\( .*\)\?$|\1 '"$FLAGS"'\2|' "$LOCAL_DESKTOP"
  echo "    -> $LOCAL_DESKTOP"
else
  cat > "$LOCAL_DESKTOP" << EOF
[Desktop Entry]
Version=1.0
Name=Brave Browser
Comment=Brave Browser (debloated)
Exec=$(command -v "$BRAVE_BIN") $FLAGS %U
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
update-desktop-database "$LOCAL_APPS" 2>/dev/null || true

# --- 3. Flush DNS (speed helper) ---
command -v resolvectl &>/dev/null && sudo resolvectl flush-caches 2>/dev/null || true

echo ""
echo "=========================================="
echo "  DONE ($LEVEL_NAME)"
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
echo "  brave://settings/security            -> Use secure DNS (choose a provider)"
echo "      DoH (DNS-over-HTTPS) encrypts the website lookups your browser makes,"
echo "      so your ISP and the local network can't see which sites you visit."
echo "      It does not hide your IP and does not block ads."
echo "      (Extreme level: DNS is forced to AdGuard and locked, nothing to do.)"
echo ""
echo "Verify: brave://policy"
echo "Undo:   ./setup.sh --restore   (or run again and choose 4) Restore)"
echo ""
