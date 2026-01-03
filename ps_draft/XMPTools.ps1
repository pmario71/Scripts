$ErrorActionPreference = "Stop"



<#
.SYNOPSIS
    Extract DateTimeOriginal XMP metadata files.
.DESCRIPTION
    This module provides functions to read and manipulate XMP metadata files commonly used in photography workflows.
#>
function Verb-Noun {
    [CmdletBinding()]
    param (
        # Path to XMP files
        [Parameter(Mandatory=$true)][string]$path,

        # Recurse into subdirectories
        [switch]$recurse
    )
    
    begin {
        $files = if ($recurse) {
            Get-ChildItem -Path $path -Filter *.xmp -Recurse -File
        } else {
            Get-ChildItem -Path $path -Filter *.xmp -File
        }
    }
    
    process {
        $orphanedXMPs = @()

        foreach ($file in $files) {
            $sourceFile = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

            if (!([System.IO.File]::Exists( $sourceFile))) {
                $orphanedXMPs += $file.FullName
            }
            else {
                $dt = Get-XMPDateTimeOriginal -XMPFilePath $file.FullName
                Write-Output "File: $($file.FullName), DateTimeOriginal: $dt"
            }

        }
    }
    
    end {
        
    }
}

function Get-XMPDateTimeOriginal {
    [CmdletBinding()]
    param (
        # Path to XMP file
        [Parameter(Mandatory=$true)][string]$XMPFilePath
    )

    begin {
        if (-not (Test-Path -Path $XMPFilePath -PathType Leaf)) {
            throw "XMP file '$XMPFilePath' not found."
        }
    }

    process {
        [xml]$xmpContent = Get-Content -Path $XMPFilePath -Raw

        $namespaceManager = New-Object System.Xml.XmlNamespaceManager($xmpContent.NameTable)
        $namespaceManager.AddNamespace("xmp", "http://ns.adobe.com/xap/1.0/")

        $dateTimeNode = $xmpContent.SelectSingleNode("//xmp:DateTimeOriginal", $namespaceManager)

        if ($null -ne $dateTimeNode) {
            return [DateTime]::Parse($dateTimeNode.InnerText)
        } else {
            throw "DateTimeOriginal not found in XMP file '$XMPFilePath'."
        }
    }

    end {
        
    }
}

$xmpPath = "TestData/Photo/XMP/DSC05043.ARW.xmp"
$dateTimeOriginal = Get-XMPDateTimeOriginal -XMPFilePath $xmpPath
Write-Output "DateTimeOriginal: $dateTimeOriginal"

