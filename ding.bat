@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

if exist "%~dp0..\config\config.vdf" (
    md "%~dp0utils\ManifestHub\backup" 2>nul
    for /f %%t in ('powershell -Command "Get-Date -Format 'yyyyMMdd_HHmmss'"') do set timestamp=%%t
    copy "%~dp0..\config\config.vdf" "%~dp0utils\ManifestHub\backup\config_!timestamp!.vdf" >nul
)

for %%i in ("%~dp0List\*.TXT") do (
    for /f "usebackq delims=" %%j in ("%%i") do (
        echo.
        echo 正在处理 AppID: %%j
        
        md "%~dp0utils\ManifestHub\%%j" 2>nul
        
        echo 正在获取游戏信息...
        curl -s "https://steamui.com/get_appinfo.php?appid=%%j" > "%~dp0utils\ManifestHub\temp_%%j.txt"
        
        echo 正在提取 depot 信息...
        powershell -Command ^
        "Select-String -Pattern '^\s*""(\d{3,7})""' -Path '%~dp0utils\ManifestHub\temp_%%j.txt' |"^
        "  ForEach-Object { $_.Matches[0].Groups[1].Value } |"^
        "  Set-Content -Encoding ASCII '%~dp0utils\ManifestHub\%%j\%%j.txt'"
        
        del "%~dp0utils\ManifestHub\temp_%%j.txt"
        
        set "api_url=https://api.github.com/repos/emtry/ManifestHub/branches/%%j"
        echo 正在查询 GitHub 分支信息...
        curl -s "!api_url!" > "%~dp0utils\ManifestHub\temp_branch_%%j.json"
        powershell -Command ^
        "$appId = '%%j'; "^
        "$branchFile = '%~dp0utils\ManifestHub\temp_branch_' + $appId + '.json'; "^
        "$localPath = '%~dp0utils\ManifestHub\' + $appId; "^
        "try { "^
        "    if ((Test-Path $branchFile) -and ($branchData = Get-Content $branchFile -Raw | ConvertFrom-Json) -and ($branchData.commit)) { "^
        "        $treeUrl = $branchData.commit.commit.tree.url; "^
        "        $treeData = Invoke-RestMethod -Uri $treeUrl -Headers @{'User-Agent'='PowerShell'}; "^
        "        if ($treeData.tree) { "^
        "            $downloadCount = 0; "^
        "            foreach ($item in $treeData.tree) { "^
        "                $fileName = $item.path; "^
        "                if ($fileName -match '\.(manifest|vdf)$' -or $fileName -match '^(Key|key|config)\.vdf$') { "^
        "                    $downloadUrl = 'https://raw.githubusercontent.com/emtry/ManifestHub/' + $appId + '/' + $fileName; "^
        "                    $outputPath = Join-Path $localPath $fileName; "^
        "                    try { "^
        "                        Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath -Headers @{'User-Agent'='PowerShell'}; "^
        "                        $downloadCount++; "^
        "                    } catch { } "^
        "                } "^
        "            } "^
        "            if ($downloadCount -gt 0) { "^
        "                Write-Host \"AppID $appId 成功下载 $downloadCount 个文件\"; "^
        "            } else { "^
        "                Write-Host \"AppID $appId 下载失败\"; "^
        "            } "^
        "        } else { "^
        "            Write-Host \"AppID $appId 下载失败\"; "^
        "        } "^
        "    } else { "^
        "        Write-Host \"AppID $appId 下载失败 或 GitHub API 速率限制\"; "^
        "    } "^
        "} catch { "^
        "    Write-Host \"AppID $appId 下载失败: $_\"; "^
        "}"
        
        if exist "%~dp0utils\ManifestHub\temp_branch_%%j.json" (
            del "%~dp0utils\ManifestHub\temp_branch_%%j.json"
        )
	
        if exist "%~dp0utils\ManifestHub\%%j\*.manifest" (
            echo 正在复制 manifest 文件到 depotcache...
            copy "%~dp0utils\ManifestHub\%%j\*.manifest" "%~dp0..\depotcache"
        )
        
        if exist "%~dp0utils\ManifestHub\%%j\key.vdf" (
            echo 正在合并密钥信息到 config.vdf...
            powershell -Command ^
            "$keyFile = '%~dp0utils\ManifestHub\%%j\key.vdf'; "^
            "$configFile = '%~dp0..\config\config.vdf'; "^
            "if ((Test-Path $keyFile) -and (Test-Path $configFile)) { "^
            "    $keyLines = Get-Content $keyFile; "^
            "    $configContent = Get-Content $configFile -Raw; "^
            "    $depotId = ''; "^
            "    foreach ($line in $keyLines) { "^
            "        if ($line -match '^\s*""(\d+)""') { "^
            "            $depotId = $matches[1]; "^
            "        } "^
            "        if ($line -match 'DecryptionKey.*?""([a-f0-9]+)""' -and $depotId) { "^
            "            $decryptionKey = $matches[1]; "^
            "            Write-Host ('正在添加depot ' + $depotId + ' 密钥: ' + $decryptionKey); "^
            "            $newEntry = '\"' + $depotId + '\"{\"DecryptionKey\"\"' + $decryptionKey + '\"}'; "^
            "            $configContent = $configContent -replace '(\"depots\"\s*\{)', (\"`$1\" + $newEntry); "^
            "            $depotId = ''; "^
            "        } "^
            "    } "^
            "    Set-Content -Path $configFile -Value $configContent -Encoding UTF8; "^
            "}"
        )

        echo.
        echo ================================
    )
    echo.
)
pause