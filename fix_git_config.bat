@echo off
chcp 65001 >nul
echo ========================================
echo Git 配置修复工具
echo ========================================
echo.

REM 检查是否安装了 Git
where git >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未检测到 Git，请先安装 Git for Windows
    echo 下载地址: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo 当前 Git 配置：
echo.
for /f "delims=" %%i in ('git config --global user.name 2^>nul') do echo   姓名: %%i
for /f "delims=" %%i in ('git config --global user.email 2^>nul') do echo   邮箱: %%i
echo.

set /p CONFIG_CHOICE="是否要重新配置？(Y/N，默认N): "
if /i not "%CONFIG_CHOICE%"=="Y" (
    echo 已取消配置
    pause
    exit /b 0
)

echo.
echo 请输入 Git 用户信息：
set /p GIT_NAME="姓名: "
set /p GIT_EMAIL="邮箱: "

if "%GIT_NAME%"=="" (
    echo [错误] 姓名不能为空！
    pause
    exit /b 1
)

if "%GIT_EMAIL%"=="" (
    echo [错误] 邮箱不能为空！
    pause
    exit /b 1
)

git config --global user.name "%GIT_NAME%"
git config --global user.email "%GIT_EMAIL%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [成功] Git 配置已更新！
    echo.
    echo 新的配置：
    git config --global user.name
    git config --global user.email
    echo.
    echo 现在可以重新运行 deploy_to_github.bat 了
) else (
    echo.
    echo [错误] 配置失败，请检查错误信息
)

echo.
pause

