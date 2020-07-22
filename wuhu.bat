@echo off & setlocal enabledelayedexpansion

del /Q "%~dp0GreenLuma 2020\AppList\"
mkdir "%~dp0GreenLuma 2020\AppList\"

set n=0
for %%i in ("%~dp0List\*.TXT") do (
for /f "usebackq delims=" %%j in ("%%i") do (
        echo/%%~j>"%~dp0GreenLuma 2020\AppList\"^!n^!.txt
        set /a n+=1
    )
)


:start
taskkill /F /IM steam.exe >nul 2>&1
cd /d "%~dp0GreenLuma 2020"
DLLInjector.exe

exit