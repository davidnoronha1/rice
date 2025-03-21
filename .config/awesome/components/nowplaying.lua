-- vim: set fdm=marker :
local std = require('platform.stdlib')

local nowPlaying = wibox.widget.textbox()
nowPlaying.font = beautiful.font

local playPause = wibox.widget.textbox()
playPause.font = beautiful.font .. ' 32'
playPause.markup = '<span color="white">⏸</span>'
playPause:buttons(awful.button({}, mouse.LEFT, function()
	playerctl:play_pause()
end))
playPause.visible = false

local playPrev = wibox.widget.textbox()
playPrev.font = beautiful.font .. ' 32'
playPrev.markup = '<span color="white">󰒮</span>'
playPrev:buttons(awful.button({}, mouse.LEFT, function()
	playerctl:previous()
end))
playPrev.visible = false

local playNext = wibox.widget.textbox()
playNext.font = beautiful.font .. ' 32'
playNext.markup = '<span color="white">󰒭</span>'
playNext:buttons(awful.button({}, mouse.LEFT, function()
	playerctl:next()
end))
playNext.visible = false

local albumArt = wibox.widget.imagebox()
albumArt.clip_shape = std.rounded
albumArt.resize = true

local albumArtEffect = wibox.widget({
	widget = wibox.container.background,
	forced_height = 256,
	bg = '#181818',
	opacity = 0,
	shape = std.rounded,
})

local playerLayout = wibox.widget({
	{
		{
			{ albumArt, widget = wibox.container.constraint, height = 256 },
			albumArtEffect,
			{
				{
					layout = wibox.layout.align.horizontal,
					expand = 'none',
					std.pointer(playPrev),
					std.pointer(playPause),
					std.pointer(playNext),
				},
				widget = wibox.container.margin,
				margins = 16,
			},
			layout = wibox.layout.stack,
		},
		nowPlaying,
		spacing = 8,
		layout = wibox.layout.fixed.vertical,
	},
	widget = wibox.container.margin,
	margins = 0,
})

albumArt:connect_signal('mouse::enter', function()
	playPrev.visible = true
	playNext.visible = true
	playPause.visible = true
	albumArtEffect.opacity = 0.4
end)

albumArt:connect_signal('mouse::leave', function()
	playPause.visible = false
	playNext.visible = false
	playPrev.visible = false
	albumArtEffect.opacity = 0
end)

-- {{{
playerctl:connect_signal('metadata', function(_, title, artist, album_path, album)
	local album_str = (album ~= '' and album ~= title) and ' (<i>' .. std.ellipsize(album, 16) .. '</i>)' or ''
	title = std.ellipsize(std.trim(title:gsub('%([^%)]*%)', '')), 26)
	nowPlaying.markup =  '<b>' .. title .. (artist ~= '' and ' by\n' .. artist or '') .. '</b>'
	albumArt.image = album_path
end)

playerctl:connect_signal('playback_status', function(_, playing)
	if not playing then
		playPause.markup = '<span color="white">⏵</span>'
	else
		playPause.markup = '<span color="white">⏸</span>'
	end
end)

-- playerctl:connect_signal('position', function(done, full, player)
-- require('naughty').notify({ text = done / full })
-- end)

nowPlaying:buttons(awful.button({}, mouse.LEFT, function()
	playerctl:play_pause()
end)) -- }}}

require('components.dashboard').register({
	widget = wibox.widget({ playerLayout, widget = wibox.container.margin, margins = 15 }),
	valign = 'bottom',
	halign = 'right',
})
