@echo off
setlocal
title Blog Admin Tool
cd /d "%~dp0"

where node.exe >nul 2>nul
if errorlevel 1 goto no_node

if not exist "node_modules\express\package.json" goto install
goto launch

:install
echo Installing required packages...
call npm.cmd install
if errorlevel 1 goto install_failed

:launch
echo.
echo ========================================
echo   Blog Admin Tool is starting...
echo   The browser will open automatically.
echo   Close this window to stop the server.
echo ========================================
echo.
start "" powershell.exe -NoProfile -WindowStyle Hidden -Command "Start-Sleep -Seconds 2; Start-Process 'http://127.0.0.1:4173/admin/'"
call npm.cmd run admin
echo.
echo The server has stopped.
pause
exit /b 0

:no_node
echo.
echo ERROR: Node.js was not found.
echo Install Node.js and then run this file again.
echo.
pause
exit /b 1

:install_failed
echo.
echo ERROR: Package installation failed.
echo Check the network connection and try again.
echo.
pause
exit /b 1
