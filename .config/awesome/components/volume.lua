local M = {
	volume = 50,
}

function M.update(volume)
	local sign = '+'
	if volume < 0 then
		sign = '-'
		volume = volume * -1
	end
	awful.spawn.easy_async("amixer sset 'Master' " .. tostring(volume) .. '%' .. sign, function(stdout, stderr, reason)
		local const = tonumber(stdout:match('%[(%d%d%d?)%%]'))
		-- TODO: allow to update OSD if already on screen
		M.volume = const
		awesome.emit_signal('custom::volume_update', M.volume)
		require('components.splashmsg')({
			{
				{
					widget = wibox.widget.textbox,
					font = beautiful.font,
					text = ' ',
					align = 'center',
				},
				{
					{
						widget = wibox.widget.progressbar,
						max_value = 100,
						color = beautiful.palette.black,--'#f0f0f0',
						background_color = require('platform.stdlib').color.darken('#f0f0f0', 64),
						value = const,
						shape = require('platform.stdlib').rounded,
					},
					forced_height = 20,
					forced_width = 280,
					widget = wibox.container.place,
				},
				{
					widget = wibox.widget.textbox,
					text = const .. '%',
					font = beautiful.font,
					align = 'center',
				},
				spacing = 16,
				layout = wibox.layout.fixed.horizontal,
			},
			widget = wibox.container.margin,
			margins = 16,
		})
	end)
end

return M
