@echo off
echo ========================================
echo    STOP ALL SERVICES
echo ========================================
echo.

echo Stopping Spring Boot application...
taskkill /f /im java.exe >nul 2>&1
if %errorlevel%==0 (
    echo ✅ Spring Boot stopped
) else (
    echo ⚠️ Spring Boot was not running
)

echo.
echo Stopping Ngrok tunnel...
taskkill /f /im ngrok.exe >nul 2>&1
if %errorlevel%==0 (
    echo ✅ Ngrok stopped
) else (
    echo ⚠️ Ngrok was not running
)

echo.
echo Stopping Maven processes...
taskkill /f /im mvn.cmd >nul 2>&1
taskkill /f /im mvn >nul 2>&1

echo.
echo ✅ All services stopped successfully!
echo.
pause
