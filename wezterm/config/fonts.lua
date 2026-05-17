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
