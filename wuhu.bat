@echo off & setlocal enabledelayedexpansion

if not exist "%~dp0utils\GreenLuma\AppList" (
        mkdir "%~dp0utils\GreenLuma\AppList\"
    ) else (
        del /Q "%~dp0utils\GreenLuma\AppList\"
    )

set n=0
for %%i in ("%~dp0List\*.TXT") do (
for /f "usebackq delims=" %%j in ("%%i") do (
        echo/%%~j>"%~dp0utils\GreenLuma\AppList\"^!n^!.txt
        set /a n+=1
    )
)


:start
taskkill /F /IM steam.exe >nul 2>&1
cd /d "%~dp0utils\GreenLuma"
DeleteSteamAppCache.exe
DLLInjector.exe

exit
