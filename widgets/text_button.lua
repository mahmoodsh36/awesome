local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")

local text_button = wibox.widget.textbox

function text_button:new(text, onclick)
    local widget = text_button()
    widget:buttons(gears.table.join(
        awful.button({}, 1, nil, function()
            onclick()
        end)
    ))
    widget.markup = '<span foreground="white">' .. text .. '</span>'
    widget.color = 'white'
    widget.stored_text = text
    widget:connect_signal('mouse::enter', function(w)
        w.markup = '<span foreground="grey">' .. w.stored_text .. '</span>'
        w.color = 'grey'
    end)
    widget:connect_signal('mouse::leave', function(w)
        w.markup = '<span foreground="white">' .. w.stored_text .. '</span>'
        w.color = 'white'
    end)
    return widget
end

function text_button:change_text(text)
    self.stored_text = text
    self.markup = '<span foreground="' .. self.color .. '">' .. text .. '</span>'
end

return text_button
