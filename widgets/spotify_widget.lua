local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

local text_button = require('widgets/text_button')

next_button = text_button:new('', function()
    awful.spawn('playerctl next')
end)
next_button.font = 'Fantasque Sans Mono 25'

prev_button = text_button:new('', function()
    awful.spawn('playerctl previous')
end)
prev_button.font = 'Fantasque Sans Mono 25'

play_pause_button = text_button:new('', function()
    if play_pause_button.stored_text == '' then -- paused - play
        awful.spawn('playerctl play')
        play_pause_button:change_text('') 
    else -- playing - pause
        awful.spawn('playerctl pause')
        play_pause_button:change_text('') 
    end
end)
play_pause_button.font = 'Fantasque Sans Mono 25'

name_button = text_button:new('song name here', function()
    awful.spawn('spotify_lyrics.sh')
end)
name_button.font = 'Fantasque Sans Mono 17'

local spotify_widget = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    {
        id = 'cover_imagebox',
        widget = wibox.widget.imagebox,
        image = '/home/mahmooz/clairo.png',
        forced_width = 500,
        forced_height = 500,
    },
    {
        widget = wibox.container.margin,
        top = 5,
        {
            widget = wibox.container.place,
            halign = 'center',
            name_button,
        }
    },
    {
        widget = wibox.container.margin,
        left = 150,
        right = 150,
        top = 5,
        {
            layout = wibox.layout.align.horizontal,
            prev_button,
            {
                widget = wibox.container.place,
                play_pause_button,
                halign = 'center',
            },
            next_button,
        }
    },
}

cover_url = ''
function spotify_widget.refresh()
    awful.spawn.easy_async(
        {'current_spotify_song.sh'},
        function(out)
            name_button:change_text(string.gsub(out,"\n",""))
            awful.spawn.easy_async(
                {'sh', '-c', [[
                    dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus' | tail -1 | sed 's/^.* "//' | tr -d '"'
                ]]},
                function(out)
                    out = string.gsub(out, "\n", "")
                    if out == 'Paused' then
                        play_pause_button:change_text('')
                    else
                        play_pause_button:change_text('')
                    end
                end
            )
            awful.spawn.easy_async(
                {'sh', '-c', [[
                    dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep artUrl -A1 | tail -1 | sed 's/^.* "//' | tr -d '"'
                ]]},
                function(out)
                    out = out:gsub('\n', '')
                    out = out:gsub('https://open.spotify.com/image/',
                                   'https://i.scdn.co/image/')
                    if out ~= current_url then
                        current_url = out
                        awful.spawn.easy_async(
                            {'curl', '-o', '/tmp/cover.png', current_url},
                            function(out)
                                if gears.filesystem.file_readable('/tmp/cover.png') then
                                    spotify_widget:get_children_by_id('cover_imagebox')[1].image = gears.surface.load_uncached("/tmp/cover.png")
                                end
                            end
                        )
                    end
                end
            )
        end
    )
end

refresh_timer = gears.timer {
    timeout     = 0.35,
    call_now    = true,
    autostart   = true,
    single_shot = false,
    callback = function()
        spotify_widget.refresh()
    end
}

return spotify_widget
