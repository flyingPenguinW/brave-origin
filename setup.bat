@echo off
chcp 65001 >nul 2>&1
title Brave Origin - Debloat + Speed Fix
cd /d "%~dp0"
setlocal enabledelayedexpansion

:: ---------------------------------------------------------------------------
:: Usage:  right-click -> Run as administrator   (interactive menu)
::         setup.bat /restore                    (undo, from backup)
:: Levels: 1) Hard  2) Extreme  3) Custom  4) Restore original
:: ---------------------------------------------------------------------------

set "KEY=HKLM\SOFTWARE\Policies\BraveSoftware\Brave"
set "BACKUP_DIR=%USERPROFILE%\.brave-origin-backup"

echo ==========================================
echo   Brave Origin - Windows Setup
echo   ☕ buymeacoffee.com/AilieIsQueen
echo ==========================================
echo.

:: --- Check admin ---
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo [x] Please re-run as Administrator.
    echo     Right-click this file -^> "Run as administrator"
    pause
    exit /b 1
)

if /i "%~1"=="/restore" goto :do_restore

:: --- Menu ---
call :print_levels

:choose
set "CHOICE="
set /p "CHOICE=Choose level [1-4]: "
if "!CHOICE!"=="1" set "LEVEL_NAME=Hard" & set "ALL=h" & goto :all_levels
if "!CHOICE!"=="2" set "LEVEL_NAME=Extreme" & set "ALL=e" & goto :all_levels
if "!CHOICE!"=="3" goto :custom
if "!CHOICE!"=="4" goto :do_restore
echo Please enter 1, 2, 3 or 4.
goto :choose

:all_levels
for %%C in (services ai reader telemetry privacy sync passwords languages ui devtools search perf) do set "LV_%%C=!ALL!"
goto :chosen

:custom
set "LEVEL_NAME=Custom"
echo.
call :ask services "Brave services" "same as Extreme" "Rewards, Wallet, VPN, News, Talk, Tor, Playlist, Wayback Machine OFF"
call :ask ai "Leo AI" "Leo AI stays ON" "Leo AI OFF, policy and AIChat feature flag"
call :ask reader "Speedreader" "Speedreader ON" "Speedreader OFF"
call :ask telemetry "Telemetry and tracking" "same as Extreme" "P3A, stats ping, metrics, web discovery, feedback, Privacy Sandbox, prediction, search suggestions OFF"
call :ask privacy "DNS and Safe Browsing" "DNS-over-HTTPS not forced, you choose in browser settings, Safe Browsing Standard" "DNS-over-HTTPS forced via AdGuard, no fallback, Safe Browsing Standard"
call :ask sync "Sync and profiles" "Sync allowed per profile, profiles and guest mode untouched" "Sync OFF for all profiles, adding profiles and guest mode blocked"
call :ask passwords "Passwords and autofill" "Password manager OFF, address autofill ON, card autofill left to you" "Password manager, address autofill, card autofill OFF"
call :ask languages "Translate and spellcheck" "Translate and local spellcheck ON, Google spellcheck service stays OFF" "Translate and spellcheck OFF"
call :ask ui "Interface" "Bookmarks bar shown, no home button, homepage about:blank, new tab unchanged so extensions can replace it, no default-browser nag" "Bookmarks bar hidden, no home button, homepage and new tab about:blank, no default-browser nag"
call :ask devtools "Developer tools" "DevTools enabled" "DevTools disabled"
call :ask search "Search engine" "Search engine left to you, not overridden" "Default search engine Brave Search, list restricted to Brave Search, Google, DuckDuckGo"
call :ask perf "Performance and misc" "same as Extreme" "Background mode OFF so Brave quits when the last window closes, Memory Saver ON, HTTPS upgrades ON, incognito, printing and downloads allowed"
goto :chosen

:chosen
echo.

:: --- Detect Brave install paths ---
set "BRAVE_NORMAL=%PROGRAMFILES%\BraveSoftware\Brave-Browser\Application"
set "BRAVE_STORE=%LOCALAPPDATA%\BraveSoftware\Brave-Browser\Application"
set "BRAVE_EXE="

