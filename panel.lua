local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local theme = require('themes/first/theme')

function create_panel()
    return awful.popup {
        widget = {
            widget = wibox.container.margin,
            margins = 10,
            {
                layout = wibox.layout.fixed.vertical,
                {
                    widget = wibox.widget.textbox,
                    text = 'control panel',
                    font = beautiful.font
                },
                {
                    widget = wibox.widget.textbox,
                    text = 'Gone Away',
                    font = beautiful.font
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
                }
            }
        },
        placement = function(c)
            awful.placement.left(c)
        end,
        shape = gears.shape.rounded_rect,
        visible = true,
        ontop = true
    }
end

panel = create_panel()

return panel
