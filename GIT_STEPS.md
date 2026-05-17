# 🔧 Git 整理步骤（一步步来）

## 当前情况
- ✅ README.md 已修改
- ✅ .gitignore 已更新（已加入 .idea/）
- ❌ 旧的 wezterm/ 目录已删除但还在 Git 追踪中
- ❌ 新结构的文件还未追踪
- ❌ .idea/ 还被追踪

## 解决方案

### 方法 A：快速方案（推荐）- 运行脚本

在 PowerShell 中运行：

```powershell
cd E:\wezterm-config
.\cleanup-and-commit.ps1
```

这个脚本会：
1. 从 Git 移除 .idea/ 追踪
2. 暂存所有更改
3. 提交一个清晰的重构提交
4. 显示最终状态

---

### 方法 B：手动方案 - 逐个命令

如果你想看到每一步发生了什么：

```powershell
# 1. 进入项目目录
cd E:\wezterm-config

# 2. 从 Git 移除 .idea/（但本地保留）
git rm -r --cached .idea

# 3. 暂存所有更改
git add -A

# 4. 查看待提交的内容
git status

# 5. 提交
git commit -m "refactor: restructure to standard wezterm config layout

- Move all files from wezterm/ to repository root
- Update README to match design documentation
- Add .idea/ to .gitignore
- No functional changes to Lua code"

# 6. 查看日志确认
git log --oneline -3
```

---

## 提交完成后

然后推送到 GitHub：

```powershell
# 关联远程（如果还没关联）
git remote add origin https://github.com/<your-username>/wezterm.git

# 首次推送
git push -u origin main
```

---

## ✅ 验证步骤

提交后应该看到：
```powershell
git status
# On branch main
# nothing to commit, working tree clean
```

提交日志中应该能看到新的重构提交：
```powershell
git log --oneline -5
# 显示新的 refactor 提交
```

---

## 📌 .gitignore 说明

已添加规则：
- `.idea/` - JetBrains IDE 配置
- `*.iml` - IntelliJ 项目文件
- `.vscode/` - VS Code 配置（以备将来使用）

这样就不会污染仓库了！

