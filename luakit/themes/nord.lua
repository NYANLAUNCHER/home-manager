---@diagnostic disable:unused-local
-----------------------
-- Nord luakit theme --
-----------------------
-- See: https://www.nordcom/docs/colors-and-palettes
-- Polar Night
local nord0 = "#2e3440"
local nord1 = "#3b4252"
local nord2 = "#434c5e"
local nord3 = "#4c566a"
-- Snow Storm
local nord4 = "#d8dee9"
local nord5 = "#e5e9f0"
local nord6 = "#eceff4"
-- Frost
local nord7  = "#8fbcbb"
local nord8  = "#88c0d0"
local nord9  = "#81a1c1"
local nord10 = "#5e81ac"
-- Aurora
local nord11 = "#bf616a"
local nord12 = "#d08770"
local nord13 = "#ebcb8b"
local nord14 = "#a3be8c"
local nord15 = "#b48ead"

local hl_statusbar = nord0
local hl_bg = nord1
local hl_fg = nord2
local hl_fg_light = nord3

---@param hex string Hex color formatted like so "#FFFFFF"
---@param a number Alpha value for rgba()
local function rgba(hex, a)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    return string.format("rgba(%d, %d, %d, %.1f)", r, g, b, a)
end


local theme = {}

-- Default settings
theme.font = "12px monospace"
theme.fg   = "#ffffff"
theme.bg   = "#000000"

-- General colours
theme.success_fg = "#00ff00"
theme.loaded_fg  = "#33AADD"
theme.error_fg = "#FFFFFF"
theme.error_bg = "#FF0000"

-- Warning colours
theme.warning_fg = "#FF0000"
theme.warning_bg = "#FFFFFF"

-- Notification colours
theme.notif_fg = "#444444"
theme.notif_bg = "#FFFFFF"

-- Menu colours
theme.menu_fg                   = "#000000"
theme.menu_bg                   = "#ffffff"
theme.menu_selected_fg          = "#000000"
theme.menu_selected_bg          = "#FFFF00"
theme.menu_title_bg             = "#ffffff"
theme.menu_primary_title_fg     = "#ff0000"
theme.menu_secondary_title_fg   = "#666666"

theme.menu_disabled_fg = "#999999"
theme.menu_disabled_bg = theme.menu_bg
theme.menu_enabled_fg = theme.menu_fg
theme.menu_enabled_bg = theme.menu_bg
theme.menu_active_fg = "#006600"
theme.menu_active_bg = theme.menu_bg

-- Proxy manager
theme.proxy_active_menu_fg      = '#000000'
theme.proxy_active_menu_bg      = '#FFFFFF'
theme.proxy_inactive_menu_fg    = '#888888'
theme.proxy_inactive_menu_bg    = '#FFFFFF'

-- Statusbar specific
theme.sbar_fg         = "#ffffff"
theme.sbar_bg         = "#000000"

-- Downloadbar specific
theme.dbar_fg         = "#ffffff"
theme.dbar_bg         = "#000000"
theme.dbar_error_fg   = "#FF0000"

-- Input bar specific
theme.ibar_fg           = "#000000"
theme.ibar_bg           = rgba("#000000", 0)

-- Tab label
theme.tab_fg            = "#888888"
theme.tab_bg            = "#222222"
theme.tab_hover_bg      = "#292929"
theme.tab_ntheme        = "#dddddd"
theme.selected_fg       = "#ffffff"
theme.selected_bg       = "#000000"
theme.selected_ntheme   = "#dddddd"
theme.loading_fg        = "#33AADD"
theme.loading_bg        = "#000000"

theme.selected_private_tab_bg = "#3d295b"
theme.private_tab_bg    = "#22254a"

-- Trusted/untrusted ssl colours
theme.trust_fg          = "#00FF00"
theme.notrust_fg        = "#FF0000"

-- Follow mode hints
theme.hint_font = "10px monospace, courier, sans-serif"
theme.hint_fg = "#ffffff"
theme.hint_bg = "#000088"
theme.hint_border = "1px dashed #000000"
theme.hint_opacity = "0.3"
theme.hint_overlay_bg = "rgba(255,255,153,0.3)"
theme.hint_overlay_border = "1px dotted #000000"
theme.hint_overlay_selected_bg = "rgba(0,255,0,0.3)"
theme.hint_overlay_selected_border = theme.hint_overlay_border

-- General colour pairings
theme.ok = { fg = "#000000", bg = "#FFFFFF" }
theme.warn = { fg = "#FF0000", bg = "#FFFFFF" }
theme.error = { fg = "#FFFFFF", bg = "#FF0000" }

-- Gopher page style (override defaults)
theme.gopher_light = { bg = "#E8E8E8", fg = "#17181C", link = "#03678D" }
theme.gopher_dark  = { bg = "#17181C", fg = "#E8E8E8", link = "#ff9900" }

return theme
