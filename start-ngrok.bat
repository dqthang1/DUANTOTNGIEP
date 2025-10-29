@echo off
echo ========================================
echo    ACTIVEWEAR STORE - NGROK SETUP
echo ========================================
echo.

echo [1/6] Starting Spring Boot application...
start "Spring Boot App" cmd /k "mvn spring-boot:run"

echo [2/6] Waiting for Spring Boot to start (30 seconds)...
timeout /t 30 /nobreak > nul

echo [3/6] Starting Ngrok tunnel...
start "Ngrok Tunnel" cmd /k "ngrok.exe http 8080"

echo [4/6] Waiting for ngrok to start (15 seconds)...
timeout /t 15 /nobreak > nul

echo [5/6] Getting ngrok URL...
call get-ngrok-url.bat

echo [6/6] Opening test pages...
start "Test Page" test-auth.html
start "Email Validation Test" test-email-validation.html

echo.
echo ========================================
echo    SETUP COMPLETE!
echo ========================================
echo.
echo Your Activewear Store is now accessible via ngrok!
echo.
echo To get your ngrok URL anytime, run: get-ngrok-url.bat
echo To update URL manually, run: update-ngrok-url.bat
echo.
echo Press any key to open the application...
pause >nul

echo Opening application in browser...
start "Activewear Store" http://localhost:8080

echo.
echo ========================================
echo    USEFUL COMMANDS
echo ========================================
echo.
echo - Get ngrok URL: get-ngrok-url.bat
echo - Update URL: update-ngrok-url.bat
echo - Stop all: taskkill /f /im java.exe ^&^& taskkill /f /im ngrok.exe
echo.
echo Press any key to exit...
pause >nul
