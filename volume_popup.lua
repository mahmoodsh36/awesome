local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local theme = require('themes/first/theme')

function create_volume_popup()
    return awful.popup {
        widget = {
            {
                {
                    text   = 'volume',
                    id     = 'tb',
                    widget = wibox.widget.textbox,
                    font   = theme.font
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
                    forced_height = 30,
                    forced_width = 300,
                    value               = 25,
                    widget              = wibox.widget.slider,
                    id                  = 's'
                },
                id = 'w',
                layout = wibox.layout.fixed.vertical,
            },
            margins = 10,
            widget  = wibox.container.margin
        },
        border_color = '#333333',
        border_width = 2,
        placement    = function(c)
            awful.placement.top_right(c)
            awful.placement.no_offscreen(c, {honor_workarea=true, margins=40})
        end,
        shape        = gears.shape.rounded_rect,
        visible      = false,
        ontop        = true
}
end

local volume_popup = create_volume_popup()

function volume_popup.show()
    awful.spawn.easy_async(
        {"sh", "-c", "amixer get Master | awk 'END {print $4}' | tr -d '[]%'"},
        function(out)
            local percentage = tonumber(out)
            local slider = volume_popup.widget.w.s
            slider.value = percentage
            volume_popup.widget.w.tb.text = '🔊 volume ' .. tostring(percentage) .. '%'
            volume_popup.visible = true
        end
    )
end

volume_popup.timer = gears.timer {
    timeout     = 5,
    call_now    = false,
    autostart   = true,
    single_shot = true,
    callback = function()
        volume_popup.visible = false
    end
}

function volume_popup.restart_timer()
    volume_popup.timer:again()
end

volume_popup.widget.w.s:connect_signal('property::value', function(slider)
    volume_popup.restart_timer()
    awful.spawn('amixer set Master ' .. tostring(slider.value) .. '%')
    volume_popup.widget.w.tb.text = 
        '🔊 volume ' .. tostring(slider.value) .. '%'
end)

return volume_popup