if exist "%BRAVE_NORMAL%\brave.exe" set "BRAVE_EXE=%BRAVE_NORMAL%\brave.exe"
if exist "%BRAVE_STORE%\brave.exe"  set "BRAVE_EXE=%BRAVE_STORE%\brave.exe"

if defined BRAVE_EXE (
    echo [*] Brave found: %BRAVE_EXE%
    if "!BRAVE_EXE:%PROGRAMFILES%=!" neq "!BRAVE_EXE!" (
        echo     Route: Normal install
    ) else (
        echo     Route: Store install
    )
) else (
    echo [!] Brave not found at expected paths.
    echo     Normal: %BRAVE_NORMAL%
    echo     Store:  %BRAVE_STORE%
)

:: --- 0. Backup ---
echo.
echo A backup lets you undo everything later with: setup.bat /restore
if exist "%BACKUP_DIR%" goto :backup_exists
call :ask_yn "Do you want to create a Brave backup? (strongly recommended)"
if !errorlevel! equ 0 goto :do_backup
echo [!] Continuing WITHOUT backup.
call :ask_yn "Are you sure?"
if !errorlevel! neq 0 goto :aborted
goto :after_backup

:backup_exists
echo [*] Backup already exists - keeping the original one.
echo     %BACKUP_DIR%
goto :after_backup

:do_backup
mkdir "%BACKUP_DIR%" >nul 2>&1
reg query "%KEY%" >nul 2>&1
if !errorlevel! equ 0 (
    reg export "%KEY%" "%BACKUP_DIR%\policy.reg" /y >nul 2>&1
) else (
    type nul > "%BACKUP_DIR%\policy.absent"
)
echo [*] Backup saved to %BACKUP_DIR%

:after_backup
echo.

:: --- 1. Registry policies ---
echo [1] Deploying registry policies (!LEVEL_NAME!)...

:: Remove values managed by this script first, so switching levels leaves nothing stale.
:: Other policies under the same key are not touched.
call :delete_managed

reg add "%KEY%" /f >nul 2>&1

call :cat_services "!LV_services!"
call :cat_ai "!LV_ai!"
call :cat_reader "!LV_reader!"
call :cat_telemetry "!LV_telemetry!"
call :cat_privacy "!LV_privacy!"
call :cat_sync "!LV_sync!"
call :cat_passwords "!LV_passwords!"
call :cat_languages "!LV_languages!"
call :cat_ui "!LV_ui!"
call :cat_devtools "!LV_devtools!"
call :cat_search "!LV_search!"
call :cat_perf "!LV_perf!"

echo     Policies applied.

:: --- 2. Brave shortcut flags note ---
set "DISABLE_FEATURES=BraveVPN"
if "!LV_ai!"=="e" set "DISABLE_FEATURES=AIChat,BraveVPN"
echo.
if defined BRAVE_EXE (
    echo [2] Add these flags to your Brave shortcut for extra debloat:
    echo     Target: !BRAVE_EXE! --disable-features=!DISABLE_FEATURES! --enable-features=HighEfficiencyMode
)

echo.
echo ==========================================
echo  DONE (!LEVEL_NAME!)
echo  ☕ buymeacoffee.com/AilieIsQueen
echo ==========================================
echo.
echo [*] Fully restart Brave (close all processes).
echo [*] Verify at brave://policy
echo.
echo Manual steps (do once in Brave):
echo.
echo   brave://flags/#brave-sidebar        -^> Disabled
echo   brave://flags/#enable-zero-copy      -^> Enabled
echo   brave://flags/#enable-parallel-downloading -^> Enabled
echo   brave://settings/appearance          -^> "Use system title bar and borders" ON
echo   brave://settings/system              -^> "Memory Saver" ON
echo   brave://settings/security            -^> "Use secure DNS" (choose a provider)
echo       DoH (DNS-over-HTTPS) encrypts the website lookups your browser makes,
echo       so your ISP and the local network can't see which sites you visit.
echo       It does not hide your IP and does not block ads.
echo       (Extreme level: DNS is forced to AdGuard and locked, nothing to do.)
echo.
echo Undo:   setup.bat /restore   (or run again and choose 4) Restore)
echo.
pause
exit /b 0

