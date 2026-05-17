--------------------------------------------------------------------------------
-- 背景图片配置
-- 支持固定图片和随机轮换，默认禁用（在 wezterm.lua 中注释掉了此模块）
-- 使用方式：将图片放入 images/ 目录，在 wezterm.lua 取消注释即可
--------------------------------------------------------------------------------

local wezterm   = require("wezterm")
local constants = require("config.constants")

local M = {}

-- ── 用户可调选项 ─────────────────────────────────────────────────────────────
local options = {
    -- 是否启用背景图片
    enabled = true,
    -- true = 从 image_dir 随机选图；false = 使用 fixed_image
    random = false,
    -- random = false 时使用的固定图片文件名（相对于 image_dir）
    fixed_image = "01.jpg",
    -- 随机模式下切换间隔（分钟）
    interval_minutes = 30,
    -- 图片目录
    image_dir = constants.CONFIG_DIR .. "/images",
    -- 图片亮度 / 色调 / 饱和度调整（值越低越暗，适合作为背景）
    image_hsb = {
        brightness = 0.08,
        hue        = 1.0,
        saturation = 1.0,
    },
}

-- ── 内部状态 ─────────────────────────────────────────────────────────────────
local image_pool       = nil
local last_switch_time = 0
local last_image       = nil

local function is_image_file(path)
    local lower = path:lower()
    return lower:match("%.png$")
        or lower:match("%.jpg$")
        or lower:match("%.jpeg$")
        or lower:match("%.webp$")
        or lower:match("%.gif$")
end

local function load_images()
    if image_pool and #image_pool > 0 then return image_pool end
    local ok, entries = pcall(wezterm.read_dir, options.image_dir)
    if not ok or not entries then
        wezterm.log_warn("背景图片目录读取失败: " .. options.image_dir)
        return {}
    end
    image_pool = {}
    for _, entry in ipairs(entries) do
        if is_image_file(entry) then
            table.insert(image_pool, entry)
        end
    end
    return image_pool
end

local function resolve_fixed()
    if not options.fixed_image or options.fixed_image == "" then return nil end
    return options.image_dir .. "/" .. options.fixed_image
end

local function pick_image()
    if not options.enabled then return nil end
    if not options.random  then return resolve_fixed() end
    local images = load_images()
    if #images == 0 then return last_image or resolve_fixed() end
    return images[math.random(#images)]
end

local function apply_image(window, image)
    if not image then return end
    last_image = image
    local overrides = window:get_config_overrides() or {}
    overrides.window_background_image     = image
    overrides.window_background_image_hsb = options.image_hsb
    window:set_config_overrides(overrides)
end

function M.apply(config)
    if not options.enabled then return end

    local initial = pick_image()
    if initial then
        config.window_background_image     = initial
        config.window_background_image_hsb = options.image_hsb
        -- 启用背景图片时建议在 appearance.lua 将 opacity 调低至 0.85 左右
    end

    -- 随机模式：通过 update-status 事件定时切换
    if options.random then
        config.status_update_interval = options.interval_minutes * 60 * 1000

        wezterm.on("update-status", function(window, _pane)
            local now = os.time()
            if now - last_switch_time < options.interval_minutes * 60 then return end
            last_switch_time = now
            apply_image(window, pick_image())
        end)
    end
end

return M
