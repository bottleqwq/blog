@echo off
setlocal
chcp 65001 >nul
title 博客可视化管理工具
cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
    echo.
    echo [错误] 没有找到 Node.js。
    echo 请先安装 Node.js，然后重新双击此文件。
    echo.
    pause
    exit /b 1
)

if not exist "node_modules\express\package.json" (
    echo 正在安装首次运行所需组件，请稍候...
    call npm install
    if errorlevel 1 (
        echo.
        echo [错误] 组件安装失败，请检查网络后重试。
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo   博客管理工具正在启动
echo   浏览器稍后会自动打开
echo   关闭此窗口即可停止管理工具
echo ========================================
echo.

start "" powershell.exe -NoProfile -WindowStyle Hidden -Command "Start-Sleep -Seconds 2; Start-Process 'http://127.0.0.1:4173/admin/'"
call npm run admin

echo.
echo 管理工具已经停止。
pause
endlocal
