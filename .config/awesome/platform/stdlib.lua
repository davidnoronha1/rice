local Gtk = require('lgi').require('Gtk', '3.0')
local Gio = require('lgi').Gio
local M = {}

-- vim: set fdm=marker :

function M.ellipsize(str, n)
	if #str > (n or 32) then
		return str:sub(0, n)
	else
		return str
	end
end

-- Cursed Shadow Box {{{
M.shadow_box = {}
function M.shadow_box.new(widget, size, offset, bg)
	return wibox.widget({
		layout = wibox.layout.fixed.horizontal,
		{
			-- Main Content
			{
				{
					widget,
					widget = wibox.container.margin,
					margins = dpi(6),
				},
				widget = wibox.container.background,
				shape = gears.shape.rectangle,
				shape_border_width = dpi(3),
				bg = bg,
				shape_border_color = beautiful.bg_shadow,
			},
			-- Bottom Horizontal Separator
			{
				{
					widget = wibox.widget.separator,
					color = beautiful.bg_shadow,
					orientation = 'horizontal',
					id = 'b_h_sep',
					thickness = 8,
					forced_width = dpi(1),
					forced_height = dpi(size or 6),
					border_width = 0,
				},
				widget = wibox.container.margin,
				left = dpi(offset or 4),
			},
			layout = wibox.layout.fixed.vertical,
		},
		{
			-- Right Vertical Separator
			{
				widget = wibox.widget.separator,
				color = beautiful.bg_shadow,
				orientation = 'vertical',
				thickness = 8,
				id = 'r_v_sep',
				forced_width = dpi(size or 6),
				forced_height = dpi(1),
				border_width = 0,
			},
			widget = wibox.container.margin,
			top = dpi(offset or 4),
		},
	})
end

function M.shadow_box.is_active(w)
	return w:get_children_by_id('b_h_sep')[1].color == beautiful.bg_shadow
end

function M.shadow_box.off(w)
	w:get_children_by_id('b_h_sep')[1].color = '#00000000'
	w:get_children_by_id('r_v_sep')[1].color = '#00000000'
end

function M.shadow_box.on(w)
	w:get_children_by_id('b_h_sep')[1].color = beautiful.bg_shadow
	w:get_children_by_id('r_v_sep')[1].color = beautiful.bg_shadow
end

function M.shadow_box.toggle(w)
	local a = w:get_children_by_id('b_h_sep')[1]
	a.color = a.color == beautiful.bg_shadow and '#00000000' or beautiful.bg_shadow

	local b = w:get_children_by_id('r_v_sep')[1]
	b.color = b.color == beautiful.bg_shadow and '#00000000' or beautiful.bg_shadow
end

-- }}}

function M.gtk_lookup_icon(icon_name, size)
	local theme = Gtk.IconTheme.get_default()
	return theme:lookup_icon(icon_name, size or 24, {}):get_filename()
end
-- Table Manipulation

function M.contains(_table, value)
	for _, item in ipairs(_table) do
		if value == item then
			return true
		end
	end
	return false
end

-- Text & Color

M.color = require('platform.libs.bling.helpers.color')
function M.color.colorify(color, txt)
	return '<span color="' .. (color or '#ff0000') .. '">' .. txt .. '</span>'
end

function M.color.rgba(r, g, b, a)
	return string.format('#%02x%02x%02x%x', r, g, b, math.ceil(a * 255))
end

function M.title_case(phrase)
	local result = string.gsub(phrase, "(%a)([%w_']*)", function(first, rest)
		return first:upper() .. rest:lower()
	end)
	return result
end

function M.trim(s)
	return s:match('^%s*(.-)%s*$')
end

-- Layout

function M.force_left(x)
	return wibox.widget({
		x,
		widget = wibox.container.place,
		halign = 'left',
	})
end

function M.force_center(x)
	return wibox.widget({
		x,
		widget = wibox.container.place,
		halign = 'center',
		valign = 'center',
	})
end

function M.force_right(x)
	return wibox.widget({
		x,
		widget = wibox.container.place,
		halign = 'right',
	})
end

-- Helper Widgets

function M.txt_button(text, fn, hovertxt)
	local w = wibox.widget({
		{
			{
				widget = wibox.widget.textbox,
				font = beautiful.font .. ' 24',
				markup = text,
				buttons = {
					awful.button({}, mouse.LEFT, fn),
				},
			},
			widget = wibox.container.margin,
			left = 32,
			right = 32,
			top = 16,
			bottom = 16,
		},
		widget = wibox.container.background,
	})

	if hovertxt ~= nil then
		awful.tooltip({
			objects = { w },
			text = hovertxt,
		})
	end

	-- TODO: Change mouse cursor on hover
	w:connect_signal('mouse::enter', function()
		w.bg = 'skyblue'
		w.fg = 'white'
	end)

	w:connect_signal('mouse::leave', function()
		w.bg = nil
		w.fg = nil
	end)

	M.pointer(w)

	return w
