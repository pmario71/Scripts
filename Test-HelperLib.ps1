#Requires -Version 7.0
<#
.SYNOPSIS
    Diagnostic script to test HelperLib assembly loading.
#>

# Configuration - Determine script directory
$scriptDirectory = if ($PSScriptRoot) {
    $PSScriptRoot
} else {
    Split-Path -Parent $MyInvocation.MyCommand.Path
}

$helperLibPath = Join-Path $scriptDirectory "projects/HelperLib/bin/Release/net10.0/HelperLib.dll"

# If not found, try absolute path
if (-not (Test-Path $helperLibPath)) {
    $helperLibPath = "/Users/pmario/Projects/Scripts/projects/HelperLib/bin/Release/net10.0/HelperLib.dll"
}

Write-Host "=== HelperLib Diagnostic Test ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Script Directory: $scriptDirectory" -ForegroundColor Yellow
Write-Host "Expected DLL Path: $helperLibPath" -ForegroundColor Yellow
Write-Host ""

# Check if file exists
if (Test-Path $helperLibPath) {
    Write-Host "✓ DLL file found" -ForegroundColor Green
    $fileInfo = Get-Item $helperLibPath
    Write-Host "  Size: $($fileInfo.Length) bytes"
    Write-Host "  Modified: $($fileInfo.LastWriteTime)"
} else {
    Write-Host "✗ DLL file NOT found" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Attempting to load assembly..." -ForegroundColor Cyan

# Load the assembly with error handling
try {
    $assembly = [Reflection.Assembly]::LoadFrom($helperLibPath)
    Write-Host "✓ Assembly loaded successfully" -ForegroundColor Green
    Write-Host "  Full Name: $($assembly.FullName)"
    Write-Host "  Location: $($assembly.Location)"
} catch {
    Write-Host "✗ Failed to load assembly: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Available types in assembly:" -ForegroundColor Cyan
$types = $assembly.GetTypes()
foreach ($type in $types) {
    Write-Host "  - $($type.FullName)"
}

Write-Host ""
Write-Host "Attempting to access XmpHelper class..." -ForegroundColor Cyan

try {
    $xmpHelper = [HelperLib.XmpHelper]
    Write-Host "✓ Successfully accessed [HelperLib.XmpHelper]" -ForegroundColor Green
    Write-Host "  Type: $($xmpHelper.FullName)"
    
    # List available methods
    Write-Host ""
    Write-Host "Available methods:" -ForegroundColor Cyan
    $methods = $xmpHelper.GetMethods([System.Reflection.BindingFlags]::Public -bor [System.Reflection.BindingFlags]::Static)
    foreach ($method in $methods | Where-Object { $_.DeclaringType.Name -eq "XmpHelper" }) {
        Write-Host "  - $($method.Name)"
    }
} catch {
    Write-Host "✗ Failed to access type: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "This typically means the assembly loaded but PowerShell can't find the type."
    Write-Host "Trying alternative method..." -ForegroundColor Yellow
    
    # Try using Get-Type
    try {
        $type = $assembly.GetType("HelperLib.XmpHelper")
        if ($type) {
            Write-Host "✓ Found type using Assembly.GetType()" -ForegroundColor Green
            Write-Host "  Type: $($type.FullName)"
        } else {
            Write-Host "✗ Type not found in assembly" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ Error: $_" -ForegroundColor Red
    }
}
