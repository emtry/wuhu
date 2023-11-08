@echo off

set /p id=

if not exist "C:\Users\%USERNAME%\AppData\Roaming\Stool\" (
        mkdir "C:\Users\%USERNAME%\AppData\Roaming\Stool\"
	copy /y "%~dp0utils\ManifestAutoUpdate\info.pak" "C:\Users\%USERNAME%\AppData\Roaming\Stool\"
    ) else (
        copy /y "%~dp0utils\ManifestAutoUpdate\info.pak" "C:\Users\%USERNAME%\AppData\Roaming\Stool\"
    )

cd /d "%~dp0utils\ManifestAutoUpdate"
SteamXP -r emtry/ManifestAutoUpdate -a %id%

pause