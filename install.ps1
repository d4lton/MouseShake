$addonPath = $PSScriptRoot
$addonName = Split-Path -Leaf $addonPath

# Search for the retail AddOns folder
$searchPaths = @(
    "$env:ProgramFiles\World of Warcraft",
    "${env:ProgramFiles(x86)}\World of Warcraft"
)
Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -ne $null } | ForEach-Object {
    $searchPaths += Join-Path $_.Root "World of Warcraft"
    $searchPaths += Join-Path $_.Root "Games\World of Warcraft"
}

$addonsRoot = $searchPaths |
    ForEach-Object { Join-Path $_ "_retail_\Interface\AddOns" } |
    Where-Object { Test-Path $_ } |
    Select-Object -First 1

if (-not $addonsRoot) {
    Write-Error "Could not find WoW retail AddOns folder."
    exit 1
}

$dest = Join-Path $addonsRoot $addonName
if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }

$files = git -C $addonPath ls-files |
    Where-Object { $_ -notmatch '\.ps1$' -and $_ -ne '.gitignore' }

foreach ($file in $files) {
    $src = Join-Path $addonPath $file
    $target = Join-Path $dest $file
    $targetDir = Split-Path -Parent $target
    if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
    Copy-Item $src -Destination $target -Force
}

Write-Host "Installed '$addonName' to $dest ($($files.Count) files)"
