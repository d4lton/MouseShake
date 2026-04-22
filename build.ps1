$repoPath = $PSScriptRoot
$addonName = Split-Path -Leaf $repoPath
 
# Get list of tracked files from git, excluding .ps1 and .gitignore
$files = git -C $repoPath ls-files |
    Where-Object { $_ -notmatch '\.ps1$' -and $_ -ne '.gitignore' }
 
$zipPath = Join-Path $repoPath "$addonName.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
 
# Build zip with files nested inside an addon-named folder
$files | ForEach-Object {
    $src = Join-Path $repoPath $_
    $entry = Join-Path $addonName $_
    Compress-Archive -Path $src -DestinationPath $zipPath -Update
}
 
# Compress-Archive doesn't support custom entry paths easily, so use .NET directly
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
 
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create')
 
foreach ($file in $files) {
    $src = Join-Path $repoPath $file
    $entry = Join-Path $addonName $file
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $src, $entry) | Out-Null
}
 
$zip.Dispose()
 
Write-Host "Created $zipPath ($($files.Count) files)"
