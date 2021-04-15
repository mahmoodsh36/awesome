local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local theme = require('themes/first/theme')

local widget = awful.popup {
    widget = awful.widget.tasklist {
        screen = screen[1],
        filter = awful.widget.tasklist.filter.currenttags,
        -- buttons  = tasklist_buttons,
        style    = {
            shape = gears.shape.rounded_rect,
        },
        layout   = {
            spacing = 2,
            vertical_expand = true,
            layout = wibox.layout.grid.horizontal,
            homogeneous = true,
            forced_num_rows = 2,
        },
        widget_template = {
            {
                {
                    id     = 'clienticon',
                    widget = awful.widget.clienticon,
                },
                margins = 4,
                widget  = wibox.container.margin,
            },
            id              = 'background_role',
            forced_width    = 48,
            forced_height   = 48,
            widget          = wibox.container.background,
            create_callback = function(self, c, index, objects)
                self:get_children_by_id('clienticon')[1].client = c
            end,
        },
    },
    border_color = '#333333',
    border_width = 2,
    placement = awful.placement.centered,
    shape        = gears.shape.rounded_rect,
    visible      = false,
    ontop        = true
}

function widget.show()
    widget.visible = true
    widget.restart_timer()
end

widget.timer = gears.timer {
    timeout     = 1,
    call_now    = false,
    autostart   = true,
    single_shot = true,
    callback = function()
        widget.visible = false
    end
}

function widget.restart_timer()
    widget.timer:again()
end

widget.show()

return widget
