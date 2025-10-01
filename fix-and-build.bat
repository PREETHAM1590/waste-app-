@echo off
echo ========================================
echo Flutter Build Fix and Run Script
echo ========================================
echo.

REM Run the PowerShell script to fix build issues
echo Fixing build issues...
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\fix-build-issues.ps1"

echo.
echo Running Flutter clean...
call flutter clean

echo.
echo Getting dependencies...
call flutter pub get

echo.
echo Building and running the app...
call flutter run

echo.
echo ========================================
echo Build script completed!
echo ========================================
pause
