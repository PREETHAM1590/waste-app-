# Fix Flutter Build Issues Script
# This script resolves common build issues related to OneDrive sync and file permissions

Write-Host "Fixing Flutter build issues..." -ForegroundColor Green

# 1. Stop interfering processes (optional - uncomment if needed)
# Write-Host "Stopping interfering processes..." -ForegroundColor Yellow
# Get-Process | Where-Object { $_.ProcessName -match 'OneDrive' } | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Clear read-only attributes from build directory
$buildPath = Join-Path $PSScriptRoot "..\build"
if (Test-Path $buildPath) {
    Write-Host "Clearing read-only attributes from build directory..." -ForegroundColor Yellow
    
    # Using PowerShell method
    Get-ChildItem -Path $buildPath -Recurse -Force -ErrorAction SilentlyContinue | 
        Where-Object { $_.Attributes -band [System.IO.FileAttributes]::ReadOnly } | 
        ForEach-Object { 
            try {
                $_.Attributes = $_.Attributes -band (-bnot [System.IO.FileAttributes]::ReadOnly)
                Write-Host "  Fixed: $($_.Name)" -ForegroundColor DarkGray
            } catch {
                Write-Host "  Could not fix: $($_.Name) - $_" -ForegroundColor Red
            }
        }
    
    # Also use attrib command as fallback
    & attrib -R "$buildPath" /S /D 2>$null
}

# 3. Clear .dart_tool if it exists and has issues
$dartToolPath = Join-Path $PSScriptRoot "..\.dart_tool"
if (Test-Path $dartToolPath) {
    Write-Host "Checking .dart_tool directory..." -ForegroundColor Yellow
    Get-ChildItem -Path $dartToolPath -Recurse -Force -ErrorAction SilentlyContinue | 
        Where-Object { $_.Attributes -band [System.IO.FileAttributes]::ReadOnly } | 
        ForEach-Object { 
            $_.Attributes = $_.Attributes -band (-bnot [System.IO.FileAttributes]::ReadOnly)
        }
}

# 4. Clear ephemeral directories
$ephemeralPaths = @(
    (Join-Path $PSScriptRoot "..\windows\flutter\ephemeral"),
    (Join-Path $PSScriptRoot "..\linux\flutter\ephemeral"),
    (Join-Path $PSScriptRoot "..\macos\Flutter\ephemeral")
)

foreach ($path in $ephemeralPaths) {
    if (Test-Path $path) {
        Write-Host "Clearing ephemeral directory: $path" -ForegroundColor Yellow
        Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | 
            Where-Object { $_.Attributes -band [System.IO.FileAttributes]::ReadOnly } | 
            ForEach-Object { 
                $_.Attributes = $_.Attributes -band (-bnot [System.IO.FileAttributes]::ReadOnly)
            }
    }
}

Write-Host "Build issue fixes completed!" -ForegroundColor Green
Write-Host ""
Write-Host "You can now run 'flutter clean' and 'flutter run' successfully." -ForegroundColor Cyan
