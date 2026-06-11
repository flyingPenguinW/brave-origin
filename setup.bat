@echo off
chcp 65001 >nul
title Brave Origin - Debloat + Speed Fix
echo ==========================================
echo   Brave Origin - Windows Setup
echo ==========================================
echo.
echo [!] Run as Administrator!
echo     Right-click this file -> "Run as administrator"
echo.

:: ------------------------------------------------------------
:: Check admin rights
:: ------------------------------------------------------------
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo [x] Please re-run this as Administrator.
    pause
    exit /b 1
)

echo [1] Deploying registry policies...
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\BraveSoftware\Brave" /f >nul 2>&1

:: --- Brave bloat features ---
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BraveRewardsDisabled         /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BraveWalletDisabled          /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BraveVPNDisabled             /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BraveAIChatEnabled           /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BraveNewsDisabled            /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BraveTalkDisabled            /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v TorDisabled                  /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BraveSpeedreaderEnabled      /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BraveWaybackMachineEnabled   /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BravePlaylistEnabled         /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Telemetry ---
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BraveP3AEnabled              /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BraveStatsPingEnabled        /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BraveWebDiscoveryEnabled     /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v SyncDisabled                 /t REG_DWORD /d 1 /f >nul 2>&1

:: --- Background / RAM saving ---
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BackgroundModeEnabled        /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v MetricsReportingEnabled      /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v ComponentUpdatesEnabled      /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v HighEfficiencyModeEnabled    /t REG_DWORD /d 1 /f >nul 2>&1

:: --- Privacy hardening ---
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DnsOverHttpsMode             /t REG_SZ     /d "secure" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DnsOverHttpsTemplates        /t REG_SZ     /d "https://dns.adguard-dns.com/dns-query" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v SafeBrowsingProtectionLevel  /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v AlternateErrorPagesEnabled   /t REG_DWORD /d 0 /f >nul 2>&1

:: --- SPEED FIX: Re-enable network prediction (DNS prefetch, TCP preconnect) ---
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v NetworkPredictionOptions     /t REG_DWORD /d 0 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v PrivacySandboxAdTopicsEnabled       /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v PrivacySandboxPromptEnabled         /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v PrivacySandboxSiteEnabledAdsEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v PaymentMethodQueryEnabled           /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v UserFeedbackAllowed                 /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v SearchSuggestEnabled                /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v SpellcheckEnabled                   /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v HttpsUpgradesEnabled                /t REG_DWORD /d 1 /f >nul 2>&1

:: --- Autofill / passwords / translate ---
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v PasswordManagerEnabled         /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v AutofillAddressEnabled         /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v AutofillCreditCardEnabled      /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v TranslateEnabled               /t REG_DWORD /d 0 /f >nul 2>&1

:: --- Dev tools ---
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DeveloperToolsAvailability     /t REG_DWORD /d 2 /f >nul 2>&1

:: --- Browser modes ---
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v IncognitoModeAvailability      /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BrowserAddPersonEnabled        /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BrowserGuestModeEnabled        /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DefaultBrowserSettingEnabled   /t REG_DWORD /d 0 /f >nul 2>&1

:: --- UI tweaks ---
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BookmarkBarEnabled             /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v ShowHomeButton                 /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v HomepageLocation               /t REG_SZ     /d "about:blank" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v NewTabPageLocation             /t REG_SZ     /d "about:blank" /f >nul 2>&1

:: --- Search (locked to Brave, Google, DDG) ---
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DefaultSearchProviderEnabled   /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DefaultSearchProviderName      /t REG_SZ     /d "Brave Search" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DefaultSearchProviderSearchURL /t REG_SZ     /d "https://search.brave.com/search?q={searchTerms}" /f >nul 2>&1

:: --- Downloads / printing ---
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DownloadRestrictions           /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v PromptForDownloadLocation      /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v PrintingEnabled                /t REG_DWORD /d 1 /f >nul 2>&1

echo    -> All policies applied.

:: ------------------------------------------------------------
::  Patch Brave shortcut to add command-line flags
:: ------------------------------------------------------------
echo [2] Patching Brave shortcut...

set BRAVE_SHORTCUT="%PROGRAMFILES%\BraveSoftware\Brave-Browser\Application\brave.exe"
if not exist %BRAVE_SHORTCUT% set BRAVE_SHORTCUT="%LOCALAPPDATA%\BraveSoftware\Brave-Browser\Application\brave.exe"
if not exist %BRAVE_SHORTCUT% (
    echo    [!] Could not find brave.exe - add flags manually:
    echo        --disable-features=AIChat,BraveVPN
    echo        --enable-features=HighEfficiencyMode
) else (
    echo    [!] Please add these flags to your Brave shortcut:
    echo        Target: %BRAVE_SHORTCUT% --disable-features=AIChat,BraveVPN --enable-features=HighEfficiencyMode
    echo.
)

:: ------------------------------------------------------------
echo.
echo ==========================================
echo  DONE
echo ==========================================
echo.
echo [*] Fully restart Brave (close all processes).
echo [*] Verify at brave://policy
echo.
echo --- POST-SETUP (do these once in Brave) ---
echo.
echo  Fix SLOW LOADING:
echo    brave://settings/privacy
echo      -> If still slow, change DNS to Cloudflare:
echo         "https://cloudflare-dns.com/dns-query"
echo.
echo  brave://flags/#brave-sidebar
echo      -> Disabled
echo.
echo  brave://settings/appearance
echo      -> "Use system title bar and borders" ON
echo.
echo  brave://flags/#enable-zero-copy
echo      -> Enabled
echo.
echo  brave://flags/#enable-parallel-downloading
echo      -> Enabled
echo.
echo  brave://settings/system
echo      -> "Memory Saver" ON
echo.
pause
