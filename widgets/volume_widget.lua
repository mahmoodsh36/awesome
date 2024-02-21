local slider_controlled_widget = require("widgets/slider_controlled_widget")
local awful = require("awful")

volume_widget = slider_controlled_widget:new(' ')

volume_widget.on_slider_input = function(value)
    -- awful.spawn([[sh -c "pactl list sinks | grep Name | cut -d ':' -f2 | cut -c2- | while read sinkindex; do pactl set-sink-volume $sinkindex ]] .. tostring(value) .. [[%; done"]])
  awful.spawn('control_volume.sh ' .. value .. '%')
end

volume_widget.on_update = function(value)
    -- awful.spawn([[sh -c "pactl list sinks | grep Name | cut -d ':' -f2 | cut -c2- | while read sinkindex; do pactl set-sink-volume $sinkindex ]] .. tostring(value) .. [[%; done"]])
  awful.spawn('control_volume.sh ' .. value .. '%')
end

function update()
   awful.spawn.easy_async(
       {"sh", "-c", "control_volume.sh"},
       function(out)
           local percentage = tonumber(out)
           volume_widget.widget.slider.value = percentage
           volume_widget.widget.icon_textbox.text = '🔊 '
           volume_widget.widget.percentage_textbox.text = ' ' .. tostring(percentage) .. '%'
       end
   )
end
-- update()

return volume_widget