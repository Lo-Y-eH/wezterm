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
