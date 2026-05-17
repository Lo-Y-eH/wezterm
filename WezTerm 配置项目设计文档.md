# WezTerm 配置项目设计文档

## 一、设计思路

### 1.1 核心原则

在原有模块化结构的基础上，做两类优化：

1. **合并过细的模块**：`window.lua`（3 行）、`cursor.lua`（5 行）等文件粒度过细，增加了认知负担却没有带来对应价值，合并入 `appearance.lua`。
2. **补充缺失的 GitHub 基础设施**：`README.md`、`.gitignore`、安装说明。

### 1.2 模块合并策略

对原有 14 个模块重新归并为 **11 个**，遵循「同一关注点放在一起」原则：

| 新模块            | 合并自                                              | 理由                                             |
| ----------------- | --------------------------------------------------- | ------------------------------------------------ |
| `appearance.lua`  | `appearance.lua` + `window.lua` + `cursor.lua`      | 三者都是「终端长什么样」的静态视觉配置，内聚性强 |
| `background.lua`  | `background.lua`                                    | 逻辑复杂，独立保留                               |
| `fonts.lua`       | `fonts.lua`                                         | 字体是独立关注点                                 |
| `tab_bar.lua`     | `tab_bar.lua`                                       | 逻辑复杂，独立保留                               |
| `keybindings.lua` | `keybindings.lua`                                   | 独立保留                                         |
| `mouse.lua`       | `mouse.lua` + `hyperlink.lua`                       | 都是「输入/交互规则」，内聚性强                  |
| `shell.lua`       | `shell.lua` + `launch_menu.lua` + `ssh_domains.lua` | 都是「从哪里启动什么程序」，内聚性强             |
| `events.lua`      | `events.lua`                                        | 独立保留                                         |
| `advanced.lua`    | `advanced.lua`                                      | 独立保留                                         |
| `constants.lua`   | `constants.lua`                                     | 基础设施，独立保留                               |
| `utils.lua`       | `utils.lua`                                         | 基础设施，独立保留                               |

### 1.3 项目分层架构

```
┌─────────────────────────────────────┐
│         wezterm.lua (入口)           │  ← 只做模块加载，不含业务逻辑
├─────────────────────────────────────┤
│  基础设施层 constants / utils        │  ← 纯数据 / 纯函数，无副作用
├─────────────────────────────────────┤
│  视觉层  appearance / fonts /        │  ← 终端「长什么样」
│          tab_bar / background        │
├─────────────────────────────────────┤
│  行为层  keybindings / mouse /       │  ← 终端「怎么操作」
│          shell                       │
├─────────────────────────────────────┤
│  运行时层 events / advanced          │  ← 动态行为 / 高级选项
└─────────────────────────────────────┘
```

### 1.4 从参考配置吸收的改进点

| 改进点                                      | 涉及模块          | 说明                                            |
| ------------------------------------------- | ----------------- | ----------------------------------------------- |
| `font_with_fallback` + emoji 回退           | `fonts.lua`       | 比单一字体更健壮，避免 emoji 乱码               |
| `line_height = 1.2`                         | `fonts.lua`       | 改善行间距，长时间阅读更舒适                    |
| `freetype_load_target / render_target`      | `fonts.lua`       | LCD 屏字体渲染优化，Windows 尤其明显            |
| `win32_system_backdrop = "Acrylic"`         | `appearance.lua`  | Windows 亚克力磨砂效果                          |
| `initial_cols / initial_rows`               | `appearance.lua`  | 启动时固定窗口大小                              |
| `inactive_pane_hsb` 改为 `brightness = 0.7` | `appearance.lua`  | 原来设 1.0 等于没效果；0.7 才能真正区分焦点窗格 |
| `animation_fps = 60`                        | `appearance.lua`  | 独立控制动画帧率，与 `max_fps` 分开             |
| `hide_tab_bar_if_only_one_tab = false`      | `tab_bar.lua`     | 始终显示 Tab 栏，方便访问启动菜单               |
| `Ctrl+1~8` Tab 跳转（循环注册）             | `keybindings.lua` | 浏览器式 Tab 跳转，比 Leader 切换快得多         |
| 字体大小调节快捷键                          | `keybindings.lua` | `Ctrl++/-/0` 临时调整字号                       |
| `Ctrl+Shift+C` 复制                         | `keybindings.lua` | 补全 Ctrl+Shift+V 的对应复制操作                |
| `Ctrl+F` 大小写不敏感搜索                   | `keybindings.lua` | 补充直接触发的搜索快捷键                        |
| `Ctrl+Q` 退出                               | `keybindings.lua` | 快速退出                                        |
| `ClipboardAndPrimarySelection`              | `mouse.lua`       | 在 Linux X11 下同时写入主剪贴板                 |
| `gui-startup` 启动最大化                    | `events.lua`      | 启动即最大化，无需手动调整                      |
| Nushell 加入启动菜单                        | `shell.lua`       | 现代 Shell 支持                                 |

------

## 二、目录结构

请按以下结构在**当前目录**创建文件。`fonts/` 和 `images/` **纳入版本控制**，随仓库一起下载，无需用户在新机器上手动补充。

