local gears = require("gears")
local awful = require("awful")
require("awful.autofocus") -- autofocus windows when switching workspaces and such
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local volume_widget = require("widgets/volume_widget")
local brightness_widget = require("widgets/brightness_widget")
local keyboard_widget = require("widgets/keyboard_widget")
local slider_controlled_widget = require("widgets/slider_controlled_widget")
local text_button = require('widgets/text_button')
--local navigation_widget = require("widgets/navigation_widget")

--awful.spawn('/home/mahmooz/workspace/scripts/startup.sh')

used_theme = "first"
themes_dir = gears.filesystem.get_configuration_dir() .. 'themes/'
editor = os.getenv("EDITOR") or "vim"
modkey = "Mod4"

beautiful.init(themes_dir .. used_theme .. '/theme.lua')

local screen_toolkit = require("widgets/screen_toolkit")

-- local panel = require("widgets/panel")

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                        title = "Oops, an error happened!",
                        text = tostring(err) })
        in_error = false
    end)
end

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}

-- Create a launcher widget and a main menu
myawesomemenu = {
    { "config", "alacritty -e tmux new-session \\; send-keys '" .. editor .. ' ' .. awesome.conffile .. "; exit' C-m \\;" },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end },
    { "reboot", function() os.execute('reboot') end },
}
appsmenu = {
    { "kitty", "kitty -e tmux" },
    { "vifm", "terminal_with_cmd.sh vifm" },
    { "spotify", "spotify" },
    { "firefox", "firefox" },
    { "emacs", "emacs" },
    { "discord", "discord" },
    { "scrcpy", "scrcpy" }
}

mymainmenu = awful.menu({
    items = { { "awesomewm", myawesomemenu, },
        { "apps", appsmenu },
        { "wallpaper", "sxiv -t /home/mahmooz/data/images/wal/" },
        { "movies", "sxiv -f /home/mahmooz/data/charts/" },
        { "reset wallpaper", function()
                os.execute("feh --bg-fill ~/.cache/wallpaper")
        end },
    },
})

local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                {raise = true}
            )
        end
    end),
    awful.button({ }, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({ }, 4, function ()
        awful.client.focus.byidx(1)
    end),
    awful.button({ }, 5, function ()
        awful.client.focus.byidx(-1)
    end)
)

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
--screen.connect_signal("property::geometry", set_wallpaper)

function create_separator()
    return wibox.widget {
        widget = wibox.widget.separator,
        forced_width = 15,
        orientation = 'vertical',
    }
end

spotify_widget = text_button:new('song here', function()
    awful.spawn('spotify_lyrics.sh')
end)

spotify_widget_timer = gears.timer {
    timeout     = 0.35,
    call_now    = true,
    autostart   = true,
    single_shot = false,
    callback = function()
        awful.spawn.easy_async(
            {"current_spotify_song.sh"},
            function(out)
                spotify_widget:change_text(out)
            end
        )
    end
}

battery_widget = awful.widget.watch([[sh -c "acpi | cut -d ' ' -f3,4 | tr -d ','"]], 1,
    function(widget, stdout)
        widget.text = stdout
    end
)

headset_battery_widget = awful.widget.watch('current_headset_battery.sh', 10,
    function(widget, stdout)
        widget.text = stdout
    end
)

function create_topbar(s)

  s.topbar = awful.wibar({position="top", screen=s, height=45})

    s.topbar:setup {
        visible = true,
        layout = wibox.layout.flex.vertical,
        wibox.widget {
            layout = wibox.layout.align.horizontal,
            forced_height = 25,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                s.mytaglist,
                s.mypromptbox,
            },
            {
                layout = wibox.layout.fixed.horizontal,
            },
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                spotify_widget,
                create_separator(),
                volume_widget.widget,
                create_separator(),
                time_widget,
                create_separator(),
                wibox.widget.systray(),
                create_separator(),
                s.mylayoutbox,
            },
        },
        wibox.widget {
            layout  = wibox.layout.align.horizontal,
            s.windowslist,
            {
                layout = wibox.layout.fixed.horizontal,
            },
            {
                layout = wibox.layout.fixed.horizontal,
                --wibox.widget {
                --    widget = wibox.widget.imagebox,
                --    image = '/home/mahmooz/data/icons/osrs.png'
                --},
                --osrs_widget,
                --create_separator(),
                --wibox.widget {
                --    widget = wibox.widget.imagebox,
                --    image = '/home/mahmooz/data/icons/rs3.jpg'
                --},
                --rs3_widget,
                headset_battery_widget,
                create_separator(),
                battery_widget,
                create_separator(),
                dl_traffic_widget,
                create_separator(),
                ul_traffic_widget,
                create_separator(),
                --create_separator(),
                memory_widget,
                create_separator(),
                storage_widget,
            }
        },
        wibox.widget {

            layout  = wibox.layout.align.horizontal,
            {
                layout = wibox.layout.fixed.horizontal,
                --trackify_widget,
            },
            {
                layout = wibox.layout.fixed.horizontal,
            },
            {
                layout = wibox.layout.fixed.horizontal,
                --eth_widget,
                --create_separator(),
                --btc_widget,
                --create_separator(),
                --wibox.widget {
                --    widget = wibox.widget.imagebox,
                --    image = '/home/mahmooz/data/icons/android.png',
                --    buttons = gears.table.join(
                --        awful.button({}, 1, nil, function ()
                --                awful.spawn('scrcpy')
                --        end)
                --    )
                --},
                create_separator(),
                restart_networkmanager_button,
                create_separator(),
                bluetooth_volume_widget.widget,
                create_separator(),
                brightness_widget.widget,
            }
        }
    }
