#!/usr/bin/env pwsh
# WezTerm 配置 - Git 清理和提交脚本

Write-Host "🔧 WezTerm 配置 Git 清理和提交" -ForegroundColor Cyan
Write-Host ""

# 1. 移除 .idea 的 Git 追踪
Write-Host "1️⃣  从 Git 追踪中移除 .idea/" -ForegroundColor Yellow
git rm -r --cached .idea 2>$null
Write-Host "   ✓ 完成" -ForegroundColor Green
Write-Host ""

# 2. 检查状态
Write-Host "2️⃣  当前 Git 状态：" -ForegroundColor Yellow
git status --short
Write-Host ""

# 3. 暂存所有更改
Write-Host "3️⃣  暂存所有文件..." -ForegroundColor Yellow
git add -A
Write-Host "   ✓ 完成" -ForegroundColor Green
Write-Host ""

# 4. 显示即将提交的内容
Write-Host "4️⃣  待提交的更改：" -ForegroundColor Yellow
git status
Write-Host ""

# 5. 提交
Write-Host "5️⃣  提交更改..." -ForegroundColor Yellow
$message = @"
feat: restructure project to standard wezterm config layout

Changes:
- Remove unnecessary wezterm/ nesting level
- Move all config files to repository root
- Update README to match design documentation
- Enable direct cloning to ~/.config/wezterm without symlinks
- Add comprehensive review and improvement documentation

Project structure:
- 11 modular configuration files (constants, utils, appearance, fonts, tab_bar, background, keybindings, mouse, shell, events, advanced)
- 4-layer architecture (infrastructure, visual, behavior, runtime)
- Cross-platform support (Windows/macOS/Linux)
- Dual keybinding system and runtime features
"@

git commit -m $message
Write-Host "   ✓ 完成" -ForegroundColor Green
Write-Host ""

Write-Host "✅ 清理完成！" -ForegroundColor Green
Write-Host ""
Write-Host "下一步：推送到 GitHub" -ForegroundColor Cyan
Write-Host "  git push -u origin main" -ForegroundColor Yellow
Write-Host ""

