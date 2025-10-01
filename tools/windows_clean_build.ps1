#!/usr/bin/env pwsh

# Windows Clean Build Script for Flutter Projects
# This script resolves common file lock issues on Windows by:
# 1. Stopping all Gradle daemons
# 2. Killing lingering Dart/Flutter processes
# 3. Running flutter clean
# 4. Force-deleting any remaining locked directories

Write-Host "🧹 Starting Windows clean build process..." -ForegroundColor Green

# Step 1: Stop Gradle daemons
Write-Host "🔴 Stopping Gradle daemons..." -ForegroundColor Yellow
try {
    if (Test-Path "android\gradlew.bat") {
        & "android\gradlew.bat" --stop
        Write-Host "✅ Gradle daemons stopped" -ForegroundColor Green
    } else {
        Write-Host "⚠️  gradlew.bat not found, skipping daemon stop" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Failed to stop Gradle daemons: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Step 2: Kill lingering Dart/Flutter processes
Write-Host "🔴 Terminating Dart/Flutter processes..." -ForegroundColor Yellow
try {
    Get-Process dart*,flutter* -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Dart/Flutter processes terminated" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Error terminating processes: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Step 3: Run flutter clean
Write-Host "🧽 Running flutter clean..." -ForegroundColor Yellow
try {
    flutter clean
    Write-Host "✅ Flutter clean completed" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter clean failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Force-delete remaining locked directories
Write-Host "🗑️  Force-deleting locked directories..." -ForegroundColor Yellow
$directoriesToDelete = @(".\build", ".\.dart_tool", ".\android\.gradle")

foreach ($dir in $directoriesToDelete) {
    if (Test-Path $dir) {
        try {
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $dir
            Write-Host "✅ Deleted $dir" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Failed to delete ${dir}: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

# Step 5: Verify problematic cloud_firestore directory is gone
$problematicPath = ".\build\cloud_firestore\intermediates\incremental"
if (-not (Test-Path $problematicPath)) {
    Write-Host "✅ Confirmed: cloud_firestore build directory removed" -ForegroundColor Green
} else {
    Write-Host "⚠️  Warning: cloud_firestore build directory still exists" -ForegroundColor Yellow
}

Write-Host "🎉 Clean build process completed!" -ForegroundColor Green
Write-Host "💡 You can now run: flutter pub get && flutter run" -ForegroundColor Cyan
