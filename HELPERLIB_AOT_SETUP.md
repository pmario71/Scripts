# HelperLib AOT with PowerShell Integration

## Overview
HelperLib has been configured for Ahead-of-Time (AOT) compilation and integrated with PowerShell through a CLI wrapper.

## What Was Built

### 1. **HelperLib.dll** (Core Library)
- Configured with `PublishAot=true` for AOT compilation
- Enabled full trimming with `TrimMode=full`
- Location: `projects/HelperLib/bin/Release/net10.0/HelperLib.dll`
- Contains: `XmpHelper` class for XMP metadata validation

### 2. **HelperLibCli** (Command-Line Tool)
- AOT-compiled console application wrapping HelperLib
- Outputs simple pipe-delimited format (no JSON serialization issues)
- Location: `projects/HelperLibCli/bin/Release/publish/HelperLibCli`
- Size: ~6.8MB (self-contained native binary with no runtime dependencies)

### 3. **Use-HelperLib.ps1** (PowerShell Script)
- Wrapper script that calls the AOT-compiled CLI tool
- Parses CLI output and formats results with color-coded output
- Handles path resolution automatically
- Location: `Use-HelperLib.ps1`

## Usage

### Run from PowerShell
```powershell
./Use-HelperLib.ps1 -PhotoPath "/path/to/photos"
```

### Run CLI directly
```bash
./projects/HelperLibCli/bin/Release/publish/HelperLibCli validate-year /path/to/photos
```

### Output Format
```
VALIDATION_RESULT|<valid_count>|<error_count>
ERROR|<ErrorType>|<message>
ERROR|<ErrorType>|<message>
...
```

## Build Commands

### Rebuild HelperLib
```bash
cd projects
dotnet build -c Release HelperLib/HelperLib.csproj
```

### Rebuild CLI Tool
```bash
cd projects
dotnet publish -c Release HelperLibCli/HelperLibCli.csproj -o ./HelperLibCli/bin/Release/publish
```

## File Structure
```
Use-HelperLib.ps1                           # PowerShell wrapper script
Test-HelperLib.ps1                          # Diagnostic test script
projects/
  HelperLib/
    HelperLib.csproj                        # Core library project
    XmpHelper.cs                            # XMP validation logic
    bin/Release/net10.0/
      HelperLib.dll                         # Compiled library
  HelperLibCli/
    HelperLibCli.csproj                     # CLI wrapper project
    Program.cs                              # CLI entry point
    bin/Release/publish/
      HelperLibCli                          # Self-contained AOT binary
      HelperLibCli.dSYM/                    # Debug symbols
```

## Key Features

✅ **AOT Compiled**: Native binary with zero runtime overhead
✅ **Self-Contained**: No .NET runtime dependency required
✅ **PowerShell Integration**: Easy to use from PowerShell scripts
✅ **Error Handling**: Comprehensive validation and error reporting
✅ **Cross-Platform**: Built for macOS (ARM64)

## Example: Creating Directories with Correct Year Structure

The validation ensures XMP metadata timestamps match directory structure:
```
Photos/
  2023/
    Photo1.jpg
    Photo1.jpg.xmp    ← DateTimeOriginal must be 2023
  2024/
    Photo2.jpg
    Photo2.jpg.xmp    ← DateTimeOriginal must be 2024
```

The `XmpHelper.ExtractYearFromPath()` method extracts the year from any 4-digit directory name in the path hierarchy.
