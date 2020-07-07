local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

function create_volume_popup()
    return awful.popup {
        widget = {
            {
                {
                    text   = 'volume',
                    id     = 'tb',
                    widget = wibox.widget.textbox
                },
                {
                    value         = 0.8,
                    forced_height = 30,
                    forced_width  = 300,
                    id            = 'pb',
                    widget        = wibox.widget.progressbar,
                    color         = '#777777',
                    background_color = '#333333',
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
        ontop        = true,
        hide_on_right_click = true,
}
end

if volume_popup == nil then
   volume_popup = create_volume_popup()
   naughty.notify({text="just created the volume popup"})
end

if popup_timer ~= nil then
   popup_timer:stop()
   volume_popup.hide = false
end

popup_timer = gears.timer {
    timeout     = 5,
    call_now    = true,
    autostart   = true,
    single_shot = true,
    callback = function()
        awful.spawn.easy_async(
            {"sh", "-c", "pactl list sinks | awk '/^\\sVolume:/ {print $5}' | tr -d '%\n'"},
            function(out)
                if volume_popup.hide then
                    volume_popup.visible = false
                    volume_popup.hide = false
                else
                    volume_popup.hide = true
                    local percentage = tonumber(out)
                    volume_popup.widget.w.pb.value = percentage / 100.0
                    volume_popup.widget.w.tb.text =
                        'volume ' .. tostring(percentage) .. '%'
                    volume_popup.visible = true
                end
            end
        )
    end
}
