@echo off
title=自动更新中
set pwd=%~dp0
rmdir /q/s "%pwd:~0,-7%\GreenLuma 2020"
mkdir "%pwd%tmp"
copy "%pwd:~0,-7%\version.txt"  c:\
cls
for /F %%i in (c:\version.txt) do (set version=%%i)
for /F %%j in ('curl https://gh.api.99988866.xyz/https://raw.githubusercontent.com/emtry/wuhu/master/version.txt') do (set last=%%j)
echo %last|findstr "404" >nul
set status=%errorlevel%
echo %last|findstr "1." >nul
set flag=%errorlevel%
del c:\version.txt
cls
if %version% == %last% ( 
 echo No releases
) ^
else if %status% neq 1 (
 echo 404
)^
else if %flag% equ 1 (
 if %version% neq %last% (
  echo New release %last%
  curl -o "%pwd%tmp\wuhu_%last%.zip" https://gh.api.99988866.xyz/https://github.com/emtry/wuhu/archive/master.zip
  unzip -o -d "%pwd%tmp" "%pwd%tmp\wuhu_%last%.zip"
  xcopy /s/e/y "%pwd%tmp\wuhu-master\*" "%pwd:~0,-7%"
  rmdir /q/s "%pwd%tmp\wuhu-master"
 )
)^
else (
 echo %last%
)
pause