```
./
├── wezterm.lua              # 入口文件
├── config/
│   ├── constants.lua        # 用户可调的共享常量
│   ├── utils.lua            # OS 检测 / 工具函数
│   ├── appearance.lua       # 外观：配色 / 窗口 / 光标 / 渲染
│   ├── fonts.lua            # 字体配置
│   ├── tab_bar.lua          # 标签栏渲染
│   ├── background.lua       # 背景图片轮换
│   ├── keybindings.lua      # 键盘绑定
│   ├── mouse.lua            # 鼠标绑定 + 超链接规则
│   ├── shell.lua            # 默认 Shell / 启动菜单 / SSH 域
│   ├── events.lua           # 事件处理
│   └── advanced.lua         # 滚动 / 退出 / 剪贴板等高级选项
├── fonts/                   # 字体文件（纳入版本控制，随仓库下载）
│   └── .gitkeep
├── images/                  # 背景图片（纳入版本控制，随仓库下载）
│   └── .gitkeep
├── .gitignore
└── README.md
```

------

## 三、完整代码

### `.gitignore`

```gitignore
# macOS 系统文件
.DS_Store

# Windows 缩略图缓存
Thumbs.db

# 编辑器临时文件
*.swp
*.swo
*~
```

> 说明：`fonts/` 和 `images/` 目录中的文件**不**加入 `.gitignore`，直接入库，确保在新机器 `git clone` 后开箱即用。

------

### `README.md`

~~~markdown
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
~~~

------

### `wezterm.lua`

```lua
--------------------------------------------------------------------------------
-- WezTerm 配置入口
-- 职责：仅负责加载子模块，不包含任何业务逻辑
-- 项目地址：https://github.com/<your-username>/wezterm
--------------------------------------------------------------------------------

local wezterm = require("wezterm")
local config  = wezterm.config_builder()

-- 模块加载顺序：视觉 → 行为 → 运行时
-- background 默认禁用，将图片放入 images/ 后取消注释即可启用
local modules = {
    -- 视觉层
    "config.fonts",
    "config.appearance",
    "config.tab_bar",
    -- "config.background",

    -- 行为层
    "config.keybindings",
    "config.mouse",
    "config.shell",

    -- 运行时层
    "config.events",
    "config.advanced",
}

for _, name in ipairs(modules) do
    local ok, mod = pcall(require, name)
    if not ok then
        wezterm.log_error("Failed to load module: " .. name .. "\n" .. tostring(mod))
    elseif mod and mod.apply then
        mod.apply(config)
    end
end

return config
```

------

### `config/constants.lua`

```lua
--------------------------------------------------------------------------------
-- 共享常量
-- 这是最常需要个性化修改的基础设施文件
-- 所有模块通过 require("config.constants") 取用
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local M = {}

-- WezTerm 配置目录（自动解析，无需手动修改）
M.CONFIG_DIR = wezterm.config_dir

-- Leader + s 可切换的配色方案列表
-- 完整方案列表：https://wezterm.org/colorschemes/index.html
M.COLOR_SCHEMES = {
    "catppuccin-frappe",
    "catppuccin-mocha",
    "catppuccin-latte",
    "Tokyo Night",
    "Ayu Mirage",
    "One Dark (Gogh)",
    "Dracula",
    "Gruvbox Dark (Gogh)",
    "Nord",
    "Rose Pine",
    "Solarized Dark (Gogh)",
}

return M
```

------

### `config/utils.lua`

```lua
--------------------------------------------------------------------------------
-- 工具函数
-- 纯函数，无副作用，不修改任何全局状态
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local M = {}

--- 判断当前是否为 Windows 系统
---@return boolean
function M.is_windows()
    return wezterm.target_triple:find("windows") ~= nil
end

--- 判断当前是否为 macOS 系统
---@return boolean
function M.is_macos()
    return wezterm.target_triple:find("apple") ~= nil
end

--- 检查 Unix 下命令是否存在（使用 command -v）
---@param cmd string 命令名称
---@return boolean
function M.unix_command_exists(cmd)
    local ok, stdout = wezterm.run_child_process({ "sh", "-c", "command -v " .. cmd })
    return ok and stdout and stdout ~= ""
end

--- 检查 Windows 下命令是否存在（使用 where）
---@param cmd string 命令名称
---@return boolean
function M.windows_command_exists(cmd)
    local ok, stdout = wezterm.run_child_process({ "where", cmd })
    return ok and stdout and stdout ~= ""
end

return M
```

------

### `config/appearance.lua`

> 合并自原来的 `appearance.lua` + `window.lua` + `cursor.lua`，三者都描述「终端静态外观」。 新增：`win32_system_backdrop`、`initial_cols/rows`、`animation_fps`，修正 `inactive_pane_hsb`。

