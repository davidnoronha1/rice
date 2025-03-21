-- -*- eval: (rainbow-mode 1); -*-

local color = require('platform.stdlib').color
local dpi = require('beautiful.xresources').apply_dpi
local themes_path = _config_dir .. 'theme/'
local std = require('platform.stdlib')
local bling_helpers = require('platform.libs.bling.helpers')
local rice_path = require('os').getenv('HOME') .. '/rice'

local theme = {}

-- Colors
theme.palette = {
	black = '#2a2428',
	white = '#f9efee',
	red = '#a77668',
	blue = '#4b5c76',
	bright_blue = std.color.rgba(100, 210, 255, 1),
	gold = '#e3bf9f'
}

theme.bg_normal = '#ff0000'
theme.bg_shadow = '#111111'
theme.fg_normal = '#181818'
theme.bg_light = '#fafafa'
theme.bg_wall = '#f7f3e8'
theme.fg_grey = '#b0b0b0'
theme.transparent = std.color.rgba(255, 0, 0, 0)

theme.dashboard_bg = std.color.hexa(std.color.lighten('#ffefd5', 16), 0.68)
theme.titlebar_bg_focus = '#f3b3b4'
theme.titlebar_bg = '#c7a8a1'
-- theme.titlebar_bg = 'transparent'
-- theme.titlebar_bg_focus = 'transparent'
theme.hotkeys_bg = theme.bg_shadow
theme.hotkeys_fg = theme.bg_ligh
theme.wibar_bg = '#fbe7e8' -- #FFEFD5'
theme.wibar_fg = bling_helpers.color.darken(theme.wibar_bg, 64)
theme.bg_systray = theme.wibar_bg
theme.tasklist_bg_normal = theme.wibar_bg
theme.tasklist_plain_task_name = true
theme.menubar_bg_normal = theme.wibar_bg
theme.menubar_fg_normal = '#fafafa'

theme.titlebar_position = 'top'
-- theme.menu_bg = '#262322'
-- theme.menu_section_bg = '#859e82'

theme.playerctl_position_update_interval = 2

theme.prompt_bg = theme.fg_normal
theme.prompt_fg = theme.bg_light
theme.prompt_bg_cursor = theme.bg_gray

-- Tasklist Status Icons
theme.tasklist_maximized = ' &lt;<b>M</b>&gt; '

-- Other
theme.useless_gap = dpi(8)
theme.gap_single_client = false
theme.systray_icon_spacing = dpi(8)
theme.font = 'Recursive Sans Linear Static'
theme.workspaces = { 'I', 'II', 'III', 'IV', 'V' }

theme.separator_color = '#2a2a2a'

-- Settings
theme.terminal = rice_path .. '/scripts/i3-sensible-terminal'
theme.tabbar_disable = true
theme.on_startup = {
	'sh ' .. rice_path .. '/scripts/master.sh startup',
	'picom -b -c -C',
	'xrdb -load ' .. rice_path .. '/Xresources',
	'nm-applet',
}

-- Notifications
theme.notification_spacing = dpi(16)
theme.notification_fg = '#f0f0f0'
theme.notification_bg = '#111111'
theme.notification_icon_size = 64
theme.notification_position = 'bottom_right'

-- Window Snapping
theme.snap_bg = beautiful.fg_inactive
theme.snap_border_width = dpi(10)
theme.snap_shape = gears.shape.rectangle

local assets = themes_path .. 'assets/'

-- Layout Icons
theme.layout_floating = assets .. 'layouts/floating.png'
theme.layout_tile = assets .. 'layouts/tile.png'
theme.layout_dwindle = assets .. 'layouts/dwindle.png'

theme.titlebar_close_button_normal = assets .. 'icons/close.svg'
theme.titlebar_close_button_focus = assets .. 'icons/close-f.svg'

theme.titlebar_maximized_button_focus = assets .. 'icons/max.svg'
theme.titlebar_maximized_button_normal = assets .. 'icons/max-f.svg'

theme.wallpaper = rice_path .. '/wallpapers/' .. 'girlsitting.png'

theme.icon_theme = 'Adwaita++ Dark'

return theme
