local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local theme = require('themes/first/theme')

local slider_controlled_widget = {
    widget = nil,
    on_slider_input = function(value) end,
    on_update = function(value) end,
}

function slider_controlled_widget:set_percentage(value)
    print(value)
    self.widget.percentage_textbox.text = ' ' .. tostring(value) .. '%'
    self.widget.slider.value = value
end

function slider_controlled_widget:get_percentage()
    return self.widget.slider.value
end

function slider_controlled_widget:update(value)
    self.on_update(value)
    self:set_percentage(value)
end

function slider_controlled_widget:update_increase(increase_value)
    new_value = self:get_percentage() + increase_value
    if new_value < 0 then
        new_value = 0
    elseif new_value > 100 then
        new_value = 100
    end
    self:update(new_value)
end

function slider_controlled_widget:new(icon_text)
    obj = {}
    obj.widget = wibox.widget {
        {
            text   = icon_text,
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
            text   = ' 25%',
            id     = 'percentage_textbox',
            widget = wibox.widget.textbox,
            font   = theme.font,
        },
        layout = wibox.layout.fixed.horizontal,
    }
    obj.widget.slider.obj = obj
    obj.widget.slider:connect_signal('property::value', function(slider)
        slider.obj.on_slider_input(slider.value)
        slider.obj:set_percentage(slider.value)
    end)
    setmetatable(obj, self)
    self.__index = self
    return obj
end

return slider_controlled_widget
