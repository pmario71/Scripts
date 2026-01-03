$ErrorActionPreference = "Stop"

<# 
.SYNOPSIS
    Finds duplicate files in a specified source path compared to a list of files.
.DESCRIPTION
    This script identifies duplicate files in a given source path by comparing file names and sizes. It generates a hash based on the file name and size to detect duplicates efficiently.
#>
function Find-Dupes {
    [CmdletBinding()]
    param (
        [System.IO.FileInfo[]]$files,
        
        # Path to search for duplicates
        [string]$sourcePath
    )
    
    begin {
        $sourcePath = [System.IO.Path]::GetFullPath($sourcePath).TrimEnd('\','/')

        $potentialDupes = $files | Where-Object { $_.DirectoryName -match $sourcePath }
        
        $hashTable = @{}
        foreach ($file in $potentialDupes) {
            # Calculate hash over file name and size
            [int]$hash = createhash -file $file
            if ($hashTable.ContainsKey($hash)) {
                $hashTable[$hash] += $file
            } else {
                $hashTable[$hash] = @($file)
            }
        }
    }
    
    process {
        $referenceFiles = $files | Where-Object { $_.DirectoryName -ne $sourcePath }

        foreach ($refFile in $referenceFiles) {
            $refHash = createhash -file $refFile
            if ($hashTable.ContainsKey($refHash)) {
                $dupes = $hashTable[$refHash]
                foreach ($dupe in $dupes) {
                    [bool]$dateDiff = ($refFile.CreationTime - $dupe.CreationTime) -lt [Timespan]::FromSeconds(1)

                    if ($dupe.FullName -ne $refFile.FullName) {
                        Write-Output @{
                            ReferenceFile = $refFile.FullName
                            DuplicateFile = $dupe.FullName
                            SameTimeStamp = $dateDiff
                        }
                    }
                }
            }
        }
    }
    
    end {
    }
}

function createhash {
    param (
        [System.IO.FileInfo]$file
    )
    $hash = ("$($file.Name)$($file.Length)").GetHashCode()
    if ($null -eq $hash) {
        $Host.UI.WriteErrorLine("Failed to create hash for file: $($file.FullName)")
    }

    return $hash
}

<#
.SYNOPSIS
    Groups files by size to identify duplicates.
.DESCRIPTION
    This function groups a list of files by their size and returns groups that contain more than one file, indicating potential duplicates.
#>
function Group-Duplicates {
    [CmdletBinding()]
    param (
        [System.IO.FileInfo[]] $f
    )
    $grps = $f
        | Group-Object -Property Length 
        | Where-Object { $_.Count -gt 1 }
        | ForEach-Object{ $_.Group | Select-Object Name, DirectoryName }

    $grps
}
# /Volumes/Gitarre/AmplitubePresets /Volumes/Gitarre/AXE-IO-User-Manual.pdf /Volumes/Gitarre/Backingtracks /Volumes/Gitarre/Guitar-Pro-8-user-guide.pdf /Volumes/Gitarre/Lessons /Volumes/Gitarre/Neu /Volumes/Gitarre/Tabs