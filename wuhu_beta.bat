@echo off & setlocal enabledelayedexpansion

if not exist "%~dp0utils\GreenLuma_beta\AppList" (
        mkdir "%~dp0utils\GreenLuma_beta\AppList\"
    ) else (
        del /Q "%~dp0utils\GreenLuma_beta\AppList\"
    )

set n=0
for %%i in ("%~dp0List\*.TXT") do (
for /f "usebackq delims=" %%j in ("%%i") do (
        echo/%%~j>"%~dp0utils\GreenLuma_beta\AppList\"^!n^!.txt
        set /a n+=1
    )
)


:start
taskkill /F /IM steam.exe >nul 2>&1
DeleteSteamAppCache.exe
cd /d "%~dp0utils\GreenLuma_beta"
DLLInjector.exe

exit
