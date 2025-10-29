@echo off
echo ========================================
echo    GET NGROK URL
echo ========================================
echo.

echo Getting ngrok URL from local API...
echo.

REM Try to get ngrok URL from local API
curl -s http://localhost:4040/api/tunnels > ngrok-info.json 2>nul

if exist ngrok-info.json (
    echo ✅ Ngrok is running!
    echo.
    
    REM Extract URL using PowerShell
    for /f "tokens=*" %%i in ('powershell -Command "(Get-Content ngrok-info.json | ConvertFrom-Json).tunnels[0].public_url"') do set NGROK_URL=%%i
    
    if not "%NGROK_URL%"=="" (
        echo 🌐 Your ngrok URL: %NGROK_URL%
        echo.
        echo 📋 Copy this URL to share with others:
        echo %NGROK_URL%
        echo.
        
        REM Ask if user wants to update application.properties
        set /p UPDATE_CONFIG="Do you want to update application.properties with this URL? (y/n): "
        
        if /i "%UPDATE_CONFIG%"=="y" (
            echo.
            echo Updating application.properties...
            
            REM Create backup
            copy "src\main\resources\application.properties" "src\main\resources\application.properties.backup" >nul
            
            REM Update app.url
            powershell -Command "(Get-Content 'src\main\resources\application.properties') -replace '^app\.url=.*', 'app.url=%NGROK_URL%' | Set-Content 'src\main\resources\application.properties'"
            
            REM Update vnpay.returnUrl
            powershell -Command "(Get-Content 'src\main\resources\application.properties') -replace '^vnpay\.returnUrl=.*', 'vnpay.returnUrl=%NGROK_URL%/payment/vnpay-return' | Set-Content 'src\main\resources\application.properties'"
            
            echo ✅ Application configuration updated!
            echo.
            echo Updated URLs:
            echo - App URL: %NGROK_URL%
            echo - VNPay Return URL: %NGROK_URL%/payment/vnpay-return
        )
    ) else (
        echo ❌ Could not extract ngrok URL from API response
    )
    
    REM Clean up
    del ngrok-info.json >nul 2>&1
) else (
    echo ❌ Ngrok is not running or not accessible
    echo.
    echo Please make sure:
    echo 1. Ngrok is running (run run-with-ngrok.bat)
    echo 2. Ngrok is accessible at http://localhost:4040
    echo.
)

echo.
pause
