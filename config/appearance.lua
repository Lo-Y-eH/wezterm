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
