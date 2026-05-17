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