:aborted
echo Aborted.
pause
exit /b 0

:: ===========================================================================
:: Restore
:: ===========================================================================
:do_restore
echo ==========================================
echo   Brave Origin - Restore original values
echo ==========================================
echo.
if exist "%BACKUP_DIR%" (
    echo [*] Using backup: %BACKUP_DIR%
) else (
    echo [!] No backup found in %BACKUP_DIR%.
    echo     Restore will just remove the policy values created by this script.
)
call :ask_yn "Restore Brave to its previous state?"
if !errorlevel! neq 0 goto :aborted

echo [1] Policies...
call :delete_managed
if exist "%BACKUP_DIR%\policy.reg" reg import "%BACKUP_DIR%\policy.reg" >nul 2>&1

echo.
echo Done. Fully restart Brave and check brave://policy
echo Manual flags/settings (brave://flags, brave://settings) and the shortcut
echo flags are not touched by this script - revert them by hand if you changed them.
echo.
pause
exit /b 0

:: ===========================================================================
:: Helpers
:: ===========================================================================
:delete_managed
for %%V in (BraveRewardsDisabled BraveWalletDisabled BraveVPNDisabled BraveNewsDisabled BraveTalkDisabled TorDisabled BravePlaylistEnabled BraveWaybackMachineEnabled BraveAIChatEnabled BraveSpeedreaderEnabled BraveP3AEnabled BraveStatsPingEnabled BraveWebDiscoveryEnabled MetricsReportingEnabled UserFeedbackAllowed PrivacySandboxAdTopicsEnabled PrivacySandboxPromptEnabled PrivacySandboxSiteEnabledAdsEnabled PaymentMethodQueryEnabled AlternateErrorPagesEnabled NetworkPredictionOptions SearchSuggestEnabled SafeBrowsingProtectionLevel DnsOverHttpsMode DnsOverHttpsTemplates SyncDisabled BrowserAddPersonEnabled BrowserGuestModeEnabled PasswordManagerEnabled AutofillAddressEnabled AutofillCreditCardEnabled TranslateEnabled SpellcheckEnabled SpellcheckServiceEnabled ShowHomeButton HomepageLocation DefaultBrowserSettingEnabled BookmarkBarEnabled NewTabPageLocation DeveloperToolsAvailability ManagedSearchEngines DefaultSearchProviderEnabled DefaultSearchProviderName DefaultSearchProviderSearchURL BackgroundModeEnabled HighEfficiencyModeEnabled ComponentUpdatesEnabled HttpsUpgradesEnabled IncognitoModeAvailability DownloadRestrictions PromptForDownloadLocation PrintingEnabled) do reg delete "%KEY%" /v %%V /f >nul 2>&1
exit /b 0

:dw
reg add "%KEY%" /v %~1 /t REG_DWORD /d %~2 /f >nul 2>&1
exit /b 0

:sz
reg add "%KEY%" /v %~1 /t REG_SZ /d "%~2" /f >nul 2>&1
exit /b 0

:ask_yn
set "REPLY="
set /p "REPLY=%~1 [y/n]: "
if /i "!REPLY!"=="y" exit /b 0
if /i "!REPLY!"=="yes" exit /b 0
if /i "!REPLY!"=="n" exit /b 1
if /i "!REPLY!"=="no" exit /b 1
echo Please answer y or n.
goto :ask_yn

:ask
echo * %~2
echo     h) Hard:    %~3
echo     e) Extreme: %~4
echo     s) Skip:    leave Brave default
:ask_loop
set "ANS="
set /p "ANS=  [h/e/s]: "
if /i "!ANS!"=="h" set "LV_%~1=h" & exit /b 0
if /i "!ANS!"=="e" set "LV_%~1=e" & exit /b 0
if /i "!ANS!"=="s" set "LV_%~1=s" & exit /b 0
echo   Please answer h, e or s.
goto :ask_loop

