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
