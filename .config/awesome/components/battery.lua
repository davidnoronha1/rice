local battery_w = require('platform.libs.battery')

-- require('naughty').notify({
	-- text = require('platform.libs.inspect')(battery_w.list_devices()),
-- })

local battery_widget = battery_w({
	device_path = battery_w.list_devices()[1],
})

local battery_state_icons = {}
battery_state_icons[1] = '󰂇 '
battery_state_icons[2] = '󰁿 '
battery_state_icons[3] = '󰂎 '
battery_state_icons[4] = '󰂅 '
battery_state_icons[5] = '󰚥 '

local last_percentage = 0

battery_widget:connect_signal('upower::update', function(w, device)
	local is_on_battery = device.kind == 2
	if last_percentage == math.floor(0.5 + device.percentage) then
		return
	else
		last_percentage = math.floor(0.5 + device.percentage)
	end
	require('components.splashmsg')({
		{
			{
				widget = wibox.widget.textbox,
				font = beautiful.font,
				text = is_on_battery and (battery_state_icons[device.state] or tostring(device.state)) or '󰚥 ',
				align = 'center',
			},
			-- { widget = wibox.widget.textbox, text = device.power_supply and 'YES' or 'NO' },
			{
				{
					widget = wibox.widget.progressbar,
					max_value = 100,
					color = beautiful.theme.black,
					background_color = require('platform.stdlib').color.darken('#f0f0f0', 64),
					value = device.percentage,
					shape = require('platform.stdlib').rounded,
				},
				forced_height = 20,
				forced_width = 280,
				widget = wibox.container.place,
			},
			{
				widget = wibox.widget.textbox,
				text = device.percentage .. '%',
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