:print_levels
echo Debloat levels:
echo.
echo   1) HARD     - same debloat, but keeps features you may actually use. (recommended)
echo   2) EXTREME  - maximum lockdown, everything disabled.
echo   3) CUSTOM   - choose Hard / Extreme / Skip for each category.
echo   4) RESTORE  - back to the original Brave state (from backup).
echo.
echo   +--------------------------------+----------------------+------------------------+
echo   ^| Setting                        ^| EXTREME              ^| HARD                   ^|
echo   +--------------------------------+----------------------+------------------------+
echo   ^| Same in both                                                                   ^|
echo   ^| Safe Browsing                  ^| Standard (Enhanced shares more visited links) ^|
echo   +--------------------------------+----------------------+------------------------+
echo   ^| Disabled in both                                                               ^|
echo   ^| Rewards/Wallet/VPN/News/Tor    ^| off                  ^| off                    ^|
echo   ^| Telemetry ^& tracking           ^| off                  ^| off                    ^|
echo   ^| Password manager               ^| off                  ^| off                    ^|
echo   ^| Search suggestions             ^| off                  ^| off                    ^|
echo   ^| Background mode                ^| off                  ^| off                    ^|
echo   +--------------------------------+----------------------+------------------------+
echo   ^| Differences                                                                    ^|
echo   ^| Leo AI                         ^| off                  ^| ON                     ^|
echo   ^| Speedreader                    ^| off                  ^| ON                     ^|
echo   ^| Sync                           ^| off (all profiles)   ^| ON                     ^|
echo   ^| Add profile / guest mode       ^| blocked              ^| allowed                ^|
echo   ^| Address autofill               ^| off                  ^| ON                     ^|
echo   ^| Card autofill                  ^| off                  ^| Brave default          ^|
echo   ^| Translate ^& spellcheck         ^| off                  ^| ON                     ^|
echo   ^| Bookmarks bar                  ^| hidden               ^| shown                  ^|
echo   ^| New tab page                   ^| about:blank          ^| unchanged              ^|
echo   ^| DevTools                       ^| off                  ^| ON                     ^|
echo   ^| DNS-over-HTTPS                 ^| forced (AdGuard)     ^| your choice            ^|
echo   ^| Default search engine          ^| Brave Search         ^| your choice            ^|
echo   +--------------------------------+----------------------+------------------------+
echo.
echo   Both levels: homepage = about:blank, Memory Saver ON, HTTPS upgrades ON.
echo   Policies lock the matching options in brave://settings
echo   ("managed by your organization"). Option 4 undoes this.
echo.
exit /b 0

:: ===========================================================================
:: Categories: what each level writes
:: ===========================================================================
:cat_services
if "%~1"=="s" exit /b 0
call :dw BraveRewardsDisabled 1
call :dw BraveWalletDisabled 1
call :dw BraveVPNDisabled 1
call :dw BraveNewsDisabled 1
call :dw BraveTalkDisabled 1
call :dw TorDisabled 1
call :dw BravePlaylistEnabled 0
call :dw BraveWaybackMachineEnabled 0
exit /b 0

:cat_ai
if "%~1"=="s" exit /b 0
if "%~1"=="e" (
  call :dw BraveAIChatEnabled 0
)
exit /b 0

:cat_reader
if "%~1"=="s" exit /b 0
if "%~1"=="e" (
  call :dw BraveSpeedreaderEnabled 0
)
if "%~1"=="h" (
  call :dw BraveSpeedreaderEnabled 1
)
exit /b 0

:cat_telemetry
if "%~1"=="s" exit /b 0
call :dw BraveP3AEnabled 0
call :dw BraveStatsPingEnabled 0
call :dw BraveWebDiscoveryEnabled 0
call :dw MetricsReportingEnabled 0
call :dw UserFeedbackAllowed 0
call :dw PrivacySandboxAdTopicsEnabled 0
call :dw PrivacySandboxPromptEnabled 0
call :dw PrivacySandboxSiteEnabledAdsEnabled 0
call :dw PaymentMethodQueryEnabled 0
call :dw AlternateErrorPagesEnabled 0
call :dw NetworkPredictionOptions 0
call :dw SearchSuggestEnabled 0
exit /b 0

:cat_privacy
if "%~1"=="s" exit /b 0
call :dw SafeBrowsingProtectionLevel 1
if "%~1"=="e" (
  call :sz DnsOverHttpsMode "secure"
  call :sz DnsOverHttpsTemplates "https://dns.adguard-dns.com/dns-query"
)
exit /b 0

