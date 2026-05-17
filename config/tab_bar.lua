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
