local slider_controlled_widget = require("widgets/slider_controlled_widget")
local awful = require("awful")

bluetooth_volume_widget = slider_controlled_widget:new('🔵🦷 ')

bluetooth_volume_widget.on_slider_input = function(value)
    awful.spawn('sh -c "~/workspace/scripts/control_bluetooth_volume.sh ' .. tostring(value) .. '%"')
end

bluetooth_volume_widget.on_update = function(value)
    os.execute('sh -c "~/workspace/scripts/control_bluetooth_volume.sh ' .. tostring(value) .. '%"')
end

--function volume_widget.update()
--    awful.spawn.easy_async(
--        --{"sh", "-c", "amixer get Master | awk 'END {print $4}' | tr -d '[]%'"},
--        {"sh", "-c", "~/workspace/scripts/control_volume.sh | tr -d '%'"},
--        function(out)
--            local percentage = tonumber(out)
--            volume_widget.widget.slider.value = percentage
--            volume_widget.widget.icon_textbox.text = '🔊 '
--            volume_widget.widget.percentage_textbox.text = ' ' .. tostring(percentage) .. '%'
--        end
--    )
--end

return bluetooth_volume_widget