```lua
--------------------------------------------------------------------------------
-- 外观配置
-- 包含：配色方案、渲染后端、窗口装饰、透明度、边距、光标、非活跃窗格
--------------------------------------------------------------------------------

local utils = require("config.utils")

local M = {}

function M.apply(config)

    -- ── 配色方案 ──────────────────────────────────────────────────────────────
    config.color_scheme = "catppuccin-frappe"

    -- 滚动条颜色（与配色方案协调）
    config.colors = config.colors or {}
    config.colors.scrollbar_thumb = "#242936"

    -- 命令面板样式（磨砂深色）
    config.command_palette_bg_color = "rgba(12, 14, 20, 0.92)"
    config.command_palette_fg_color = "#e6e9ef"

    -- ── 渲染后端 ──────────────────────────────────────────────────────────────
    config.front_end               = "WebGpu"
    config.webgpu_power_preference = "HighPerformance"
    config.max_fps                 = 120
    -- animation_fps 控制光标闪烁、选区高亮等动画的帧率，独立于渲染最大帧率
    config.animation_fps           = 60

    -- ── 窗口外观 ──────────────────────────────────────────────────────────────
    -- RESIZE：无标题栏，保留调整大小边框（配合 Ctrl+Alt 拖动移动窗口）
    config.window_decorations = "RESIZE"

    -- 调整字号时不自动改变窗口大小
    config.adjust_window_size_when_changing_font_size = false

    -- 关闭时不弹确认框
    config.window_close_confirmation = "NeverPrompt"

    -- 背景透明度（0.0 完全透明 ~ 1.0 完全不透明）
    -- 启用背景图片时建议调至 0.85 左右
    config.window_background_opacity = 0.95

    -- Windows 亚克力磨砂效果（需在系统设置中开启透明效果）
    -- 可选值："Disable" | "Acrylic" | "Mica" | "Tabbed"
    -- 非 Windows 系统此项自动忽略，无需条件判断
    config.win32_system_backdrop = "Acrylic"

    -- 窗口内边距（适当留白比全清零更舒适）
    config.window_padding = {
        left   = 8,
        right  = 8,
        top    = 6,
        bottom = 4,
    }

    -- 启动时的初始窗口尺寸（字符数），gui-startup 事件会将其最大化
    -- 此值作为非最大化状态下的默认大小
    config.initial_cols = 200
    config.initial_rows = 50

    -- ── 光标 ─────────────────────────────────────────────────────────────────
    config.default_cursor_style  = "BlinkingBar"
    config.cursor_blink_rate     = 600
    -- Linear 闪烁更像传统终端；EaseOut 更平滑，按个人喜好选择
    config.cursor_blink_ease_in  = "Linear"
    config.cursor_blink_ease_out = "Linear"
    config.underline_thickness   = "1pt"

    -- ── 非活跃窗格 ───────────────────────────────────────────────────────────
    -- 分屏时，非焦点窗格变暗，一眼区分当前工作区域
    -- brightness 越低越暗，推荐范围 0.6 ~ 0.8
    config.inactive_pane_hsb = {
        saturation = 0.9,
        brightness = 0.7,
    }
end

return M
```

------

### `config/fonts.lua`

> 新增：`font_with_fallback`（含 emoji 回退）、`line_height`、`freetype` 渲染优化（OS 感知）。

```lua
--------------------------------------------------------------------------------
-- 字体配置
-- 字体文件放在 <config_dir>/fonts/ 目录，随仓库一起入库
--------------------------------------------------------------------------------

local wezterm   = require("wezterm")
local constants = require("config.constants")
local utils     = require("config.utils")

local M = {}

function M.apply(config)

    -- 仅从项目 fonts/ 目录加载，不使用系统字体（保证跨机器可移植性）
    config.font_dirs    = { constants.CONFIG_DIR .. "/fonts" }
    config.font_locator = "ConfigDirsOnly"

    -- 字体回退链：主字体 → emoji 兜底
    -- 当主字体缺少某个字形时，自动回退到下一个，避免出现方块乱码
    config.font = wezterm.font_with_fallback({
        -- 主字体：推荐 Maple Mono NF CN（含中文 + Nerd Font 图标）
        -- https://github.com/subframe7536/maple-font
        { family = "Maple Mono NF CN", weight = "Regular" },
        -- emoji 回退：优先使用系统自带 emoji 字体
        { family = "Segoe UI Emoji"   },  -- Windows
        { family = "Apple Color Emoji" }, -- macOS
        { family = "Noto Color Emoji"  }, -- Linux
    })

    -- 字号（pt）
    config.font_size = 12

    -- 行高（1.0 = 字体默认行高；1.2 增加行间距，长时间阅读更舒适）
    config.line_height = 1.2

    -- ── Windows LCD 字体渲染优化 ──────────────────────────────────────────────
    -- 在 LCD 屏幕上亚像素渲染可以显著改善字体清晰度
    -- macOS / Linux 上这两个选项通常不需要调整
    if utils.is_windows() then
        -- Light：减轻字体描边，避免 Windows 上字体过重
        config.freetype_load_target   = "Light"
        -- HorizontalLcd：启用水平亚像素渲染（适用于绝大多数 LCD 显示器）
        config.freetype_render_target = "HorizontalLcd"
    end
end

return M
```

------

### `config/tab_bar.lua`

> 新增：`hide_tab_bar_if_only_one_tab = false`，始终显示 Tab 栏。

