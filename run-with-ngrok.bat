@echo off
echo ========================================
echo    ACTIVEWEAR STORE - WITH NGROK
echo ========================================
echo.

echo [1/5] Starting Spring Boot application...
echo Please wait for the application to start...
echo.

start "Spring Boot App" cmd /k "mvn spring-boot:run"

echo [2/5] Waiting for application to start (30 seconds)...
timeout /t 30 /nobreak > nul

echo [3/5] Starting Ngrok tunnel...
echo Exposing localhost:8080 to the internet...
echo.

start "Ngrok Tunnel" cmd /k "ngrok.exe http 8080"

echo [4/5] Waiting for ngrok to start (10 seconds)...
timeout /t 10 /nobreak > nul

echo [5/5] Opening test pages...
start "Test Page" test-auth.html
start "Email Validation Test" test-email-validation.html

echo.
echo ========================================
echo    NGROK TUNNEL INFORMATION
echo ========================================
echo.
echo 1. Check the ngrok window for your public URL
echo 2. It will look like: https://xxxxx.ngrok.io
echo 3. Share this URL with others to test your app
echo 4. The app is running on: http://localhost:8080
echo.
echo ========================================
echo    TEST INSTRUCTIONS
echo ========================================
echo.
echo 1. Use the public ngrok URL to test from anywhere
echo 2. Test accounts available:
echo    - Admin: admin@datnfpolysd45.com / password
echo    - User:  customer@example.com / password
echo.
echo 3. Test features:
echo    - Register with new email
echo    - Email validation real-time
echo    - OTP verification via email
echo    - Login/logout functionality
echo    - Admin panel access
echo.
echo 4. Share the ngrok URL with others for testing
echo.
echo ========================================
echo Press any key to stop all services...
pause > nul

echo.
echo Stopping services...
taskkill /f /im java.exe >nul 2>&1
taskkill /f /im ngrok.exe >nul 2>&1
echo All services stopped.
