@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo 配置 GitHub 远程仓库
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

REM 检查是否是 Git 仓库
if not exist .git (
    echo [错误] 当前目录不是 Git 仓库
    echo 请先运行: git init
    pause
    exit /b 1
)

echo 当前远程仓库配置：
echo.
git remote -v
echo.

REM 检查 origin 是否存在
git remote get-url origin >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    for /f "delims=" %%i in ('git remote get-url origin 2^>nul') do set CURRENT_URL=%%i
    if defined CURRENT_URL (
        echo 当前 origin URL: %CURRENT_URL%
    ) else (
        echo 当前 origin URL: (未设置或无效)
        set CURRENT_URL=
    )
    echo.
    echo 选择操作：
    echo   [1] 修改现有 URL
    echo   [2] 删除并重新添加
    echo   [3] 退出
    echo.
    set /p ACTION="请选择 (1/2/3): "
    
    if "!ACTION!"=="1" (
        goto update_url
    )
    if "!ACTION!"=="2" (
        echo.
        echo 正在删除现有的 origin...
        git remote remove origin
        echo 已删除
        echo.
        goto add_remote
    )
    if "!ACTION!"=="3" (
        echo 已取消
        pause
        exit /b 0
    )
    if "!ACTION!"=="" (
        echo 已取消
        pause
        exit /b 0
    )
    echo 无效的选择，已取消
    pause
    exit /b 0
) else (
    echo origin 未配置
    echo.
    goto add_remote
)

:update_url
echo.
echo 请输入新的 GitHub 仓库 URL
echo 格式: https://github.com/用户名/仓库名.git
echo.
set /p NEW_URL="新的仓库 URL: "
if "!NEW_URL!"=="" (
    echo [错误] URL 不能为空！
    pause
    exit /b 1
)
echo.
echo 正在更新远程仓库 URL...
git remote set-url origin "!NEW_URL!"
if !ERRORLEVEL! EQU 0 (
    echo.
    echo [成功] 远程仓库 URL 已更新！
    echo 新 URL: !NEW_URL!
) else (
    echo.
    echo [错误] 更新失败！请检查 URL 格式
    pause
    exit /b 1
)
goto verify

:add_remote
echo 请输入 GitHub 仓库 URL
echo 格式: https://github.com/用户名/仓库名.git
echo 例如: https://github.com/username/SphericalHarmonics.git
echo.
:get_url
set /p REPO_URL="仓库 URL: "
if "!REPO_URL!"=="" (
    echo [错误] URL 不能为空！
    goto get_url
)

echo.
echo 正在添加远程仓库...
git remote add origin "!REPO_URL!" 2>nul
if !ERRORLEVEL! EQU 0 (
    echo [成功] 远程仓库已添加！
) else (
    echo [信息] origin 已存在，尝试更新 URL...
    git remote set-url origin "!REPO_URL!"
    if !ERRORLEVEL! EQU 0 (
        echo [成功] 远程仓库 URL 已更新！
    ) else (
        echo [错误] 更新失败！请检查 URL 格式
        pause
        exit /b 1
    )
)

:verify
echo.
echo ========================================
echo 验证配置
echo ========================================
git remote -v
echo.

REM 测试连接（可选）
set /p TEST_CONNECTION="是否测试连接？(Y/N，默认N): "
if /i "!TEST_CONNECTION!"=="Y" (
    echo.
    echo 正在测试连接...
    git ls-remote origin >nul 2>nul
    if !ERRORLEVEL! EQU 0 (
        echo [成功] 可以连接到远程仓库！
    ) else (
        echo [警告] 无法连接到远程仓库
        echo 这可能是因为：
        echo   1. 仓库不存在或 URL 错误
        echo   2. 需要身份验证
        echo   3. 网络问题
        echo.
        echo 可以稍后使用 git push 命令时进行身份验证
    )
)

echo.
echo ========================================
echo 配置完成！
echo ========================================
echo 现在可以运行 deploy_to_github.bat 或使用以下命令推送：
echo   git push -u origin main
echo.
pause

