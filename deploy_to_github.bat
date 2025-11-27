@echo off
setlocal enabledelayedexpansion
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
echo [4/5] 检查远程仓库配置...
git remote get-url origin >nul 2>nul
if !ERRORLEVEL! NEQ 0 (
    echo 远程仓库未配置
    goto setup_remote
    ) else (
        for /f "delims=" %%i in ('git remote get-url origin 2^>nul') do set REMOTE_URL=%%i
        if "!REMOTE_URL!"=="" (
            echo 远程仓库配置无效
            goto setup_remote
        ) else (
            echo 远程仓库已配置: !REMOTE_URL!
            echo.
            set /p CHANGE_REMOTE="是否需要修改远程仓库地址？(Y/N，默认N): "
            if /i "!CHANGE_REMOTE!"=="Y" (
                goto setup_remote
            )
        )
    )
goto after_remote

:setup_remote
echo.
echo 需要设置远程仓库地址
echo 请在 GitHub 上创建一个新仓库，然后复制仓库 URL
echo 例如: https://github.com/YOUR_USERNAME/SphericalHarmonics.git
echo.
:get_repo_url
set /p REPO_URL="请输入仓库 URL: "
if "!REPO_URL!"=="" (
    echo [错误] URL 不能为空！
    goto get_repo_url
)

REM 检查 origin 是否已存在
git remote get-url origin >nul 2>nul
if !ERRORLEVEL! EQU 0 (
    echo.
    echo [信息] origin 已存在，正在更新 URL...
    git remote set-url origin "!REPO_URL!"
    if !ERRORLEVEL! EQU 0 (
        echo [成功] 远程仓库 URL 已更新！
        echo 新 URL: !REPO_URL!
    ) else (
        echo [错误] 更新失败！尝试删除后重新添加...
        git remote remove origin
        git remote add origin "!REPO_URL!"
        if !ERRORLEVEL! EQU 0 (
            echo [成功] 远程仓库已重新配置！
            echo URL: !REPO_URL!
        ) else (
            echo [错误] 配置远程仓库失败！
            echo 请检查 URL 格式是否正确
            echo URL 应该类似: https://github.com/用户名/仓库名.git
            pause
            exit /b 1
        )
    )
) else (
    echo.
    echo 正在添加远程仓库...
    git remote add origin "!REPO_URL!"
    if !ERRORLEVEL! EQU 0 (
        echo [成功] 远程仓库已添加！
        echo URL: !REPO_URL!
    ) else (
        echo [错误] 添加远程仓库失败！
        echo 请检查 URL 格式是否正确
        echo URL 应该类似: https://github.com/用户名/仓库名.git
        pause
        exit /b 1
    )
)

after_remote:

echo.
echo [5/5] 检查代码状态...
REM 检查是否有提交历史
git log --oneline -1 >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    REM 有提交历史
    git diff --cached --quiet
    if %ERRORLEVEL% EQU 0 (
        git diff --quiet
        if %ERRORLEVEL% EQU 0 (
            echo [信息] 所有文件已提交，工作区干净
            echo 将直接推送到远程仓库...
            echo.
            goto push_code
        )
    )
)

REM 检查是否有文件需要提交
git diff --cached --quiet
if %ERRORLEVEL% NEQ 0 (
    REM 有暂存的文件，需要提交
    echo [信息] 检测到已暂存的文件，准备提交
) else (
    REM 没有暂存的文件，检查是否有未跟踪或修改的文件
    git diff --quiet
    if %ERRORLEVEL% NEQ 0 (
        echo [信息] 检测到未跟踪或修改的文件，正在添加...
        git add .
    ) else (
        echo [信息] 工作区干净，检查是否有提交历史...
        git log --oneline -1 >nul 2>nul
        if %ERRORLEVEL% EQU 0 (
            echo [信息] 有提交历史，将直接推送
            goto push_code
        ) else (
            echo [警告] 没有文件需要提交，且没有提交历史
            echo 检查 .gitignore 文件，确保需要提交的文件没有被忽略
            echo.
            git status
            echo.
            echo 如果需要强制添加被忽略的文件，请修改 .gitignore 文件
            pause
            exit /b 1
        )
    )
)

REM 执行提交
echo.
set /p COMMIT_MSG="请输入提交信息 (直接回车使用默认): "
if "!COMMIT_MSG!"=="" set COMMIT_MSG=Initial commit: 3D球谐函数可视化项目

git commit -m "!COMMIT_MSG!"
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

push_code:
echo ========================================
echo 开始推送到 GitHub...
echo ========================================
REM 验证远程仓库 URL
for /f "delims=" %%i in ('git remote get-url origin 2^>nul') do set CURRENT_REMOTE_URL=%%i
if "!CURRENT_REMOTE_URL!"=="" (
    echo [错误] 远程仓库 URL 未配置！
    echo 请重新运行脚本并配置远程仓库地址
    pause
    exit /b 1
)
echo 远程仓库: !CURRENT_REMOTE_URL!
echo.
echo 提示: 如果这是第一次推送，可能需要输入 GitHub 用户名和密码（或访问令牌）
echo.
pause

REM 确保分支名为 main
git branch -M main 2>nul

REM 推送代码
git push -u origin main
if !ERRORLEVEL! NEQ 0 (
    echo.
    echo [错误] 推送失败！
    echo.
    echo 当前远程仓库 URL: !CURRENT_REMOTE_URL!
    echo.
    echo 可能的原因：
    echo   1. 远程仓库不存在或 URL 错误
    echo   2. 认证失败（用户名/密码或访问令牌错误）
    echo   3. 网络连接问题
    echo.
    set /p RETRY_REMOTE="是否要重新配置远程仓库地址？(Y/N，默认N): "
    if /i "!RETRY_REMOTE!"=="Y" (
        echo.
        set /p NEW_REPO_URL="请输入新的仓库 URL: "
        if not "!NEW_REPO_URL!"=="" (
            git remote set-url origin "!NEW_REPO_URL!"
            if !ERRORLEVEL! EQU 0 (
                echo [成功] 远程仓库 URL 已更新
                echo 请重新运行脚本或手动执行: git push -u origin main
            ) else (
                echo [错误] 更新失败！
            )
        )
    ) else (
        echo.
        echo 请检查：
        echo   1. 确保在 GitHub 上已创建仓库
        echo   2. 使用个人访问令牌而不是密码
        echo   3. 仓库 URL 格式: https://github.com/用户名/仓库名.git
    )
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo 部署完成！
echo ========================================
pause

