﻿<#
.Synopsis
   Synchronizes two volumes and ensures that all files missing from target are copied over from copy.
.DESCRIPTION
   Lange Beschreibung
.EXAMPLE
   Beispiel für die Verwendung dieses Cmdlets
.EXAMPLE
   Ein weiteres Beispiel für die Verwendung dieses Cmdlets
#>
function Sync-Volume
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # Hilfebeschreibung zu Param1
        [Parameter(Mandatory=$true)]
        [string]
        [ValidateScript( { Test-Path $_ } )]
        $TargetPath, 

        # Hilfebeschreibung zu Param2
        [Parameter(Mandatory=$true)]
        [string]
        [ValidateScript( { Test-Path $_ } )]
        $PathToCopy
    )

    Begin
    {
    }
    Process
    {
        # 
        $org = Get-ChildItem -Path $TargetPath -Recurse
        $cpy = Get-ChildItem -Path $PathToCopy -Recurse

        $res = Compare-Object -ReferenceObject $org -DifferenceObject $cpy

        $missing = ($res | where SideIndicator -EQ '=>')

        foreach($f in $missing)
        {
            $d = [System.IO.Path]::GetDirectoryName($f.Fullname)
            $d[0] = 'w'
            Copy-Item -Force -Path $f.Fullname -Destination 
        }
    }
    End
    {
    }
}