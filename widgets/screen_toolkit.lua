local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local volume_widget = require("widgets/volume_widget")
local brightness_widget = require("widgets/brightness_widget")
local bluetooth_volume_widget = require("widgets/bluetooth_volume_widget")
local spotify_widget = require("widgets/spotify_widget")
local text_button = require('widgets/text_button')

memory_widget = awful.widget.watch('sh -c "free -h | awk \'/Mem/ {print $3 \\"/\\" $2}\'"', 1,
function(widget, stdout)
    widget.text = 'MEM ' .. stdout
end)

storage_widget = awful.widget.watch([[sh -c "df -h | awk '/\\/$/ {print $3 \"/\" $2}'"]], 1,
function(widget, stdout)
    widget.text = 'STORAGE ' .. stdout
end)


time_widget = awful.widget.watch('date "+%H:%M:%S (%a) %d/%m/%y"', 1,
function(widget, stdout)
    widget.text = stdout
end)

last_tx_bytes = 0
last_rx_bytes = 0
ul_traffic_widget = awful.widget.watch('cat /sys/class/net/wlp0s20f3/statistics/tx_bytes', 1, function(widget, stdout)
    current_tx_bytes = tonumber(stdout)
    widget.text = 'UP ' .. tostring(math.floor((current_tx_bytes - last_tx_bytes) / 1000)) .. 'kb/s'
    last_tx_bytes = current_tx_bytes
end)
dl_traffic_widget = awful.widget.watch('cat /sys/class/net/wlp0s20f3/statistics/rx_bytes', 1, function(widget, stdout)
    current_rx_bytes = tonumber(stdout)
    widget.text = 'DL ' .. tostring(math.floor((current_rx_bytes - last_rx_bytes) / 1000)) .. 'kb/s'
    last_rx_bytes = current_rx_bytes
end)

transmission_widget = awful.widget.watch([[sh -c 'transmission-remote -l | grep -v "Stopped\|Finished\|Sum\|\s*ID" | awk "split(\$8,a,\".\") {print \$2 \" \" a[1] \"kb/s\"}"']], 1, function(widget, stdout)
    widget.text = ' ' .. stdout
end)

eth_widget = awful.widget.watch("get_eth_price.py", 100, function(widget, stdout)
    widget.text = '' .. stdout
end)

btc_widget = awful.widget.watch("get_btc_price.py", 100, function(widget, stdout)
    widget.text = ' ' .. stdout
end)

hoge_widget = awful.widget.watch("get_hoge_price.py", 100, function(widget, stdout)
    widget.text = ' ' .. stdout
end)

doge_widget = awful.widget.watch("get_doge_price.py", 100, function(widget, stdout)
    widget.text = ' ' .. stdout
end)

matic_widget = awful.widget.watch("get_matic_price.py", 100, function(widget, stdout)
    widget.text = ' ' .. stdout
end)

local screen_toolkit = {
}

function screen_toolkit:new(screen)
    obj = awful.popup {
        widget = {
            {
                id = 'first_bar',
                layout = wibox.layout.align.horizontal,
                forced_height = 25,
                {
                    layout = wibox.layout.fixed.horizontal,
                    screen.mytaglist,
                    screen.mypromptbox,
                },
                nil,
                {
                    layout = wibox.layout.fixed.horizontal,
                    create_separator(),
                    volume_widget.widget,
                    create_separator(),
                    wibox.widget.systray(),
                    create_separator(),
                    time_widget,
                }
            },
            {
                id = 'second_bar',
                layout = wibox.layout.align.horizontal,
                forced_height = 25,
                {
                    layout = wibox.layout.fixed.horizontal,
                },
                {
                    layout = wibox.layout.fixed.horizontal,
                    wibox.widget {
                        widget = wibox.widget.imagebox,
                        image = '/home/mahmooz/data/icons/ethereum.png'
                    },
                    eth_widget,
                    create_separator(),
                    wibox.widget {
                        widget = wibox.widget.imagebox,
                        image = '/home/mahmooz/data/icons/bitcoin.png'
                    },
                    btc_widget,
                    create_separator(),
                    wibox.widget {
                        widget = wibox.widget.imagebox,
                        image = '/home/mahmooz/data/icons/hoge.png'
                    },
                    hoge_widget,
                    create_separator(),
                    wibox.widget {
                        widget = wibox.widget.imagebox,
                        image = '/home/mahmooz/data/icons/doge.png'
                    },
                    doge_widget,
                    create_separator(),
                    wibox.widget {
                        widget = wibox.widget.imagebox,
                        image = '/home/mahmooz/data/icons/matic.png'
                    },
                    matic_widget,
                },
                {
                    layout = wibox.layout.fixed.horizontal,
                    wibox.widget {
                        widget = wibox.widget.imagebox,
                        image = '/home/mahmooz/data/icons/transmission.png'
                    },
                    transmission_widget,
                    create_separator(),
                    ul_traffic_widget,
                    dl_traffic_widget,
                    create_separator(),
                    storage_widget,
                    create_separator(),
                    memory_widget,
                }
            },
            {
                layout = wibox.layout.fixed.horizontal,
                {
                    layout = wibox.layout.fixed.horizontal,
                    spotify_widget,
                },
                {
                    layout = wibox.layout.fixed.horizontal,
                },
                {
                    layout = wibox.layout.fixed.vertical,
                    {
                        layout = wibox.layout.fixed.horizontal,
                        forced_height = 25,
                        brightness_widget.widget,
                        create_separator(),
                        bluetooth_volume_widget.widget,
                    },
                    {
                        layout = wibox.layout.fixed.horizontal,
                        forced_height = 25,
                        screen.windowslist,
                    }
                }
            },
            id = 'widget',
            layout = wibox.layout.fixed.vertical,
            forced_height = 1080,
            forced_width = 1920,
        },
        visible = true,
        ontop = false,
        placement = awful.placement.top_left,
    }
    obj.screen = screen
end

return screen_toolkit