```lua
--------------------------------------------------------------------------------
-- 标签栏配置
-- 自动从当前配色方案提取颜色，无需手动指定颜色值
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local M = {}

-- 从 config 对象解析当前配色方案的完整颜色表
local function resolve_scheme(config)
    if not config or not config.color_scheme then return nil end
    local name     = config.color_scheme
    local builtins = wezterm.get_builtin_color_schemes()
    if config.color_schemes and config.color_schemes[name] then
        return config.color_schemes[name]
    end
    if builtins and builtins[name] then
        return builtins[name]
    end
    return nil
end

local function pick(primary, fallback)
    return (primary and primary ~= "") and primary or fallback
end

-- 根据配色方案生成标签栏颜色表
local function make_tab_bar_colors(config)
    local s = resolve_scheme(config)
    if not s then return nil end

    local fg          = pick(s.foreground, "#c0c0c0")
    local inactive_fg = (s.ansi and s.ansi[8]) or (s.brights and s.brights[1]) or fg
    local transparent = "rgba(0,0,0,0)"
    local hover_bg    = "rgba(0,0,0,0.25)"

    return {
        background         = transparent,
        active_tab         = { bg_color = transparent, fg_color = fg,          intensity = "Bold" },
        inactive_tab       = { bg_color = transparent, fg_color = inactive_fg                     },
        inactive_tab_hover = { bg_color = hover_bg,    fg_color = fg                             },
        new_tab            = { bg_color = transparent, fg_color = inactive_fg                     },
        new_tab_hover      = { bg_color = hover_bg,    fg_color = fg                             },
    }
end

function M.apply(config)

    -- ── 标签栏全局设置 ────────────────────────────────────────────────────────
    config.enable_tab_bar                             = true
    config.tab_bar_at_bottom                          = true
    config.use_fancy_tab_bar                          = false   -- 使用自定义渲染
    config.show_new_tab_button_in_tab_bar             = true
    config.show_tab_index_in_tab_bar                  = true
    config.show_tabs_in_tab_bar                       = true
    config.switch_to_last_active_tab_when_closing_tab = true
    config.tab_max_width                              = 25
    -- 只有一个 Tab 时也保持显示，方便随时访问启动菜单
    config.hide_tab_bar_if_only_one_tab               = false

    -- ── 配色（自动跟随 color_scheme）────────────────────────────────────────
    local colors = make_tab_bar_colors(config)
    if colors then
        config.colors         = config.colors or {}
        config.colors.tab_bar = colors
    end

    -- ── 新建标签按钮样式 ──────────────────────────────────────────────────────
    config.tab_bar_style = {
        new_tab = wezterm.format({
            { Foreground = { Color = "#5fbf7d" } },
            { Text = " + " },
        }),
        new_tab_hover = wezterm.format({
            { Foreground = { Color = "#7ad491" } },
            { Text = " + " },
        }),
    }

    -- ── 标签标题渲染（format-tab-title 事件）────────────────────────────────
    wezterm.on("format-tab-title", function(tab, _tabs, _panes, cfg, hover, _max_width)
        local s = resolve_scheme(cfg)
        if not s then return tab.active_pane.title end

        local bg          = hover and "rgba(0,0,0,0.25)" or "rgba(0,0,0,0)"
        local fg          = pick(s.foreground, "#c0c0c0")
        -- 标签序号使用品红色系（ansi[5] = magenta）
        local index_color = (s.ansi and s.ansi[5]) or fg
        -- 活跃标签标题暖红色高亮，非活跃用前景色
        local title_color = tab.is_active and "#e28a8a" or fg
        local intensity   = tab.is_active and "Bold" or "Normal"
        local title       = tab.active_pane.title or ""

        return wezterm.format({
            { Background = { Color = bg          } },
            { Foreground = { Color = index_color } },
            { Text = string.format(" %d:", tab.tab_index + 1) },
            { Foreground = { Color = title_color } },
            { Attribute = { Intensity = intensity } },
            { Text = " " .. title .. " " },
        })
    end)
end

return M
```

------

### `config/background.lua`

