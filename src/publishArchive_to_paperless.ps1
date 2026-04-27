# Build archive_to_paperless for MacOS using AOT and copy to $env:tools

$projectPath = "archive_to_paperless/archive_to_paperless.csproj"
$outputDir = "publish-macos"
$toolsDir = "/Users/pmario/Local/tools"

# Publish with AOT for MacOS (x64)
dotnet publish $projectPath `
  -c Release `
  -r osx-x64 `
  -p:PublishAot=true `
  --self-contained true `
  -o $outputDir

# Copy the resulting binary to $env:tools
$binary = Join-Path $outputDir "archive_to_paperless"
Copy-Item $binary $toolsDir -Force

Write-Host "Build and copy complete. Binary is at $toolsDir/archive_to_paperless"