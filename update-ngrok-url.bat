@echo off
echo ========================================
echo    UPDATE NGROK URL
echo ========================================
echo.

echo This script will help you update the application URL for ngrok
echo.

set /p NGROK_URL="Enter your ngrok URL (e.g., https://abc123.ngrok.io): "

if "%NGROK_URL%"=="" (
    echo No URL provided. Exiting...
    pause
    exit /b 1
)

echo.
echo Updating application.properties with ngrok URL: %NGROK_URL%
echo.

REM Create backup
copy "src\main\resources\application.properties" "src\main\resources\application.properties.backup" >nul

REM Update app.url
powershell -Command "(Get-Content 'src\main\resources\application.properties') -replace '^app\.url=.*', 'app.url=%NGROK_URL%' | Set-Content 'src\main\resources\application.properties'"

REM Update vnpay.returnUrl
powershell -Command "(Get-Content 'src\main\resources\application.properties') -replace '^vnpay\.returnUrl=.*', 'vnpay.returnUrl=%NGROK_URL%/payment/vnpay-return' | Set-Content 'src\main\resources\application.properties'"

echo.
echo ✅ Application URL updated successfully!
echo.
echo Updated URLs:
echo - App URL: %NGROK_URL%
echo - VNPay Return URL: %NGROK_URL%/payment/vnpay-return
echo.
echo Note: You may need to restart the Spring Boot application for changes to take effect.
echo.

pause
