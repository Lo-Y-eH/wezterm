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
