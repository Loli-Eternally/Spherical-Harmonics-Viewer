@echo off
chcp 65001 >nul
echo ========================================
echo GitHub 部署脚本
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

echo [1/5] 检查 Git 配置...
for /f "delims=" %%i in ('git config user.name 2^>nul') do set GIT_NAME_CHECK=%%i
for /f "delims=" %%i in ('git config user.email 2^>nul') do set GIT_EMAIL_CHECK=%%i

if "%GIT_NAME_CHECK%"=="" (
    echo.
    echo 首次使用 Git，需要配置用户信息：
    set /p GIT_NAME="请输入你的姓名: "
    set /p GIT_EMAIL="请输入你的邮箱: "
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
    echo 配置完成！
    echo.
) else (
    echo Git 用户信息已配置：
    echo   姓名: %GIT_NAME_CHECK%
    echo   邮箱: %GIT_EMAIL_CHECK%
    echo.
)

echo [2/5] 初始化 Git 仓库...
if not exist .git (
    git init
    echo Git 仓库初始化完成
) else (
    echo Git 仓库已存在
)

echo.
echo [3/5] 添加文件到暂存区...
git add .
echo 文件已添加

echo.
echo [4/5] 检查是否已有远程仓库...
git remote get-url origin >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo 需要设置远程仓库地址
    echo 请在 GitHub 上创建一个新仓库，然后复制仓库 URL
    echo 例如: https://github.com/YOUR_USERNAME/SphericalHarmonics.git
    echo.
    set /p REPO_URL="请输入仓库 URL: "
    git remote add origin "%REPO_URL%"
    echo 远程仓库已添加
) else (
    echo 远程仓库已配置
    git remote get-url origin
)

echo.
echo [5/5] 提交代码...
set /p COMMIT_MSG="请输入提交信息 (直接回车使用默认): "
if "%COMMIT_MSG%"=="" set COMMIT_MSG=Initial commit: 3D球谐函数可视化项目

REM 检查是否有文件需要提交
git diff --cached --quiet
if %ERRORLEVEL% EQU 0 (
    echo [警告] 没有文件需要提交，可能所有文件都已被忽略或已提交
    echo 检查 .gitignore 文件，确保需要提交的文件没有被忽略
    echo.
    git status
    echo.
    pause
    exit /b 1
)

git commit -m "%COMMIT_MSG%"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [错误] 提交失败！请检查上面的错误信息
    echo 常见原因：
    echo   1. Git 用户信息未正确配置
    echo   2. 没有文件需要提交
    echo.
    pause
    exit /b 1
)

echo.
echo 提交成功！
echo.

REM 检查是否有提交
git log --oneline -1 >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 没有找到提交记录，无法推送
    pause
    exit /b 1
)

echo 接下来需要推送到 GitHub...
echo 提示: 如果这是第一次推送，可能需要输入 GitHub 用户名和密码（或访问令牌）
echo.
pause

REM 确保分支名为 main
git branch -M main 2>nul

REM 推送代码
git push -u origin main
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [错误] 推送失败！
    echo 可能的原因：
    echo   1. 远程仓库不存在或 URL 错误
    echo   2. 认证失败（用户名/密码或访问令牌错误）
    echo   3. 网络连接问题
    echo.
    echo 请检查：
    echo   1. 远程仓库 URL: 
    git remote get-url origin
    echo   2. 确保在 GitHub 上已创建仓库
    echo   3. 使用个人访问令牌而不是密码
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo 部署完成！
echo ========================================
pause

