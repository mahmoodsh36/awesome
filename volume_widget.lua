local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local theme = require('themes/first/theme')

local volume_widget = wibox.widget {
    {
        text   = 'volume icon here',
        id     = 'icon_textbox',
        widget = wibox.widget.textbox,
        font   = theme.font,
    },
    {
        bar_shape           = gears.shape.rounded_rect,
        bar_height          = 3,
        bar_color           = '#333333',
        bar_active_color    = '#00ff00',
        handle_color        = '#777777',
        handle_shape        = gears.shape.circle,
        handle_border_color = beautiful.border_color,
        handle_border_width = 1,
        forced_height       = 30,
        forced_width        = 150,
        value               = 25,
        widget              = wibox.widget.slider,
        id                  = 'slider'
    },
    {
        text   = 'volume percentage here',
        id     = 'percentage_textbox',
        widget = wibox.widget.textbox,
        font   = theme.font,
    },
    layout = wibox.layout.fixed.horizontal,
}

function volume_widget.update()
    awful.spawn.easy_async(
        {"sh", "-c", "amixer get Master | awk 'END {print $5}' | tr -d '[]%'"},
        function(out)
            local percentage = tonumber(out)
            volume_widget.slider.value = percentage
            volume_widget.icon_textbox.text = '🔊 '
            volume_widget.percentage_textbox.text = ' ' .. tostring(percentage) .. '%'
        end
    )
end

function volume_widget.increase_volume(val)
    os.execute('amixer set Master ' .. tostring(val) .. '%+')
    volume_widget.update()
end

function volume_widget.decrease_volume(val)
    os.execute('amixer set Master ' .. tostring(val) .. '%-')
    volume_widget.update()
end

volume_widget.slider:connect_signal('property::value', function(slider)
    awful.spawn('amixer set Master ' .. tostring(slider.value) .. '%')
    volume_widget.percentage_textbox.text = ' ' .. tostring(slider.value) .. '%'
end)


volume_widget.update()

return volume_widget
