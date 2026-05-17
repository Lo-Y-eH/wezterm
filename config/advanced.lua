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
