@echo off

set /p id=

cd /d "%~dp0utils\ManifestAutoUpdate"
SteamXP -r emtry/ManifestAutoUpdate -a %id%

pause

taskkill /F /IM steam.exe >nul 2>&1
start "" steam://install/%id%