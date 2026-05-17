--------------------------------------------------------------------------------
-- Shell / 启动菜单 / SSH 域
-- 所有「从哪里启动程序」的配置集中于此
--------------------------------------------------------------------------------

local utils = require("config.utils")

local M = {}

function M.apply(config)

    -- ── 默认 Shell ───────────────────────────────────────────────────────────
    -- 优先级：Windows → Pwsh；Unix → Nushell → Zsh → Bash
    if utils.is_windows() then
        config.default_prog = { "pwsh", "--NoLogo" }
    elseif utils.unix_command_exists("nu") then
        config.default_prog = { "nu" }
    elseif utils.unix_command_exists("zsh") then
        config.default_prog = { "zsh", "-i" }
    else
        config.default_prog = { "bash", "-i" }
    end

    -- ── 启动菜单（Leader + p 唤出）────────────────────────────────────────────
    -- 按平台分组：Shell → WSL → SSH
    config.launch_menu = {
        -- Shell
        { label = "Nushell",        args = { "nu"                           } },
        { label = "Zsh",            args = { "zsh",           "-l"          } },
        { label = "Bash",           args = { "bash",          "-l"          } },
        { label = "Pwsh",           args = { "pwsh.exe",      "--NoLogo"    } },
        { label = "PowerShell",     args = { "powershell.exe","--NoLogo"    } },

        -- WSL 发行版
        { label = "WSL: Fedora",    args = { "wsl.exe", "-d", "fedora"     } },

        -- SSH 快捷项（也可在 SSH Domains 中配置并用 Leader+o 连接）
        { label = "SSH: linuxbrew", args = { "ssh", "linuxbrew@122.207.79.209" } },
        { label = "SSH: software",  args = { "ssh", "software@122.207.79.209"  } },
    }

    -- ── SSH 域（Leader + o 唤出，支持 WezTerm 原生 SSH 多路复用）────────────
    -- 优势：WezTerm 接管 SSH 连接后可共享本地 GPU 渲染，支持远程标签页
    config.ssh_domains = {
        {
            name           = "mint",
            remote_address = "122.207.79.207:22",
            username       = "mint",
            -- 如需指定私钥，取消注释：
            -- ssh_option = { identityfile = "~/.ssh/id_rsa" },
        },
        {
            name           = "linuxbrew",
            remote_address = "122.207.79.207:22",
            username       = "linuxbrew",
        },
        {
            name           = "software",
            remote_address = "122.207.79.207:22",
            username       = "software",
        },
    }
end

return M
