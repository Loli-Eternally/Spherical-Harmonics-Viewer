# GitHub 部署指南

## 前置要求

1. 安装 Git
   - Windows: 下载并安装 [Git for Windows](https://git-scm.com/download/win)
   - macOS: 运行 `brew install git` 或从官网下载
   - Linux: 运行 `sudo apt-get install git`

2. 创建 GitHub 账户
   - 访问 [GitHub](https://github.com) 注册账户

## 部署步骤

### 1. 在 GitHub 上创建新仓库

1. 登录 GitHub
2. 点击右上角的 "+" 号，选择 "New repository"
3. 填写仓库信息：
   - Repository name: `SphericalHarmonics` (或你喜欢的名字)
   - Description: `3D球谐函数可视化工具`
   - 选择 Public 或 Private
   - **不要**勾选 "Initialize this repository with a README"（因为我们已经有了）
4. 点击 "Create repository"

### 2. 在本地初始化 Git 仓库

打开终端（PowerShell 或 CMD），进入项目目录：

```bash
cd D:\BaiduSyncdisk\Markdown\SphericalHarmonics
```

### 3. 初始化 Git 并提交代码

```bash
# 初始化 Git 仓库
git init

# 添加所有文件到暂存区
git add .

# 提交代码
git commit -m "Initial commit: 3D球谐函数可视化项目"

# 添加远程仓库（将 YOUR_USERNAME 替换为你的 GitHub 用户名）
git remote add origin https://github.com/YOUR_USERNAME/SphericalHarmonics.git

# 将代码推送到 GitHub
git branch -M main
git push -u origin main
```

### 4. 配置 Git 用户信息（首次使用需要）

如果这是你第一次使用 Git，需要先配置用户信息：

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## 后续更新代码

当你修改代码后，使用以下命令更新 GitHub：

```bash
# 查看修改状态
git status

# 添加修改的文件
git add .

# 提交修改
git commit -m "描述你的修改内容"

# 推送到 GitHub
git push
```

## 使用 SSH 密钥（可选，更安全）

如果你想要使用 SSH 而不是 HTTPS，可以配置 SSH 密钥：

1. 生成 SSH 密钥：
```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

2. 将公钥添加到 GitHub：
   - 复制 `~/.ssh/id_ed25519.pub` 文件内容
   - GitHub -> Settings -> SSH and GPG keys -> New SSH key
   - 粘贴并保存

3. 将远程仓库 URL 改为 SSH：
```bash
git remote set-url origin git@github.com:YOUR_USERNAME/SphericalHarmonics.git
```

## 常见问题

### 问题1: 推送时要求输入用户名和密码

**解决方案**: 使用个人访问令牌（Personal Access Token）
1. GitHub -> Settings -> Developer settings -> Personal access tokens -> Tokens (classic)
2. 生成新令牌，勾选 `repo` 权限
3. 推送时使用令牌作为密码

### 问题2: 忽略某些文件

检查 `.gitignore` 文件，确保不需要的文件已被忽略。

### 问题3: 合并冲突

如果有冲突，使用以下命令：
```bash
git pull origin main
# 解决冲突后
git add .
git commit -m "解决冲突"
git push
```

## 完成后的仓库链接

部署完成后，你的仓库地址将是：
```
https://github.com/YOUR_USERNAME/SphericalHarmonics
```

记得在 README.md 中更新仓库链接！

