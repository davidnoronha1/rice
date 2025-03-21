local wezterm = require 'wezterm'
local config = wezterm.config_builder()

wezterm.on("update-right-status", function(window, pane)
    local cwd = pane:get_foreground_process_name() or ""
    local is_vim = cwd:match("vim$") or cwd:match("nvim$")

    window:set_config_overrides({
        enable_scroll_bar = not is_vim
    })
end)

-- Colorscheme
-- Monokai Pro Spectrum
config.colors = {
	foreground = "#F7F1FF",
	background = "#222222",
	cursor_bg = "#F7F1FF",
	cursor_border = "#F7F1FF",
	cursor_fg = "#222222",
	selection_bg = "#F7F1FF",
	selection_fg = "#222222",
	scrollbar_thumb = "#444444",

	ansi = {
		"#131313", -- black
		"#FC618D", -- red
		"#7BD88F", -- green
		"#FCE566", -- yellow
		"#948AE3", -- blue
		"#FD9353", -- purple
		"#5AD4E6", -- cyan
		"#FFFFFF", -- white
	},
	brights = {
		"#191919", -- bright black
		"#FC618D", -- bright red
		"#7BD88F", -- bright green
		"#FCE566", -- bright yellow
		"#948AE3", -- bright blue
		"#FD9353", -- bright purple
		"#5AD4E6", -- bright cyan
		"#FFFFFF", -- bright white
	},

	tab_bar = {
		active_tab = {
			-- The color of the background area for the tab
			bg_color = '#222222',
			-- The color of the text for the tab
			fg_color = '#c0c0c0',

			-- Specify whether you want "Half", "Normal" or "Bold" intensity for the
			-- label shown for this tab.
			-- The default is "Normal"
			intensity = 'Normal',

			-- Specify whether you want "None", "Single" or "Double" underline for
			-- label shown for this tab.
			-- The default is "None"
			underline = 'None',

			-- Specify whether you want the text to be italic (true) or not (false)
			-- for this tab.  The default is false.
			italic = false,

			-- Specify whether you want the text to be rendered with strikethrough (true)
			-- or not for this tab.  The default is false.
			strikethrough = false,
		},
	}
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	return tab.active_pane.title -- This removes the numbering
end)

local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
config.automatically_reload_config = true

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

-- Window Frame (2px) & Padding (20px)
config.window_frame = {
	border_left_width = '2px',
	border_right_width = '2px',
	border_bottom_height = '2px',
	border_top_height = '2px',
	border_left_color = '#333333',
	border_right_color = '#333333',
	border_bottom_color = '#333333',
	border_top_color = '#333333',
	font = wezterm.font_with_fallback({ "Recursive Sans Linear Static", "IosevkaTerm Nerd Font" })
}
config.window_padding = {
	left = 20,
	right = 20,
	top = 20,
	bottom = 20,
}

-- Misc Config
config.enable_scroll_bar = true
config.hide_tab_bar_if_only_one_tab = true
-- config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
-- config.integrated_title_button_style = "Gnome"
-- config.use_fancy_tab_bar = false

-- Font
-- config.font = wezterm.font("Liga SFMono Nerd Font")
config.font = wezterm.font("IosevkaTerm Nerd Font")
-- config.font = wezterm.font("Cozette")
config.font_size = 12

-- config.front_end = "WebGpu"

-- Key Bindings
config.keys = {
	-- Split pane vertically (new pane on the right)
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" },
	},

	-- Split pane horizontally (new pane below)
	{
		key = "b",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" },
	},
	{
		key = "t",
		mods = "CTRL",
		action = wezterm.action.SpawnTab "CurrentPaneDomain",
	},
}

return config
