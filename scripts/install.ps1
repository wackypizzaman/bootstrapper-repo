function hasCommand($name) {
    return $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}

if (-not (hasCommand git)) {
    Write-Host "git not found -- installing git"

    if (hasCommand winget) {
        winget install --id Git.Git -e --silent
    }
    else {
        Write-Host "No package installer found"
        exit 1
    }

}

Write-Host "Installing aftman"

$tmp = Join-Path $env:TEMP ("aftman_install_{0}" -f ([guid]::NewGuid().ToString()))
New-Item -ItemType Directory -Path $tmp | Out-Null

try {
    $api = 'https://api.github.com/repos/LPGhatguy/aftman/releases/latest'
    $response = Invoke-RestMethod -Uri $api -UseBasicParsing -ErrorAction Stop
    
    $asset = $response.assets | Where-Object { 
        $_.name -match '(?i)aftman' -and $_.name -match '(?i)windows|x64|\.exe' 
    } | Select-Object -First 1

    if (-not $asset) {
        Write-Host "No Windows-specific asset found, trying any aftman asset..."
        $asset = $response.assets | Where-Object { $_.name -match '(?i)aftman' } | Select-Object -First 1
    }

    if (-not $asset) {
        Write-Host "No asset found"
        exit 1
    }

    $url = $asset.browser_download_url
    $fname = Join-Path $tmp ([System.IO.Path]::GetFileName($url))

    Write-Host "Downloading $($asset.name)"

    Invoke-WebRequest -Uri $url -OutFile $fname -UseBasicParsing -ErrorAction Stop

    switch -Wildcard ($fname) {
        '*.zip' {
            Write-Host "Extracting zip archive..."
            Expand-Archive -Path $fname -DestinationPath $tmp -Force
            break
        }
        '*.tar.gz' {
            if (hasCommand 'tar') {
                Write-Host "Extracting tar.gz archive with tar..."
                & tar -xzf $fname -C $tmp
            }
            break
        }
        '*.exe' {
            Write-Host "Executable downloaded, no extraction needed"
            $exePath = $fname
            break
        }
        default {
            Write-Host "Unknown file type: $fname"

            if ($fname -match '\.(zip|tar\.gz)$') {
                Write-Host "Attempting to extract..."
                try {
                    Expand-Archive -Path $fname -DestinationPath $tmp -Force
                } catch {
                    Write-Host "Extraction failed: $($_.Exception.Message)"
                }
            } else {
                $exePath = $fname
            }
        }
    }

    if (-not $exePath) {
        $candidate = Get-ChildItem -Path $tmp -File -Force | Where-Object { 
            $_.Name -match '(?i)^aftman' -and $_.Extension -in @('.exe', '') 
        } | Select-Object -First 1
        
        if (-not $candidate) {
            $candidate = Get-ChildItem -Path $tmp -File -Recurse -Force | Where-Object { 
                $_.Name -match '(?i)aftman' -and $_.Extension -in @('.exe', '') 
            } | Select-Object -First 1
        }

        if ($candidate) {
            $exePath = $candidate.FullName
        } else {
            Write-Host "No aftman.exe found, re install"
            exit 1
        }
    }

    & $exePath 'self-install'

} catch {
    Write-Host "Error during installation: $($_.Exception.Message)"
    exit 1
} finally {
    try {
        Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Cleaned up temporary files."
    } catch {
        Write-Host "Warning: failed to remove temp folder $tmp."
    }
}

if (hasCommand aftman) {
    Write-Host "Aftman installed successfully!"
    $aftmanPath = (Get-Command aftman).Source
    Write-Host "Aftman installed at Path: $aftmanPath"

    aftman add rojo-rbx/rojo@7.2.1

} else {
    Write-Host "aftman not install 💀"
}

Write-Host "Finished"
