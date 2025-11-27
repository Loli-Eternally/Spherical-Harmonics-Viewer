#!/bin/bash

echo "========================================"
echo "GitHub 部署脚本"
echo "========================================"
echo ""

# 检查是否安装了 Git
if ! command -v git &> /dev/null; then
    echo "[错误] 未检测到 Git，请先安装 Git"
    exit 1
fi

echo "[1/5] 检查 Git 配置..."
if [ -z "$(git config user.name)" ]; then
    echo ""
    echo "首次使用 Git，需要配置用户信息："
    read -p "请输入你的姓名: " GIT_NAME
    read -p "请输入你的邮箱: " GIT_EMAIL
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    echo "配置完成！"
    echo ""
fi

echo "[2/5] 初始化 Git 仓库..."
if [ ! -d .git ]; then
    git init
    echo "Git 仓库初始化完成"
else
    echo "Git 仓库已存在"
fi

echo ""
echo "[3/5] 添加文件到暂存区..."
git add .
echo "文件已添加"

echo ""
echo "[4/5] 检查是否已有远程仓库..."
if ! git remote get-url origin &> /dev/null; then
    echo ""
    echo "需要设置远程仓库地址"
    echo "请在 GitHub 上创建一个新仓库，然后复制仓库 URL"
    echo "例如: https://github.com/YOUR_USERNAME/SphericalHarmonics.git"
    echo ""
    read -p "请输入仓库 URL: " REPO_URL
    git remote add origin "$REPO_URL"
    echo "远程仓库已添加"
else
    echo "远程仓库已配置"
    git remote get-url origin
fi

echo ""
echo "[5/5] 提交代码..."
read -p "请输入提交信息 (直接回车使用默认): " COMMIT_MSG
if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG="Initial commit: 3D球谐函数可视化项目"
fi

git commit -m "$COMMIT_MSG"

echo ""
echo "提交完成！"
echo ""
echo "接下来需要推送到 GitHub..."
echo "提示: 如果这是第一次推送，可能需要输入 GitHub 用户名和密码（或访问令牌）"
echo ""
read -p "按回车继续推送..."

git branch -M main
git push -u origin main

echo ""
echo "========================================"
echo "部署完成！"
echo "========================================"

