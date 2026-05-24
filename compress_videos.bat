@echo off
chcp 65001 >nul
title 博客视频批量压缩工具
echo ============================================
echo   博客视频批量压缩工具
echo   使用 FFmpeg 智能压缩
echo ============================================
echo.

:: 检查 FFmpeg 是否安装
where ffmpeg >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未找到 FFmpeg！
    echo.
    echo 请先安装 FFmpeg：
    echo   方式1：winget install ffmpeg
    echo   方式2：从 https://ffmpeg.org/download.html 下载
    echo.
    pause
    exit /b 1
)

echo [信息] FFmpeg 已就绪
echo.

:: 创建输出目录（在原目录下创建 _compressed 子目录）
set OUTPUT_BASE=%~dp0_compressed
if not exist "%OUTPUT_BASE%" mkdir "%OUTPUT_BASE%"
echo [信息] 输出目录：%OUTPUT_BASE%
echo.

:: ============================================
:: 1. 主页背景视频 - 最小体积，720p 足够
:: ============================================
echo [1/6] 压缩主页背景视频...
set SRC=主页图片\bg.mp4
set OUT=%OUTPUT_BASE%\主页图片
if not exist "%OUT%" mkdir "%OUT%"
if exist "%SRC%" (
    ffmpeg -i "%SRC%" -c:v libx264 -crf 30 -preset slow -vf "scale=-1:720" -c:a aac -b:a 32k -movflags +faststart -y "%OUT%\bg.mp4"
    echo   ✓ bg.mp4 压缩完成
) else (
    echo   - bg.mp4 不存在，跳过
)

:: ============================================
:: 2. LIVE2D 展示视频 - 适中质量
:: ============================================
echo.
echo [2/6] 压缩 LIVE2D 展示视频...
set SRC_DIR=LIVE2D图片
set OUT_DIR=%OUTPUT_BASE%\%SRC_DIR%
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

if exist "%SRC_DIR%\LIVE2D1.mp4" (
    ffmpeg -i "%SRC_DIR%\LIVE2D1.mp4" -c:v libx264 -crf 28 -preset slow -c:a aac -b:a 64k -movflags +faststart -y "%OUT_DIR%\LIVE2D1.mp4"
    echo   ✓ LIVE2D1.mp4 压缩完成
)
if exist "%SRC_DIR%\LIVE2D2.mp4" (
    ffmpeg -i "%SRC_DIR%\LIVE2D2.mp4" -c:v libx264 -crf 28 -preset slow -c:a aac -b:a 64k -movflags +faststart -y "%OUT_DIR%\LIVE2D2.mp4"
    echo   ✓ LIVE2D2.mp4 压缩完成
)
if exist "%SRC_DIR%\LIVE2D3.mp4" (
    ffmpeg -i "%SRC_DIR%\LIVE2D3.mp4" -c:v libx264 -crf 28 -preset slow -c:a aac -b:a 64k -movflags +faststart -y "%OUT_DIR%\LIVE2D3.mp4"
    echo   ✓ LIVE2D3.mp4 压缩完成
)

:: ============================================
:: 3. 游戏展示视频 - 较好质量
:: ============================================
echo.
echo [3/6] 压缩游戏展示视频...
set SRC_DIR=制作游戏图片
set OUT_DIR=%OUTPUT_BASE%\%SRC_DIR%
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

for %%f in ("%SRC_DIR%\*.mp4") do (
    if exist "%%f" (
        ffmpeg -i "%%f" -c:v libx264 -crf 25 -preset slow -c:a aac -b:a 64k -movflags +faststart -y "%OUT_DIR%\%%~nxf"
        echo   ✓ %%~nxf 压缩完成
    )
)

:: ============================================
:: 4. 音乐视频 - 较好质量
:: ============================================
echo.
echo [4/6] 压缩音乐视频...
set SRC_DIR=音乐图片
set OUT_DIR=%OUTPUT_BASE%\%SRC_DIR%
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

for %%f in ("%SRC_DIR%\*.mp4") do (
    if exist "%%f" (
        ffmpeg -i "%%f" -c:v libx264 -crf 25 -preset slow -c:a aac -b:a 64k -movflags +faststart -y "%OUT_DIR%\%%~nxf"
        echo   ✓ %%~nxf 压缩完成
    )
)

:: ============================================
:: 5. 项目演示视频 - 较好质量
:: ============================================
echo.
echo [5/6] 压缩项目演示视频...
set SRC_DIR=项目图片
set OUT_DIR=%OUTPUT_BASE%\%SRC_DIR%
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

for %%f in ("%SRC_DIR%\*.mp4") do (
    if exist "%%f" (
        ffmpeg -i "%%f" -c:v libx264 -crf 25 -preset slow -c:a aac -b:a 64k -movflags +faststart -y "%OUT_DIR%\%%~nxf"
        echo   ✓ %%~nxf 压缩完成
    )
)

:: ============================================
:: 6. 统计结果
:: ============================================
echo.
echo ============================================
echo  压缩完成！结果统计：
echo ============================================
echo.

:: 统计原始大小
set ORIG_SIZE=0
for /r %%f in (*.mp4) do set /a ORIG_SIZE+=%%~zf

:: 统计压缩后大小
set COMP_SIZE=0
for /r "%OUTPUT_BASE%" %%f in (*.mp4) do set /a COMP_SIZE+=%%~zf

echo  原始总大小：未统计（因含中文路径）
echo  压缩后目录：%OUTPUT_BASE%
echo.
echo  各文件详情：
echo  ----------------------------------------
for /r "%OUTPUT_BASE%" %%f in (*.mp4) do (
    for %%s in (%%f) do (
        set SIZE_MB=%%~zs
        set /a SIZE_MB_CALC=%%~zs/1024/1024
    )
    echo  %%~nxf
)

echo.
echo  ----------------------------------------
echo.
echo [提示] 压缩后的文件在 _compressed 目录下
echo 确认效果满意后，手动覆盖原文件即可
echo.
echo 查看单个文件大小：右键 → 属性
echo.
pause
