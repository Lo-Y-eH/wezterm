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
