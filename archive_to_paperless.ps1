# PowerShell-Skript zum Archivieren von Dateien und Kopieren in einen NAS-Drop-Ordner
# /Users/pmario/Local/tools/archive_to_paperless.ps1

if ($args.Length -le 0) {
    Write-Error "No file path(s) provided."
    return    
}

$archivePath = '/Users/pmario/Local/archived'
$NASDropPath = '/Volumes/Dropfolder/paperless'

foreach ($filename in $args) {
    if (-not (Test-Path -Path $filename)) {
        Write-Error "File not found: $File"
        continue
    }

    $nasDest = [System.IO.Path]::Combine($NASDropPath, $filename)
    $archiveDest = [System.IO.Path]::Combine($archivePath, $filename)

    # Copy to NAS drop
    Copy-Item -Path $File -Destination $nasDest -Force
    
    # Move original to archive
    Move-Item -Path $File -Destination $archiveDest -Force
}