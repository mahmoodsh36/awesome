local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local theme = require('themes/first/theme')

local MAX_BRIGHTNESS = 120000

local widget = wibox.widget {
    {
        text   = 'icon here',
        id     = 'icon_textbox',
        widget = wibox.widget.textbox,
        font   = theme.font,
    },
    {
        bar_shape           = gears.shape.rounded_rect,
        bar_height          = 3,
        bar_color           = '#777777',
        bar_active_color    = '#00ff00',
        handle_color        = '#cccccc',
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
        text   = 'percentage here',
        id     = 'percentage_textbox',
        widget = wibox.widget.textbox,
        font   = theme.font,
    },
    layout = wibox.layout.fixed.horizontal,
}

function widget.update()
    awful.spawn.easy_async(
        {"sh", "-c", "cat /sys/class/backlight/intel_backlight/brightness"},
        function(out)
            local brightness = tonumber(out)
            percentage = math.floor(brightness / MAX_BRIGHTNESS * 100)
            widget.slider.value = percentage
            widget.icon_textbox.text = '🌞 '
            widget.percentage_textbox.text = ' ' .. tostring(percentage) .. '%'
        end
    )
end

function widget.increase(percentage)
    os.execute('change_brightness.sh ' .. tostring(percentage))
    widget.update()
end

function widget.decrease(percentage)
    os.execute('change_brightness.sh -' .. tostring(percentage))
    widget.update()
end

widget.slider:connect_signal('property::value', function(slider)
    print(math.floor(slider.value / 100 * MAX_BRIGHTNESS))
    awful.spawn('sudo sh -c \'echo "' .. tostring(math.floor(slider.value / 100 * MAX_BRIGHTNESS)) .. '" > /sys/class/backlight/intel_backlight/brightness\'')
    widget.percentage_textbox.text = ' ' .. tostring(slider.value) .. '%'
end)


widget.update()

return widget