```lua
--------------------------------------------------------------------------------
-- 背景图片配置
-- 支持固定图片和随机轮换，默认禁用（在 wezterm.lua 中注释掉了此模块）
-- 使用方式：将图片放入 images/ 目录，在 wezterm.lua 取消注释即可
--------------------------------------------------------------------------------

local wezterm   = require("wezterm")
local constants = require("config.constants")

local M = {}

-- ── 用户可调选项 ─────────────────────────────────────────────────────────────
local options = {
    -- 是否启用背景图片
    enabled = true,
    -- true = 从 image_dir 随机选图；false = 使用 fixed_image
    random = false,
    -- random = false 时使用的固定图片文件名（相对于 image_dir）
    fixed_image = "01.jpg",
    -- 随机模式下切换间隔（分钟）
    interval_minutes = 30,
    -- 图片目录
    image_dir = constants.CONFIG_DIR .. "/images",
    -- 图片亮度 / 色调 / 饱和度调整（值越低越暗，适合作为背景）
    image_hsb = {
        brightness = 0.08,
        hue        = 1.0,
        saturation = 1.0,
    },
}

-- ── 内部状态 ─────────────────────────────────────────────────────────────────
local image_pool       = nil
local last_switch_time = 0
local last_image       = nil

local function is_image_file(path)
    local lower = path:lower()
    return lower:match("%.png$")
        or lower:match("%.jpg$")
        or lower:match("%.jpeg$")
        or lower:match("%.webp$")
        or lower:match("%.gif$")
end

local function load_images()
    if image_pool and #image_pool > 0 then return image_pool end
    local ok, entries = pcall(wezterm.read_dir, options.image_dir)
    if not ok or not entries then
        wezterm.log_warn("背景图片目录读取失败: " .. options.image_dir)
        return {}
    end
    image_pool = {}
    for _, entry in ipairs(entries) do
        if is_image_file(entry) then
            table.insert(image_pool, entry)
        end
    end
    return image_pool
end

local function resolve_fixed()
    if not options.fixed_image or options.fixed_image == "" then return nil end
    return options.image_dir .. "/" .. options.fixed_image
end

local function pick_image()
    if not options.enabled then return nil end
    if not options.random  then return resolve_fixed() end
    local images = load_images()
    if #images == 0 then return last_image or resolve_fixed() end
    return images[math.random(#images)]
end

local function apply_image(window, image)
    if not image then return end
    last_image = image
    local overrides = window:get_config_overrides() or {}
    overrides.window_background_image     = image
    overrides.window_background_image_hsb = options.image_hsb
    window:set_config_overrides(overrides)
end

function M.apply(config)
    if not options.enabled then return end

    local initial = pick_image()
    if initial then
        config.window_background_image     = initial
        config.window_background_image_hsb = options.image_hsb
        -- 启用背景图片时建议在 appearance.lua 将 opacity 调低至 0.85 左右
    end

    -- 随机模式：通过 update-status 事件定时切换
    if options.random then
        config.status_update_interval = options.interval_minutes * 60 * 1000

        wezterm.on("update-status", function(window, _pane)
            local now = os.time()
            if now - last_switch_time < options.interval_minutes * 60 then return end
            last_switch_time = now
            apply_image(window, pick_image())
        end)
    end
end

return M
```

------

### `config/keybindings.lua`

> 新增：`Ctrl+1~8` Tab 跳转（循环注册）、字体大小调节、`Ctrl+Shift+C`、`Ctrl+F` 搜索、`Ctrl+Q` 退出。 两套快捷键并存，互不冲突。

