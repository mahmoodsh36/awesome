local slider_controlled_widget = require("widgets/slider_controlled_widget")
local awful = require("awful")

local MAX_BRIGHTNESS = 120000

brightness_widget = slider_controlled_widget:new('BRIGHTNESS ')

brightness_widget.on_slider_input = function(value)
    awful.spawn('sudo sh -c \'echo "' .. tostring(math.floor(value / 100 * MAX_BRIGHTNESS)) .. '" > /sys/class/backlight/intel_backlight/brightness\'')
end

return brightness_widget