end

function M.contain_image(i, w, h, opt)
	return wibox.widget({
		gears.table.crush({
			resize = true,
			widget = wibox.widget.imagebox,
			image = i,
		}, opt or {}),
		widget = wibox.container.constraint,
		width = w or 200,
		height = h or w or 200,
	})
end

function M.add_buttons(wdgt, btns)
	wdgt.buttons = btns or {}

	return wdgt
end

local cairo = require('lgi').cairo
function M.color.monochrome_image(image)
	local surface = require('gears').surface.duplicate_surface(image)
	local cr = cairo.Context.create(surface)
	local patt = cairo.Pattern.create_for_surface(surface)
	cr:set_source_rgb(0, 0, 0)
	cr:set_operator(cairo.Operator.HSL_SATURATION)
	cr:mask(patt)
	return surface
end

function M.color.hexa(str, alpha)
	return str .. string.format('%02x', math.floor(alpha) * 255)
end

-- Misc

function M.pointer(w)
	w:connect_signal('mouse::enter', function()
		local wibox = mouse.object_under_pointer()
		if wibox ~= nil then
			wibox.cursor = 'hand2'
		end
	end)

	w:connect_signal('mouse::leave', function()
		local wibox = mouse.object_under_pointer()
		if wibox ~= nil then
			wibox.cursor = 'left_ptr'
		end
	end)

	return w
end

-- Popup that exits once you click somewhere else {{{
function M.only_popup(popup, e, dont_keygrab, bindings)
	e = e or true
	if not e then
		return
	end
	popup.visible = true

	local keygrab = nil
	if not dont_keygrab then
		keygrab = awful.keygrabber({
			stop_key = 'Escape',
			keybindings = bindings,
			stop_event = 'press',
			stop_callback = function()
				popup.visible = false
				if mousegrabber.isrunning() then
					mousegrabber.stop()
				end
			end,
		})
		keygrab:start()
	end

	popup:connect_signal('property::visible', function()
		if not popup.visible then
			if not dont_keygrab then
				keygrab:stop()
			end
			if mousegrabber.isrunning() then
				mousegrabber.stop()
			end
		end
	end)

	local function start_mgrabber()
		mousegrabber.run(function(m)
			if mouse.current_wibox and mouse.current_wibox == popup then
				return false
			end

			if (m.buttons[1] or m.buttons[3]) and mouse.current_wibox ~= popup then
				popup.visible = false
				if not dont_keygrab then
					keygrab:stop()
				end
				return false
			end
			return true
		end, 'left_ptr')
	end

	popup:connect_signal('mouse::leave', function()
		if mousegrabber.isrunning() then
			mousegrabber.stop()
		end

		start_mgrabber()
	end)

	popup:connect_signal('mouse::enter', function()
		if mousegrabber.isrunning() then
			mousegrabber.stop()
		end
	end)

	if mouse.current_wibox ~= popup then
		start_mgrabber()
	end
end
-- }}}

-- Courtesy of no37
function M.hexagon_shape(cr, width, height)
	temp = 0
	if width > height then
		temp = height
	else
		temp = width
	end
	cr:move_to(temp / 2, 0)
	cr:line_to(temp, temp * 3 / 11)
	cr:line_to(temp, temp * 8 / 11)
	cr:line_to(temp / 2, temp)
	cr:line_to(0, temp * 8 / 11)
	cr:line_to(0, temp * 3 / 11)
	cr:close_path()
end

function M.formatter(format)
	return function(s)
		return '<span ' .. format .. '>' .. s .. '</span>'
	end
end

-- Tricky little bit of work to make things work
function M.rounded(r, w, h)
	r = r or 8
	if not w then
		return function(cr, w, h)
			gears.shape.rounded_rect(cr, w, h, r)
		end
	else
		gears.shape.rounded_rect(r, w, h, 8)
	end
end

function M.round_meter(color, icon)
	return wibox.widget({
		{
			widget = wibox.widget.textbox,
			text = icon,
			font = beautiful.font,
			align = "center",
			forced_width = dpi(60),
			forced_height = dpi(60),
		},
		border_color = "#45403d",
		max_value = 100, -- DONT CHANGE
		min_value = 0,
		border_width = dpi(6),
		color = color,
		widget = wibox.container.radialprogressbar,
	})
end

return M