```lua
--------------------------------------------------------------------------------
-- 键盘绑定
-- 两套并存：Leader 模式（tmux 风格）+ 直接修饰键（浏览器风格）
-- Leader 键：Ctrl + a（与 tmux 风格对齐）
--------------------------------------------------------------------------------

local wezterm   = require("wezterm")
local constants = require("config.constants")

local M = {}

function M.apply(config)
    local act = wezterm.action

    -- 禁用 WezTerm 内置默认快捷键，使用完全自定义方案
    config.disable_default_key_bindings = true

    -- Leader 键定义
    config.leader = {
        key                  = "a",
        mods                 = "CTRL",
        timeout_milliseconds = 1500,
    }

    -- 配色方案选择列表（从 constants 读取，统一维护）
    local scheme_choices = {}
    for _, s in ipairs(constants.COLOR_SCHEMES) do
        table.insert(scheme_choices, { label = s })
    end

    config.keys = {

        -- ════════════════════════════════════════════════════════════════
        -- Leader 模式（Ctrl+a 作为前缀，tmux 风格）
        -- ════════════════════════════════════════════════════════════════

        -- 窗口管理
        { key = "F11", mods = "NONE",   action = act.ToggleFullScreen },
        { key = "m",   mods = "LEADER", action = act.Hide             },

        -- 标签页（Leader 模式）
        { key = "n",   mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain")        },
        { key = "w",   mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) },
        { key = "Tab", mods = "LEADER", action = act.ActivateTabRelative(1)               },
        { key = "t",   mods = "LEADER", action = act.EmitEvent("toggle-tab-bar")          },

        -- 窗格分割（Leader 模式）
        { key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
        { key = "-",  mods = "LEADER", action = act.SplitVertical  ({ domain = "CurrentPaneDomain" }) },

        -- 窗格导航（Leader + 方向键）
        { key = "LeftArrow",  mods = "LEADER", action = act.ActivatePaneDirection("Left")  },
        { key = "DownArrow",  mods = "LEADER", action = act.ActivatePaneDirection("Down")  },
        { key = "UpArrow",    mods = "LEADER", action = act.ActivatePaneDirection("Up")    },
        { key = "RightArrow", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

        -- 复制 / 搜索（Leader 模式）
        { key = "c",    mods = "LEADER", action = act.ActivateCopyMode                         },
        { key = "/",    mods = "LEADER", action = act.Search("CurrentSelectionOrEmptyString")  },
        { key = "k",    mods = "LEADER", action = act.ClearScrollback("ScrollbackAndViewport") },
        { key = "Home", mods = "LEADER", action = act.ScrollToTop                              },
        { key = "End",  mods = "LEADER", action = act.ScrollToBottom                           },

        -- 粘贴（Leader 模式）
        -- Leader+v：Bracketed Paste 模式，适配支持该协议的编辑器（Vim / Helix）
        { key = "v", mods = "LEADER", action = act.PasteFrom("Clipboard") },

        -- 启动器（Leader 模式）
        {
            key    = "p",
            mods   = "LEADER",
            action = act.ShowLauncherArgs({
                title = "🚀 启动菜单",
                flags = "FUZZY|LAUNCH_MENU_ITEMS",
            }),
        },
        {
            key    = "Space",
            mods   = "LEADER",
            action = act.ShowLauncherArgs({
                flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS|KEY_ASSIGNMENTS",
            }),
        },
        {
            key    = "o",
            mods   = "LEADER",
            action = act.ShowLauncherArgs({
                title = "🔗 SSH 连接",
                flags = "FUZZY|DOMAINS",
            }),
        },

        -- 配色方案切换（Leader + s）
        {
            key  = "s",
            mods = "LEADER",
            action = act.InputSelector({
                title   = "🎨 选择配色方案",
                choices = scheme_choices,
                action  = wezterm.action_callback(function(window, _pane, _id, label)
                    if label then
                        window:set_config_overrides({ color_scheme = label })
                        wezterm.log_info("配色方案 → " .. label)
                    end
                end),
            }),
        },

        -- ════════════════════════════════════════════════════════════════
        -- 直接快捷键（浏览器 / 现代终端风格，无需 Leader 前缀）
        -- ════════════════════════════════════════════════════════════════

        -- 标签页
        { key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain")        },
        { key = "w", mods = "CTRL", action = act.CloseCurrentTab({ confirm = false }) },

        -- 窗格关闭（与 Leader+w 关闭标签页区分）
        { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },

        -- 窗格大小调整（Ctrl+Shift + 方向键）
        { key = "LeftArrow",  mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left",  5 }) },
        { key = "DownArrow",  mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down",  5 }) },
        { key = "UpArrow",    mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up",    5 }) },
        { key = "RightArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

        -- 复制 / 粘贴
        { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
        { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

        -- Ctrl+Shift+V 增强版：直接 SendString 发送文本到终端
        -- 适用于不支持 Bracketed Paste 的程序（如 SSH 内某些交互式脚本）
        {
            key  = "V",
            mods = "CTRL|SHIFT",
            action = wezterm.action_callback(function(window, pane)
                local text = window:copy_clipboard("Clipboard")
                if text then pane:send_text(text) end
            end),
        },

        -- 搜索（大小写不敏感，直接触发，无需 Leader）
        {
            key    = "f",
            mods   = "CTRL",
            action = act.Search({ CaseInSensitiveString = "" }),
        },

        -- 字体大小调节（临时调整，重启后恢复默认值）
        { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
        { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
        { key = "0", mods = "CTRL", action = act.ResetFontSize    },

        -- 退出
        { key = "q", mods = "CTRL", action = act.QuitApplication },
    }

    -- Ctrl+1~8：直接跳转到对应标签页（浏览器式体验）
    -- 用循环批量注册，比手写 8 条更简洁优雅
    for i = 1, 8 do
        table.insert(config.keys, {
            key    = tostring(i),
            mods   = "CTRL",
            action = act.ActivateTab(i - 1),
        })
    end
end

return M
```

------

### `config/mouse.lua`

> 合并自原来的 `mouse.lua` + `hyperlink.lua`。 改进：左键选中改为 `ClipboardAndPrimarySelection`，在 Linux X11 下同时写入主剪贴板。

```lua
--------------------------------------------------------------------------------
-- 鼠标绑定 + 超链接规则
--------------------------------------------------------------------------------

local wezterm = require("wezterm")

local M = {}

function M.apply(config)
    local act = wezterm.action

    -- 保留 WezTerm 默认鼠标行为，在此基础上叠加自定义绑定
    config.disable_default_mouse_bindings = false

    config.mouse_bindings = {
        -- 左键单击释放：复制选中内容到剪贴板
        -- ClipboardAndPrimarySelection：同时写入系统剪贴板和 X11 主剪贴板（Linux 友好）
        {
            event  = { Up = { streak = 1, button = "Left" } },
            mods   = "NONE",
            action = act.CompleteSelection("ClipboardAndPrimarySelection"),
        },
        -- 右键单击释放：粘贴剪贴板
        {
            event  = { Up = { streak = 1, button = "Right" } },
            mods   = "NONE",
            action = act.PasteFrom("Clipboard"),
        },
        -- Ctrl + 左键单击：打开光标处超链接
        {
            event  = { Up = { streak = 1, button = "Left" } },
            mods   = "CTRL",
            action = act.OpenLinkAtMouseCursor,
        },
        -- Ctrl+Alt + 左键拖动：拖动移动窗口（配合 RESIZE 窗口装饰使用）
        {
            event  = { Drag = { streak = 1, button = "Left" } },
            mods   = "CTRL|ALT",
            action = act.StartWindowDrag,
        },
    }

    -- ── 超链接识别规则（按优先级排列）────────────────────────────────────────
    config.hyperlink_rules = {
        -- Windows 绝对路径：C:\Users\name\file.txt 或 C:/Users/name/file.txt
        {
            regex     = "\\b([A-Za-z]:[\\\\/][^\\s<>\\\"']+)\\b",
            format    = "file://$1",
            highlight = 1,
        },
        -- 括号包裹的 URL：(https://example.com)
        { regex = "\\((\\w+://\\S+)\\)",              format = "$1", highlight = 1 },
        -- 方括号包裹的 URL：[https://example.com]
        { regex = "\\[(\\w+://\\S+)\\]",              format = "$1", highlight = 1 },
        -- 花括号包裹的 URL：{https://example.com}
        { regex = "\\{(\\w+://\\S+)\\}",              format = "$1", highlight = 1 },
        -- 尖括号包裹的 URL：<https://example.com>
        { regex = "<(\\w+://\\S+)>",                  format = "$1", highlight = 1 },
        -- 普通 URL
        { regex = "\\b\\w+://\\S+[)/a-zA-Z0-9-]+",   format = "$0"               },
        -- 邮箱地址
        { regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b", format = "mailto:$0"        },
    }
end

return M
```