:cat_sync
if "%~1"=="s" exit /b 0
if "%~1"=="e" (
  call :dw SyncDisabled 1
  call :dw BrowserAddPersonEnabled 0
  call :dw BrowserGuestModeEnabled 0
)
exit /b 0

:cat_passwords
if "%~1"=="s" exit /b 0
call :dw PasswordManagerEnabled 0
if "%~1"=="e" (
  call :dw AutofillAddressEnabled 0
  call :dw AutofillCreditCardEnabled 0
)
if "%~1"=="h" (
  call :dw AutofillAddressEnabled 1
)
exit /b 0

:cat_languages
if "%~1"=="s" exit /b 0
if "%~1"=="e" (
  call :dw TranslateEnabled 0
  call :dw SpellcheckEnabled 0
  call :dw SpellcheckServiceEnabled 0
)
if "%~1"=="h" (
  call :dw TranslateEnabled 1
  call :dw SpellcheckEnabled 1
  call :dw SpellcheckServiceEnabled 0
)
exit /b 0

:cat_ui
if "%~1"=="s" exit /b 0
call :dw ShowHomeButton 0
call :sz HomepageLocation "about:blank"
call :dw DefaultBrowserSettingEnabled 0
if "%~1"=="e" (
  call :dw BookmarkBarEnabled 0
  call :sz NewTabPageLocation "about:blank"
)
if "%~1"=="h" (
  call :dw BookmarkBarEnabled 1
)
exit /b 0

:cat_devtools
if "%~1"=="s" exit /b 0
if "%~1"=="e" (
  call :dw DeveloperToolsAvailability 2
)
if "%~1"=="h" (
  call :dw DeveloperToolsAvailability 1
)
exit /b 0