end

awful.screen.connect_for_each_screen(function(s)
        -- Wallpaper
        -- set_wallpaper(s)

        -- Each screen has its own tag table.
        awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

        -- Create a promptbox for each screen
        s.mypromptbox = awful.widget.prompt()
        -- Create an imagebox widget which will contain an icon indicating which layout we're using.
        -- We need one layoutbox per screen.
        s.mylayoutbox = awful.widget.layoutbox(s)
        s.mylayoutbox:buttons(gears.table.join(
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc( 1) end),
            awful.button({ }, 5, function () awful.layout.inc(-1) end)))
        -- Create a taglist widget
        s.mytaglist = awful.widget.taglist {
            screen  = s,
            filter  = awful.widget.taglist.filter.all,
            buttons = taglist_buttons,
        }

        -- Create a tasklist widget
        s.windowslist = awful.widget.tasklist {
            screen  = s,
            filter  = awful.widget.tasklist.filter.currenttags,
            buttons = tasklist_buttons,
            style    = {
                shape_border_width = 1,
                shape_border_color = '#777777',
                shape  = gears.shape.rounded_bar,
            },
            layout = {
                spacing = 5,
                layout  = wibox.layout.fixed.horizontal
            },
            widget_template = {
                {
                    {
                        {
                            {
                                id     = 'icon_role',
                                widget = wibox.widget.imagebox,
                            },
                            margins = 2,
                            widget  = wibox.container.margin,
                        },
                        {
                            id     = 'text_role',
                            widget = wibox.widget.textbox,
                        },
                        layout = wibox.layout.fixed.horizontal,
                    },
                    right = 5,
                    widget = wibox.container.margin
                },
                id     = 'background_role',
                widget = wibox.container.background,
            },
        }

        --toolkit = screen_toolkit:new(s)

        -- Create the wibox

        keyboard_layout_widget = awful.widget.watch("sh -c \"setxkbmap -query | awk '/layout/ {print $2}'\"", 1,
        function(widget, stdout)
            widget.text = '⌨ ' .. stdout
        end)

        wifi_widget = awful.widget.watch([[zsh -c '( sudo wpa_cli -i wlp0s20f3 status; sudo wpa_cli -i wlp0s20f3 signal_poll ) | grep "^\(ssid\|RSSI\)" | cut -d "=" -f2 | tr "\n" " " | read wifi rssi; echo $wifi $rssi']], 1, function(widget, stdout)
            widget.text = '📶 ' .. stdout
        end)

        rs3_widget = awful.widget.watch('rs_player_count.py rs3', 7, function(widget, stdout)
            widget.text = ' ' .. stdout
        end)
        osrs_widget = awful.widget.watch('rs_player_count.py osrs', 7, function(widget, stdout)
            widget.text = ' ' .. stdout
        end)

        restart_networkmanager_button = wibox.widget {
            {
                widget = wibox.widget.textbox,
                id = 'button',
                text = ' restart networkmanager ',
                align = 'center',
            },
            widget = wibox.container.background,
            bg = beautiful.bg_focus,
            fg = beautiful.bg_normal,
            shape = gears.shape.rounded_rect
        }
        restart_networkmanager_button.button:buttons(gears.table.join(
            restart_networkmanager_button:buttons(),
            awful.button({}, 1, nil, function ()
                    awful.spawn([[sh -c "sudo systemctl restart NetworkManager && notify-send 'restarted networkmanager'"]])
            end)
        ))

        trackify_widget = awful.widget.watch('trackify_last_play.py', 10, function(widget, stdout)
            widget.text = stdout
        end)

        create_topbar(s)
end)

-- Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 1, function () mymainmenu:hide() end),
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
        {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
        {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
        {description = "go back", group = "tag"}),
    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.global_bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus down", group = "client"}),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.global_bydirection("up")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus up", group = "client"}),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.global_bydirection("left")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus left", group = "client"}),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.global_bydirection("right")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus right", group = "client"}),

    awful.key({ modkey, "Control"   }, "l",
        function ()
            client.focus.x = client.focus.x + 20
        end,
        {description = "move the client forward", group = "layout"}),
    awful.key({ modkey, "Control"   }, "h",
        function ()
            client.focus.x = client.focus.x - 20
        end,
        {description = "move the client upward", group = "layout"}),
    awful.key({ modkey, "Control"   }, "k",
        function ()
            client.focus.y = client.focus.y - 20
        end,
        {description = "move the client backward", group = "layout"}),
    awful.key({ modkey, "Control"   }, "j",
        function ()
            client.focus.y = client.focus.y + 20
        end,
        {description = "move the client downward", group = "layout"}),

    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.bydirection("down")    end,
        {description = "swap with client down", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.bydirection("up")    end,
        {description = "swap with client up", group = "client"}),
    awful.key({ modkey, "Shift"   }, "l", function () awful.client.swap.bydirection("right")    end,
        {description = "swap with client to the right", group = "client"}),
    awful.key({ modkey, "Shift"   }, "h", function () awful.client.swap.bydirection("left")    end,
        {description = "swap with client to the left", group = "client"}),

    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.byidx(1)
            --navigation_widget.show()
        end,
        {description = "go back", group = "client"}),
    awful.key({ modkey, "Shift" }, "Tab",
        function ()
            awful.client.focus.byidx(-1)
            --navigation_widget.show()
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey, "Mod1" }, "k", function()
        volume_widget:update_increase(3)
    end, {description = "increase volume", group = 'volume'}),
    awful.key({ modkey, "Mod1" }, "j", function()
        volume_widget:update_increase(-3)
    end, {description = "decrease volume", group = 'volume'}),
    awful.key({ modkey, "Mod1" }, "l", function()
        bluetooth_volume_widget:update_increase(3)
    end, {description = "increase bluetooth volume", group = 'volume'}),
    awful.key({ modkey, "Mod1" }, "h", function()
        bluetooth_volume_widget:update_increase(-3)
    end, {description = "decrease bluetooth volume", group = 'volume'}),

    awful.key({ modkey, "Control" }, "space", function ()
        keyboard_widget.switch_layout()
        keyboard_widget.show()
    end, {description = "switch to next keyboard layout", group = "keyboard"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
        {description = "select next", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", {raise = true}
                )
            end
        end,
        {description = "restore minimized", group = "client"}),

    awful.key({ modkey }, "d", function() naughty.destroy_all_notifications() end,
        {description = "lua execute prompt", group = "awesome"})
)

clientkeys = gears.table.join(
    awful.key({ modkey }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),

    awful.key({ modkey,           }, "c", function (c)
        awful.placement.centered(c)
        awful.placement.no_offscreen(c)
    end,
        {description = "center client", group = "client"}),

    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
        {description = "close", group = "client"}),
    awful.key({ modkey, "Shift"   }, "space",  awful.client.floating.toggle                     ,
        {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
        {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
        {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
        {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

globalkeys = gears.table.join(globalkeys,
    awful.key({modkey}, "`", function()
        local screen = awful.screen.focused()
        local tag = screen.tags[4]
        if tag then
            tag:view_only()
        end
    end)
)


-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    { rule_any = { instance = { "Nightly", "Navigator", "Firefox", "firefox" } }, -- firefox
      properties = { tag = "3" } },
    { rule = { name = "Spotify" },
      properties = { tag = "2" } },

    -- All clients will match this rule.
    { rule = { },
      properties = {
          border_width = beautiful.border_width,
          border_color = beautiful.border_normal,
          focus = awful.client.focus.filter,
          raise = true,
          keys = clientkeys,
          buttons = clientbuttons,
          screen = awful.screen.preferred,
          placement = awful.placement.no_overlap+awful.placement.no_offscreen
      }
    },

    --  desktop toolkit
    { rule = { name = "desktop_toolkit" },
      properties = { below = true, focusable = false, requests_no_titlebar = true, raise = false, titlebars_enabled = false, }
    },

    -- Floating clients.
    { rule_any = {
          instance = {
              "DTA",  -- Firefox addon DownThemAll.
              "copyq",  -- Includes session name in class.
              "pinentry",
          },
          class = {
              "Arandr",
              "Blueman-manager",
              "Gpick",
              "Kruler",
              "MessageWin",  -- kalarm.
              "Sxiv",
              "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
              "Wpa_gui",
              "veromix",
              "xtightvncviewer"},

          -- Note that the name property shown in xprop might be set slightly after creation of the client
          -- and the name shown there might not match defined rules here.
          name = {
              "Event Tester",  -- xev.
          },
          role = {
              "AlarmWindow",  -- Thunderbird's calendar.
              "ConfigManager",  -- Thunderbird's about:config.
              "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
          }
    }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
                 }, properties = { titlebars_enabled = true }
    },


    --{ rule_any = { name = { "win.*", }, }, properties = {focusable = false, ontop = true, titlebars_enabled = false} },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
        and not c.size_hints.user_position
    and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    if c.name == 'desktop_toolkit' then
        return
    end
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    local c_titlebar = awful.titlebar(c, {size = 13})
    c_titlebar : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            --awful.titlebar.widget.floatingbutton (c),
            --awful.titlebar.widget.maximizedbutton(c),
            --awful.titlebar.widget.stickybutton   (c),
            --awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus  end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
client.connect_signal("manage",  function(c)
    c.shape = gears.shape.rounded_rect
    if c.fullscreen then
        c.ontop = true
    end
    --navigation_widget.show()
end)
client.connect_signal("manage",  function(c)
    --navigation_widget.show()
end)

gears.timer.start_new(1, function() collectgarbage("step", 20000) return true end)