------

### `config/shell.lua`

> 合并自原来的 `shell.lua` + `launch_menu.lua` + `ssh_domains.lua`。 新增：Nushell（`nu`）作为 Unix 下的优先 Shell 选项。

```lua
--------------------------------------------------------------------------------
-- Shell / 启动菜单 / SSH 域
-- 所有「从哪里启动程序」的配置集中于此
--------------------------------------------------------------------------------

local utils = require("config.utils")

local M = {}

function M.apply(config)

    -- ── 默认 Shell ───────────────────────────────────────────────────────────
    -- 优先级：Windows → Pwsh；Unix → Nushell → Zsh → Bash
    if utils.is_windows() then
        config.default_prog = { "pwsh", "--NoLogo" }
    elseif utils.unix_command_exists("nu") then
        config.default_prog = { "nu" }
    elseif utils.unix_command_exists("zsh") then
        config.default_prog = { "zsh", "-i" }
    else
        config.default_prog = { "bash", "-i" }
    end

    -- ── 启动菜单（Leader + p 唤出）────────────────────────────────────────────
    -- 按平台分组：Shell → WSL → SSH
    config.launch_menu = {
        -- Shell
        { label = "Nushell",        args = { "nu"                           } },
        { label = "Zsh",            args = { "zsh",           "-l"          } },
        { label = "Bash",           args = { "bash",          "-l"          } },
        { label = "Pwsh",           args = { "pwsh.exe",      "--NoLogo"    } },
        { label = "PowerShell",     args = { "powershell.exe","--NoLogo"    } },

        -- WSL 发行版
        { label = "WSL: Fedora",    args = { "wsl.exe", "-d", "fedora"     } },

        -- SSH 快捷项（也可在 SSH Domains 中配置并用 Leader+o 连接）
        { label = "SSH: linuxbrew", args = { "ssh", "linuxbrew@122.207.79.209" } },
        { label = "SSH: software",  args = { "ssh", "software@122.207.79.209"  } },
    }

    -- ── SSH 域（Leader + o 唤出，支持 WezTerm 原生 SSH 多路复用）────────────
    -- 优势：WezTerm 接管 SSH 连接后可共享本地 GPU 渲染，支持远程标签页
    config.ssh_domains = {
        {
            name           = "mint",
            remote_address = "122.207.79.207:22",
            username       = "mint",
            -- 如需指定私钥，取消注释：
            -- ssh_option = { identityfile = "~/.ssh/id_rsa" },
        },
        {
            name           = "linuxbrew",
            remote_address = "122.207.79.207:22",
            username       = "linuxbrew",
        },
        {
            name           = "software",
            remote_address = "122.207.79.207:22",
            username       = "software",
        },
    }
end

return M
```

------

### `config/events.lua`

> 新增：`gui-startup` 事件，启动时自动最大化窗口。

```lua
--------------------------------------------------------------------------------
-- 事件处理
-- 运行时动态行为，通过 wezterm.on() 注册
--------------------------------------------------------------------------------

local wezterm = require("wezterm")
local mux     = wezterm.mux

local M = {}

function M.apply(_config)

    -- ── 启动时最大化 ──────────────────────────────────────────────────────────
    -- gui-startup 在 GUI 窗口创建后、首个 Tab 绘制前触发，是最适合最大化的时机
    wezterm.on("gui-startup", function(cmd)
        local _tab, _pane, window = mux.spawn_window(cmd or {})
        window:gui_window():maximize()
    end)

    -- ── 切换标签栏显示 ────────────────────────────────────────────────────────
    -- 触发：Leader + t（在 keybindings.lua 中定义）
    wezterm.on("toggle-tab-bar", function(window, _pane)
        local overrides = window:get_config_overrides() or {}
        -- 首次触发时 enable_tab_bar 为 nil（等同于 true），之后才有明确值
        local current = overrides.enable_tab_bar
        overrides.enable_tab_bar = not (current == nil and true or current)
        window:set_config_overrides(overrides)
    end)

    -- ── 超链接打开处理 ────────────────────────────────────────────────────────
    -- 对 file:// 协议做 Windows 路径规范化，其余 URI 直接系统打开
    wezterm.on("open-uri", function(_window, _pane, uri)
        if uri:lower():match("^file://") then
            local normalized = uri
            -- Windows 驱动器路径 file://C:\ → file:///C:\
            if normalized:match("^file://[A-Za-z]:") then
                normalized = normalized:gsub("^file://", "file:///")
            end
            -- 反斜杠统一转正斜杠
            normalized = normalized:gsub("\\\\", "/")
            wezterm.open_with(normalized)
        else
            wezterm.open_with(uri)
        end
        return true
    end)
end

return M
```

