local awful = require("awful")
local wibox = require("wibox")
local theme = require('themes/first/theme')
local gears = require("gears")

layouts = { "us", "il", "ar" }

function create()
    local popup = awful.popup {
        widget = {
            widget = wibox.container.margin,
            margins = 3,
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = 5,
                id = 'layout_widget',
            }
        },
        bg = "#643e46",
        shape = gears.shape.rounded_rect,
        visible = false,
        ontop   = true,
        placement = awful.placement.centered,
    }
    for _, layout in ipairs(layouts) do
        widget = wibox.widget {
            widget = wibox.container.background,
            shape = gears.shape.rounded_rect,
            shape_border_width = 5,
            forced_height = 50,
            forced_width = 90,
            bg = "#643e46",
            {
                text   = layout,
                widget = wibox.widget.textbox,
                align  = 'center',
                font   = 'Fantasque Sans Mono 20',
                id     = 'tb',
            },
        }
        popup.widget.layout_widget:add(widget)
    end
    return popup
end

local keyboard_widget = create()

function keyboard_widget.show()
    awful.spawn.easy_async(
        {"sh", "-c", "setxkbmap -query | awk '/layout/ {print $2}'"},
        function(out)
            layout = string.gsub(out, '\n', '')
            for _, widget in ipairs(keyboard_widget.widget.layout_widget.children) do
                if widget.tb.text == layout then
                    widget.bg = '#335711'
                else
                    widget.bg = "#643e46"
                end
            end
            keyboard_widget.visible = true
        end
    )
end

keyboard_widget.timer = gears.timer {
    timeout = 1,
    call_now = false,
    autostart = true,
    single_shot = true,
    callback = function()
        keyboard_widget.visible = false
    end
}

function keyboard_widget.restart_timer()
    keyboard_widget.timer:again()
end

function keyboard_widget.switch_layout()
    awful.spawn.easy_async(
        {"sh", "-c", "setxkbmap -query | awk '/layout/ {print $2}'"},
        function(out)
            layout = string.gsub(out, '\n', '')
            current_layout_idx = 0
            max_layout_idx = 0
            for idx, widget in ipairs(keyboard_widget.widget.layout_widget.children) do
                if widget.tb.text == layout then
                    current_layout_idx = idx
                end
                if idx > max_layout_idx then
                    max_layout_idx = idx
                end
            end
            new_layout_idx = current_layout_idx + 1
            if current_layout_idx == max_layout_idx then
                new_layout_idx = 1
            end
            os.execute("setxkbmap " .. layouts[new_layout_idx])
            keyboard_widget.show()
            keyboard_widget.restart_timer()
        end
    )
end

--keyboard_widget.switch_layout()

return keyboard_widget
