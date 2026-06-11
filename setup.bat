@echo off
chcp 65001 >nul 2>&1
title Brave Origin - Debloat + Speed Fix
cd /d "%~dp0"
setlocal enabledelayedexpansion

echo ==========================================
echo   Brave Origin - Windows Setup
echo   ☕ buymeacoffee.com/AilieIsQueen
echo ==========================================
echo.
echo [!] Run as Administrator!
echo     Right-click this file -^> "Run as administrator"
echo.

:: --- Check admin ---
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo [x] Please re-run as Administrator.
    pause
    exit /b 1
)

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

:: --- 1. Registry policies ---
echo.
echo [1] Deploying registry policies...

reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /f >nul 2>&1

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

reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BraveP3AEnabled              /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BraveStatsPingEnabled        /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BraveWebDiscoveryEnabled     /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v SyncDisabled                 /t REG_DWORD /d 1 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BackgroundModeEnabled        /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v MetricsReportingEnabled      /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v ComponentUpdatesEnabled      /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v HighEfficiencyModeEnabled    /t REG_DWORD /d 1 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DnsOverHttpsMode             /t REG_SZ     /d "secure" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DnsOverHttpsTemplates        /t REG_SZ     /d "https://dns.adguard-dns.com/dns-query" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v SafeBrowsingProtectionLevel  /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v AlternateErrorPagesEnabled   /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v NetworkPredictionOptions     /t REG_DWORD /d 0 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v PrivacySandboxAdTopicsEnabled       /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v PrivacySandboxPromptEnabled         /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v PrivacySandboxSiteEnabledAdsEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v PaymentMethodQueryEnabled           /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v UserFeedbackAllowed                 /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v SearchSuggestEnabled                /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v SpellcheckEnabled                   /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v HttpsUpgradesEnabled                /t REG_DWORD /d 1 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v PasswordManagerEnabled         /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v AutofillAddressEnabled         /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v AutofillCreditCardEnabled      /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v TranslateEnabled               /t REG_DWORD /d 0 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DeveloperToolsAvailability     /t REG_DWORD /d 2 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v IncognitoModeAvailability      /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BrowserAddPersonEnabled        /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BrowserGuestModeEnabled        /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DefaultBrowserSettingEnabled   /t REG_DWORD /d 0 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v BookmarkBarEnabled             /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v ShowHomeButton                 /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v HomepageLocation               /t REG_SZ     /d "about:blank" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v NewTabPageLocation             /t REG_SZ     /d "about:blank" /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DefaultSearchProviderEnabled   /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DefaultSearchProviderName      /t REG_SZ     /d "Brave Search" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DefaultSearchProviderSearchURL /t REG_SZ     /d "https://search.brave.com/search?q={searchTerms}" /f >nul 2>&1

reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v DownloadRestrictions           /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v PromptForDownloadLocation      /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\BraveSoftware\Brave" /v PrintingEnabled                /t REG_DWORD /d 1 /f >nul 2>&1

echo    Policies applied.

:: --- 2. Brave shortcut flags note ---
echo.
if defined BRAVE_EXE (
    echo [2] Add these flags to your Brave shortcut for extra debloat:
    echo     Target: !BRAVE_EXE! --disable-features=AIChat,BraveVPN --enable-features=HighEfficiencyMode
)

echo.
echo ==========================================
echo  DONE
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
echo.
pause
