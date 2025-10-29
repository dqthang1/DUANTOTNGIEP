@echo off
echo ========================================
echo    ACTIVEWEAR STORE - AUTHENTICATION TEST
echo ========================================
echo.

echo [1/4] Starting Spring Boot application...
echo Please wait for the application to start...
echo.

start "Spring Boot App" cmd /k "mvn spring-boot:run"

echo [2/4] Waiting for application to start (30 seconds)...
timeout /t 30 /nobreak > nul

echo [3/4] Opening test pages...
start "Test Page" test-auth.html
start "Email Validation Test" test-email-validation.html

echo [4/4] Opening application in browser...
start "Activewear Store" http://localhost:8080

echo.
echo ========================================
echo    TEST INSTRUCTIONS
echo ========================================
echo.
echo 1. Wait for Spring Boot to fully start (check console for "Started DemoApplication")
echo 2. Use the test page to verify authentication features
echo 3. Test accounts available:
echo    - Admin: admin@datnfpolysd45.com / password
echo    - User:  customer@example.com / password
echo.
echo 4. Test the following features:
echo    - Login with existing accounts
echo    - Register new account
echo    - Email validation real-time
echo    - OTP verification
echo    - Access protected pages
echo    - Admin panel access
echo    - Logout functionality
echo.
echo 5. Email Validation Test:
echo    - Try existing emails: admin@datnfpolysd45.com, customer@example.com
echo    - Try new emails: newuser@example.com, test@example.com
echo.
echo ========================================
echo Press any key to exit...
pause > nul
