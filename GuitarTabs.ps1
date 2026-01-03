$ErrorActionPreference = "stop"

function Clean-FileName {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)]
        [ValidateScript({Test-Path $_ -PathType Leaf })]
        [System.IO.FileInfo]$Source
    )
    
    begin {
        
    }
    
    process {
        $name = $Source.Name
        $newName = $name -replace "-", " - "
        $newName = $newName -replace "_", " "

        if ($PSCmdlet.ShouldProcess($Source.FullName, "Rename to $newName")) {
            [System.IO.File]::Move($Source.FullName, $Source.DirectoryName + "\" + $newName)
        } else {
            Write-Host "Renaming $Source to $newName"
        }
    }
    
    end {
        
    }
}

function Copy-Tabs {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$Source,

        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$Target
    )
    
    begin {
        $files = Get-ChildItem -Path $Source -Filter *.gp*
    }
    
    process {
        foreach ($file in $files) {
            $bandName, $initial = GetBandName -title $file.BaseName

            if ($bandName -match "The") {
                [System.Diagnostics.Debugger]::Break()
            }

            $dir = [System.IO.Path]::Combine($Target, $initial, $bandName)
            [System.IO.Directory]::CreateDirectory($dir)

            if ($PSCmdlet.ShouldProcess($file.FullName, "Copy to $dir")) {
                # Copy-Item -Path $file.FullName -Destination $dir
                $targetFile = [System.IO.Path]::Combine($dir, $file.Name)

                if ([System.IO.File]::Exists($targetFile)) {
                    Write-Host "File $targetFile already exists"
                } else {
                    [System.IO.File]::Copy($file.FullName, $targetFile)
                }
            } else {
                Write-Host "Copying $file to $dir"                
            }
        }
    }

    end {
        
    }
}

function GetBandName {
    param (
        [string]$title
    )
    $name = ($title -split ' - ')[0].Trim()
    $initial = $name -replace "The ", ""
    return $name, $initial[0]
}