------

### `config/advanced.lua`

```lua
--------------------------------------------------------------------------------
-- 高级选项
-- 滚动、退出行为、SSH 后端等不属于其他模块的配置
--------------------------------------------------------------------------------

local M = {}

function M.apply(config)

    -- ── 滚动 ─────────────────────────────────────────────────────────────────
    config.enable_scroll_bar = false
    config.scrollback_lines  = 20000

    -- ── 自动重载 ─────────────────────────────────────────────────────────────
    config.automatically_reload_config = true

    -- ── 退出行为 ─────────────────────────────────────────────────────────────
    -- CloseOnCleanExit：Shell 正常退出时关闭窗口；异常退出保留窗口查看原因
    config.exit_behavior           = "CloseOnCleanExit"
    config.exit_behavior_messaging = "Verbose"

    -- ── 状态更新间隔（ms）───────────────────────────────────────────────────
    -- 影响右侧状态栏刷新频率，不宜太低（消耗 CPU）
    -- 若启用了 background 随机轮换，background.lua 会覆盖此值
    config.status_update_interval = 50000

    -- ── SSH 后端 ──────────────────────────────────────────────────────────────
    -- Ssh2 对密码认证支持更好，推荐保留
    config.ssh_backend = "Ssh2"

    -- ── Wayland（Linux 专属）────────────────────────────────────────────────
    -- Windows / macOS 设为 false 即可；Linux Wayland 用户改为 true
    config.enable_wayland = false

    -- ── OSC 52 剪贴板支持 ────────────────────────────────────────────────────
    -- 允许远程程序（如 SSH 内的 Vim / Helix / tmux）通过 OSC 52 读写本地剪贴板
    -- WezTerm 默认已开启，此处仅作记录
    -- config.enable_osc52_clipboard_write = true
end

return M
```

------

### `fonts/.gitkeep`

空文件，用于 Git 追踪空目录。将字体文件（`.ttf` / `.otf`）放入此目录后直接提交即可。

### `images/.gitkeep`

空文件，用于 Git 追踪空目录。将背景图片放入此目录后直接提交即可。

------

## 四、执行指令

你已提前进入目标目录，请直接在当前目录执行以下操作：

```bash
# 1. 创建子目录结构
mkdir -p config fonts images

# 2. 创建空目录占位文件（确保 Git 可以追踪空目录）
touch fonts/.gitkeep
touch images/.gitkeep

# 3. 初始化 Git 仓库
git init
git branch -M main

# 4. 按本文档「完整代码」一节逐一创建以下文件：
#
#    .gitignore
#    README.md
#    wezterm.lua
#    config/constants.lua
#    config/utils.lua
#    config/appearance.lua
#    config/fonts.lua
#    config/tab_bar.lua
#    config/background.lua
#    config/keybindings.lua
#    config/mouse.lua
#    config/shell.lua
#    config/events.lua
#    config/advanced.lua

# 5. 初次提交
git add .
git commit -m "feat: initial modular wezterm config"

# 6. 推送到 GitHub（先在 GitHub 上创建同名空仓库，不要勾选初始化 README）
git remote add origin https://github.com/<your-username>/wezterm.git
git push -u origin main
```

------

## 五、使用说明

### 在新机器上安装

```bash
# Linux / macOS
git clone https://github.com/<your-username>/wezterm.git ~/.config/wezterm

# Windows（PowerShell）
git clone https://github.com/<your-username>/wezterm.git "$env:USERPROFILE\.config\wezterm"
```

克隆完成后，`fonts/` 和 `images/` 中的文件已一并下载，重启 WezTerm 即可直接使用，无需额外操作。

### 启用背景图片

1. 打开 `wezterm.lua`，取消 `"config.background"` 那行的注释
2. 在 `config/background.lua` 顶部的 `options` 表中修改 `fixed_image` 为你放入 `images/` 的文件名，或设置 `random = true`
3. 在 `config/appearance.lua` 中将 `window_background_opacity` 调低（建议 `0.85`）

### 添加新 SSH 主机

编辑 `config/shell.lua`，在 `config.ssh_domains` 中追加条目，同时可在 `config.launch_menu` 中加入对应的快捷 SSH 项。

### 切换配色方案（运行时）

按 `Leader + s`（即 `Ctrl+a` 然后按 `s`），在弹出的选择器中选择即可立即生效，下次启动恢复默认。如需永久修改，编辑 `config/appearance.lua` 中的 `config.color_scheme`。