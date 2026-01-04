#Requires -Version 7.0
<#
.SYNOPSIS
    PowerShell script demonstrating usage of the AOT-compiled HelperLib CLI tool.

.DESCRIPTION
    This script calls the HelperLibCli executable to validate XMP metadata in photo 
    files against their directory structure.

.PARAMETER PhotoPath
    The root directory path containing photo folders with XMP files to validate.

.EXAMPLE
    .\Use-HelperLib.ps1 -PhotoPath "/Users/pmario/Projects/Scripts/TestData/Photo"
#>

param(
    [Parameter(Mandatory=$true, HelpMessage="Path to the photo directory")]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$PhotoPath
)

# Configuration - Determine script directory
$scriptDirectory = if ($PSScriptRoot) {
    $PSScriptRoot
} else {
    Split-Path -Parent $MyInvocation.MyCommand.Path
}

$helperLibCliPath = Join-Path $scriptDirectory "projects/HelperLibCli/bin/Release/publish/HelperLibCli"

# If not found, try absolute path
if (-not (Test-Path $helperLibCliPath)) {
    $helperLibCliPath = "/Users/pmario/Projects/Scripts/projects/HelperLibCli/bin/Release/publish/HelperLibCli"
}

# Verify the executable exists
if (-not (Test-Path $helperLibCliPath)) {
    Write-Error "HelperLibCli executable not found at: $helperLibCliPath"
    Write-Host "Please build it first using: dotnet publish -c Release projects/HelperLibCli/HelperLibCli.csproj"
    Write-Host "Script directory: $scriptDirectory"
    exit 1
}

Write-Host "Validating XMP metadata in: $PhotoPath" -ForegroundColor Cyan
Write-Host "---" -ForegroundColor Cyan

try {
    # Call the CLI tool and capture output
    $output = & $helperLibCliPath validate-year $PhotoPath
    $lines = $output -split "`n" | Where-Object { $_ }
    
    # Parse the result line
    $resultLine = $lines[0]
    if ($resultLine -match "^VALIDATION_RESULT\|(\d+)\|(\d+)$") {
        $validCount = [int]$matches[1]
        $errorCount = [int]$matches[2]
        
        # Display errors if any
        if ($errorCount -gt 0) {
            Write-Host ""
            for ($i = 1; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match "^ERROR\|(.+)\|(.+)$") {
                    $errorType = $matches[1]
                    $message = $matches[2]
                    
                    $color = $errorType -eq "ValidationError" ? "Red" : "Yellow"
                    $icon = $errorType -eq "ValidationError" ? "❌" : "⚠️"
                    Write-Host "$icon $($errorType): $message" -ForegroundColor $color
                }
            }
        }
        
        # Summary
        Write-Host ""
        Write-Host "Validation Summary:" -ForegroundColor Green
        Write-Host "  Valid files:   $validCount"
        Write-Host "  Errors found:  $errorCount"
        
        exit ($errorCount -eq 0 ? 0 : 1)
    } else {
        Write-Error "Unexpected output format from CLI"
        exit 1
    }
} catch {
    Write-Error "Error running validation: $_"
    exit 1
}
