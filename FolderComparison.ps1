$ErrorActionPreference = 'Stop'

<#
.SYNOPSIS
    Compares files in two folders and reports differences in file presence and last write timestamps.
.DESCRIPTION
    This script compares files in a source folder and a target folder. It identifies files that are
    only present in one of the folders and files that exist in both folders but have differing last
    write timestamps beyond a specified tolerance.
#>
function Compare-Folder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$Source,
        [Parameter(Mandatory=$true)][string]$Target,
        [bool]$Recurse = $true,
        [int]$TimeToleranceSeconds = 2
    )

    if (-not (Test-Path -Path $Source -PathType Container)) { throw "Source path '$Source' not found." }
    if (-not (Test-Path -Path $Target -PathType Container)) { throw "Target path '$Target' not found." }

    function Get-Relative {
        param($Root, $Path)
        try {
            $rootFull = (Resolve-Path -Path $Root).ProviderPath
            $pathFull = (Resolve-Path -Path $Path).ProviderPath
            return [IO.Path]::GetRelativePath($rootFull, $pathFull) -replace '\\','/'
        } catch {
            $rootFull = (Resolve-Path -Path $Root).ProviderPath.TrimEnd('/','\')
            $pathFull = (Resolve-Path -Path $Path).ProviderPath
            return $pathFull.Substring($rootFull.Length).TrimStart('/','\') -replace '\\','/'
        }
    }

    $srcFiles = if ($Recurse) { Get-ChildItem -Path $Source -File -Recurse -Force -ErrorAction SilentlyContinue } else { Get-ChildItem -Path $Source -File -Force -ErrorAction SilentlyContinue }
    $tgtFiles = if ($Recurse) { Get-ChildItem -Path $Target -File -Recurse -Force -ErrorAction SilentlyContinue } else { Get-ChildItem -Path $Target -File -Force -ErrorAction SilentlyContinue }

    $srcMap = @{}
    foreach ($f in $srcFiles) {
        $rel = Get-Relative -Root $Source -Path $f.FullName
        $srcMap[$rel] = $f
    }

    $tgtMap = @{}
    foreach ($f in $tgtFiles) {
        $rel = Get-Relative -Root $Target -Path $f.FullName
        $tgtMap[$rel] = $f
    }

    $allKeys = ($srcMap.Keys + $tgtMap.Keys) | Sort-Object -Unique

    foreach ($key in $allKeys) {
        $hasSrc = $srcMap.ContainsKey($key)
        $hasTgt = $tgtMap.ContainsKey($key)
        $srcTime = if ($hasSrc) { $srcMap[$key].LastWriteTimeUtc } else { $null }
        $tgtTime = if ($hasTgt) { $tgtMap[$key].LastWriteTimeUtc } else { $null }

        if (-not $hasTgt) {
            [PSCustomObject]@{
                RelativePath = $key
                SourcePath = $srcMap[$key].FullName
                TargetPath = $null
                SourceLastWriteTimeUtc = $srcTime
                TargetLastWriteTimeUtc = $null
                Status = 'OnlyInSource'
            }
        } elseif (-not $hasSrc) {
            [PSCustomObject]@{
                RelativePath = $key
                SourcePath = $null
                TargetPath = $tgtMap[$key].FullName
                SourceLastWriteTimeUtc = $null
                TargetLastWriteTimeUtc = $tgtTime
                Status = 'OnlyInTarget'
            }
        } else {
            $diffSec = [math]::Abs(($srcTime - $tgtTime).TotalSeconds)
            if ($diffSec -gt $TimeToleranceSeconds) {
                [PSCustomObject]@{
                    RelativePath = $key
                    SourcePath = $srcMap[$key].FullName
                    TargetPath = $tgtMap[$key].FullName
                    SourceLastWriteTimeUtc = $srcTime
                    TargetLastWriteTimeUtc = $tgtTime
                    Status = 'TimestampDiff'
                    DifferenceSeconds = [math]::Round($diffSec,3)
                }
            }
        }
    }
}