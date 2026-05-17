# WezTerm 配置

个人 WezTerm 终端配置，模块化 Lua 结构，适配 Windows / WSL / macOS / Linux。

## 特性

- **模块化**：每个关注点独立文件，改一处不影响其余
- **跨平台**：自动检测 OS，选择合适的默认 Shell（Nushell → Zsh → Bash / Pwsh）
- **配色切换**：`Leader + s` 运行时实时切换内置配色方案，无需重启
- **背景轮换**：可选随机背景图片，定时切换（需将图片放入 `images/`）
- **双模式快捷键**：Leader 键模式（tmux 风格）+ 直接修饰键（浏览器风格），两套并存
- **SSH 快速连接**：`Leader + o` 弹出已配置的 SSH 域选择器
- **Windows 亚克力效果**：透明磨砂背景，配合系统透明效果使用

## 快速开始

### 1. 克隆仓库

**Linux / macOS**
```bash
git clone https://github.com/<your-username>/wezterm.git ~/.config/wezterm
```

**Windows（PowerShell）**
```powershell
git clone https://github.com/<your-username>/wezterm.git "$env:USERPROFILE\.config\wezterm"
```

克隆完成后，`fonts/` 和 `images/` 目录中的文件已随仓库一起下载，重启 WezTerm 即可生效。

### 2. 启用背景图片（可选）

1. 打开 `wezterm.lua`，取消 `"config.background"` 那行的注释
2. 在 `config/background.lua` 顶部的 `options` 表中修改 `fixed_image` 文件名，或设置 `random = true`
3. 在 `config/appearance.lua` 中将 `window_background_opacity` 调低（建议 `0.85`）

## 键位速查

### Leader 模式（`Ctrl + a` 作为前缀）

| 快捷键 | 功能 |
|--------|------|
| `Leader + n` | 新建标签页 |
| `Leader + w` | 关闭当前标签页 |
| `Leader + Tab` | 切换到下一标签页 |
| `Leader + \` | 横向分割窗格 |
| `Leader + -` | 纵向分割窗格 |
| `Leader + ←↑↓→` | 切换窗格 |
| `Leader + c` | 进入复制模式（Vim 风格） |
| `Leader + /` | 搜索（大小写敏感） |
| `Leader + k` | 清空滚动缓冲区 |
| `Leader + s` | 切换配色方案 |
| `Leader + o` | SSH 连接选择器 |
| `Leader + p` | 启动菜单 |
| `Leader + t` | 切换标签栏显示 |
| `Leader + m` | 最小化窗口 |
| `Leader + v` | 粘贴（Bracketed Paste） |

### 直接快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl + T` | 新建标签页 |
| `Ctrl + W` | 关闭当前标签页 |
| `Ctrl + 1~8` | 跳转到第 N 个标签页 |
| `Ctrl + Shift + W` | 关闭当前窗格（确认） |
| `Ctrl + Shift + ←↑↓→` | 调整窗格大小 |
| `Ctrl + Shift + C` | 复制到剪贴板 |
| `Ctrl + Shift + V` | 粘贴剪贴板 |
| `Ctrl + F` | 搜索（大小写不敏感） |
| `Ctrl + =` | 增大字号 |
| `Ctrl + -` | 减小字号 |
| `Ctrl + 0` | 重置字号 |
| `Ctrl + Q` | 退出 WezTerm |
| `F11` | 全屏切换 |
| `Ctrl + 左键` | 打开超链接 |
| `右键单击` | 粘贴剪贴板 |

## 个性化

各功能模块对应文件：

| 想改什么 | 编辑哪个文件 |
|----------|-------------|
| 字体 / 字号 / 行高 | `config/fonts.lua` |
| 配色 / 透明度 / 亚克力效果 / 窗口边距 | `config/appearance.lua` |
| 光标样式 | `config/appearance.lua` |
| 标签栏样式 | `config/tab_bar.lua` |
| 背景图片 | `config/background.lua` |
| 键位绑定 | `config/keybindings.lua` |
| 鼠标行为 / 超链接规则 | `config/mouse.lua` |
| 默认 Shell / 启动菜单 / SSH | `config/shell.lua` |
| 可切换的配色方案列表 | `config/constants.lua` |
| 滚动行数 / 退出行为 | `config/advanced.lua` |

## 依赖

- [WezTerm](https://wezfurlong.org/wezterm/) ≥ 20240203
- 字体：[Maple Mono NF CN](https://github.com/subframe7536/maple-font)（或替换为任意 Nerd Font，修改 `config/fonts.lua`）
