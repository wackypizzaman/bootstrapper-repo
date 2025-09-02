function hasCommand($name) {
    return $null -ne (Get-Command $name)
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

Write-Host "Installing rokit"
Invoke-RestMethod https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.ps1 | Invoke-Expression

Write-Host "Installing all tools"
rokit install

Write-Host "Finished"