:cat_search
if "%~1"=="s" exit /b 0
if "%~1"=="e" (
  powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand UwBlAHQALQBJAHQAZQBtAFAAcgBvAHAAZQByAHQAeQAgAC0ARgBvAHIAYwBlACAALQBQAGEAdABoACAAJwBIAEsATABNADoAXABTAE8ARgBUAFcAQQBSAEUAXABQAG8AbABpAGMAaQBlAHMAXABCAHIAYQB2AGUAUwBvAGYAdAB3AGEAcgBlAFwAQgByAGEAdgBlACcAIAAtAE4AYQBtAGUAIAAnAE0AYQBuAGEAZwBlAGQAUwBlAGEAcgBjAGgARQBuAGcAaQBuAGUAcwAnACAALQBUAHkAcABlACAAUwB0AHIAaQBuAGcAIAAtAFYAYQBsAHUAZQAgACcAWwB7ACIAbgBhAG0AZQAiADoAIgBCAHIAYQB2AGUAIABTAGUAYQByAGMAaAAiACwAIgBrAGUAeQB3AG8AcgBkACIAOgAiAHMAZQBhAHIAYwBoAC4AYgByAGEAdgBlAC4AYwBvAG0AIgAsACIAcwBlAGEAcgBjAGgAXwB1AHIAbAAiADoAIgBoAHQAdABwAHMAOgAvAC8AcwBlAGEAcgBjAGgALgBiAHIAYQB2AGUALgBjAG8AbQAvAHMAZQBhAHIAYwBoAD8AcQA9AHsAcwBlAGEAcgBjAGgAVABlAHIAbQBzAH0AIgAsACIAcwB1AGcAZwBlAHMAdABfAHUAcgBsACIAOgAiAGgAdAB0AHAAcwA6AC8ALwBzAGUAYQByAGMAaAAuAGIAcgBhAHYAZQAuAGMAbwBtAC8AYQBwAGkALwBzAHUAZwBnAGUAcwB0AD8AcQA9AHsAcwBlAGEAcgBjAGgAVABlAHIAbQBzAH0AIgAsACIAZQBuAGMAbwBkAGkAbgBnACIAOgAiAFUAVABGAC0AOAAiACwAIgBmAGEAdgBpAGMAbwBuAF8AdQByAGwAIgA6ACIAaAB0AHQAcABzADoALwAvAGIAcgBhAHYAZQAuAGMAbwBtAC8AZgBhAHYAaQBjAG8AbgAuAGkAYwBvACIAfQAsAHsAIgBuAGEAbQBlACIAOgAiAEcAbwBvAGcAbABlACIALAAiAGsAZQB5AHcAbwByAGQAIgA6ACIAZwBvAG8AZwBsAGUALgBjAG8AbQAiACwAIgBzAGUAYQByAGMAaABfAHUAcgBsACIAOgAiAGgAdAB0AHAAcwA6AC8ALwB3AHcAdwAuAGcAbwBvAGcAbABlAC4AYwBvAG0ALwBzAGUAYQByAGMAaAA/AHEAPQB7AHMAZQBhAHIAYwBoAFQAZQByAG0AcwB9ACIALAAiAHMAdQBnAGcAZQBzAHQAXwB1AHIAbAAiADoAIgBoAHQAdABwAHMAOgAvAC8AdwB3AHcALgBnAG8AbwBnAGwAZQAuAGMAbwBtAC8AYwBvAG0AcABsAGUAdABlAC8AcwBlAGEAcgBjAGgAPwBvAHUAdABwAHUAdAA9AGMAaAByAG8AbQBlACYAcQA9AHsAcwBlAGEAcgBjAGgAVABlAHIAbQBzAH0AIgAsACIAZQBuAGMAbwBkAGkAbgBnACIAOgAiAFUAVABGAC0AOAAiACwAIgBmAGEAdgBpAGMAbwBuAF8AdQByAGwAIgA6ACIAaAB0AHQAcABzADoALwAvAHcAdwB3AC4AZwBvAG8AZwBsAGUALgBjAG8AbQAvAGYAYQB2AGkAYwBvAG4ALgBpAGMAbwAiAH0ALAB7ACIAbgBhAG0AZQAiADoAIgBEAHUAYwBrAEQAdQBjAGsARwBvACIALAAiAGsAZQB5AHcAbwByAGQAIgA6ACIAZAB1AGMAawBkAHUAYwBrAGcAbwAuAGMAbwBtACIALAAiAHMAZQBhAHIAYwBoAF8AdQByAGwAIgA6ACIAaAB0AHQAcABzADoALwAvAGQAdQBjAGsAZAB1AGMAawBnAG8ALgBjAG8AbQAvAD8AcQA9AHsAcwBlAGEAcgBjAGgAVABlAHIAbQBzAH0AIgAsACIAcwB1AGcAZwBlAHMAdABfAHUAcgBsACIAOgAiAGgAdAB0AHAAcwA6AC8ALwBkAHUAYwBrAGQAdQBjAGsAZwBvAC4AYwBvAG0ALwBhAGMALwA/AHEAPQB7AHMAZQBhAHIAYwBoAFQAZQByAG0AcwB9ACYAdAB5AHAAZQA9AGwAaQBzAHQAIgAsACIAZQBuAGMAbwBkAGkAbgBnACIAOgAiAFUAVABGAC0AOAAiACwAIgBmAGEAdgBpAGMAbwBuAF8AdQByAGwAIgA6ACIAaAB0AHQAcABzADoALwAvAGQAdQBjAGsAZAB1AGMAawBnAG8ALgBjAG8AbQAvAGYAYQB2AGkAYwBvAG4ALgBpAGMAbwAiAH0AXQAnAA== >nul 2>&1
  call :dw DefaultSearchProviderEnabled 1
  call :sz DefaultSearchProviderName "Brave Search"
  call :sz DefaultSearchProviderSearchURL "https://search.brave.com/search?q={searchTerms}"
)
exit /b 0

:cat_perf
if "%~1"=="s" exit /b 0
call :dw BackgroundModeEnabled 0
call :dw HighEfficiencyModeEnabled 1
call :dw ComponentUpdatesEnabled 1
call :dw HttpsUpgradesEnabled 1
call :dw IncognitoModeAvailability 0
call :dw DownloadRestrictions 0
call :dw PromptForDownloadLocation 1
call :dw PrintingEnabled 1
exit /b 0

