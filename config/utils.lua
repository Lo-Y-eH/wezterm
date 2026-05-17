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
