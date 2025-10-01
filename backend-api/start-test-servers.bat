@echo off
echo 🚀 Starting Waste Wise Test Servers...
echo.

REM Check if Node.js is available
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js not found. Please install Node.js first.
    pause
    exit /b 1
)

echo 🔧 Starting servers...
echo.

REM Start API server in background
echo 📡 Starting API server on port 3001...
start "Waste Wise API" cmd /k "npm start"

REM Wait a moment for API to start
timeout /t 3 /nobreak >nul

REM Start webapp server
echo 🌐 Starting test webapp server on port 3002...
start "Test Webapp" cmd /k "cd test-webapp && node serve.js"

REM Wait a moment for webapp to start
timeout /t 2 /nobreak >nul

echo.
echo ✅ Both servers started!
echo.
echo 📡 API Server: http://localhost:3001
echo 🌐 Test Webapp: http://localhost:3002
echo 🎯 Advanced Tester: http://localhost:3002/advanced
echo.
echo Press any key to open the test webapp in browser...
pause >nul

REM Open the advanced tester in default browser
start http://localhost:3002/advanced

echo.
echo 💡 Tip: Keep this window open. Close it to stop the servers.
echo Press any key to continue or Ctrl+C to stop servers...
pause >nul
