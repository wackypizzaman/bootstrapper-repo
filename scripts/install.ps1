function hasCommand($name) {
    return $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}

Write-Host "`nThis script will install all the needed tooling for development."

$prompt = "- Do you want to proceed with the installation? (y/n) "
Write-Host $prompt -NoNewline

do {
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    if ($key.Character -eq 'n' -or $key.Character -eq 'N') {
        Write-Host "n"
        Write-Host "`nInstallation cancelled."
        exit 0
    }
    elseif ($key.Character -eq 'y' -or $key.Character -eq 'Y') {
        Write-Host "y"
        break
    }
    else {
        $currentPos = $host.UI.RawUI.CursorPosition
        $host.UI.RawUI.CursorPosition = @{X = $prompt.Length; Y = $currentPos.Y}
        Write-Host " " -NoNewline
        $host.UI.RawUI.CursorPosition = @{X = $prompt.Length; Y = $currentPos.Y}
    }
} while ($true)

Write-Host "`nContinuing with installation..."

# Check for git
if (-not (hasCommand git)) {
    Write-Host "- Git not found -- installing git"
    
    if (hasCommand winget) {
        winget install --id Git.Git -e --silent
    }
    else {
        Write-Host "- No package installer found."
        exit 1
    }

    Write-Host "- Git installed successfully.`n"
} else {
    Write-Host "- Git is installed.`n"
}

$hasRokit = hasCommand rokit
$hasAftman = hasCommand aftman
$useRokit = $true

if ($hasRokit -and -not $hasAftman) {
    Write-Host "- Rokit is installed."
} elseif (-not $hasRokit -and $hasAftman) {
    Write-Host "- Aftman is installed."
    $useRokit = $false
} elseif ($hasRokit -and $hasAftman) {
    Write-Host "- Both Rokit and Aftman are installed."
} else {
    Write-Host "- Rokit and aftman not found -- installing rokit"
    Invoke-RestMethod https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.ps1 | Invoke-Expression
    Write-Host "- Rokit installed successfully."
}

if ($useRokit) {
    Write-Host "- Installing all tools with rokit."
    rokit install
} else {
    Write-Host "- Installing all tools with aftman."
    aftman install
}

Write-Host "`nInstallation complete! You can now develop with our tools."