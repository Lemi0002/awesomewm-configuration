pcall(require, 'luarocks.loader')

-- Standard awesome library
local gears = require('gears')
local awful = require('awful')
require('awful.autofocus')
-- Widget and layout library
local wibox = require('wibox')
-- Theme handling library
local beautiful = require('beautiful')
-- Notification library
local naughty = require('naughty')
local menubar = require('menubar')
local hotkeys_popup = require('awful.hotkeys_popup')
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require('awful.hotkeys_popup.keys')

local battery = require('widgets.battery')
local volume = require('widgets.volume')
local wallpaper = require('core.wallpaper')

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = 'Oops, there were errors during startup!',
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal('debug::error', function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = 'Oops, an error happened!',
            text = tostring(err),
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. 'default/theme.lua')
beautiful.init(os.getenv('HOME') .. '/.config/awesome/theme.lua')
core_wallpaper = wallpaper.initialize()
-- beautiful.wallpaper = awful.util.get_configuration_dir() .. 'wallpapers/mountain-road.jpg'

-- This is used later as the default terminal and editor to run.
local terminal = 'kitty'
local editor = os.getenv('EDITOR') or 'nvim'
local editor_cmd = terminal .. ' -e ' .. editor
local modkey = 'Mod4'

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    awful.layout.suit.tile,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.floating,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menubar
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibar
-- Create a textclock widget
local widget_textclock = wibox.widget.textclock('\u{f00ed} %a %d.%m.%y  \u{f0954} %R')
local widget_keyboardlayout = awful.widget.keyboardlayout()
local widget_battery = battery.initialize()
local widget_volume = volume.initialize()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end)
)

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
-- screen.connect_signal('property::geometry', function() wallpaper.set_wallpaper(core_wallpaper, nil) end)

awful.screen.connect_for_each_screen(function(s)
    -- wallpaper.set_wallpaper(core_wallpaper, s)

    -- Each screen has its own tag table.
    awful.tag({ '1', '2', '3', '4', '5', '6', '7', '8', '9' }, s, awful.layout.layouts[1])

    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)))

    s.mytaglist = awful.widget.taglist({
        screen          = s,
        filter          = awful.widget.taglist.filter.all,
        buttons         = taglist_buttons,
        style           = {
            bg_empty = beautiful.color.bg[2],
            bg_occupied = beautiful.color.bg[3],
            bg_focus = beautiful.bg_focus,
            bg_urgent = beautiful.bg_urgent,
            bg_volatile = beautiful.bg_urgent,
            shape = gears.shape.rounded_rect,
        },
        layout          = {
            spacing = beautiful.spacing,
            layout = wibox.layout.fixed.horizontal,
        },
        widget_template = {
            {
                {
                    id     = "text_role",
                    widget = wibox.widget.textbox,
                },
                left   = beautiful.margin_horizontal,
                right  = beautiful.margin_horizontal,
                widget = wibox.container.margin,
            },
            id     = "background_role",
            widget = wibox.container.background,
        },
    })

    s.mywibox = awful.wibar({
        position = 'top',
        screen = s,
        border_width = beautiful.border_width,
        border_color = beautiful.bg_normal,
    })
    s.mywibox:setup({
        {
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        {
            {
                widget = wibox.container.background,
            },
            layout = wibox.layout.flex.horizontal,
        },
        {
            wibox.widget.systray(),
            {
                {
                    {
                        widget = widget_volume.widget,
                    },
                    left   = beautiful.margin_horizontal,
                    right  = beautiful.margin_horizontal,
                    widget = wibox.container.margin,
                },
                bg = beautiful.color.bg[3],
                shape = gears.shape.rounded_rect,
                widget = wibox.container.background,
            },
            {
                {
                    {
                        widget = widget_battery.widget,
                    },
                    left   = beautiful.margin_horizontal,
                    right  = beautiful.margin_horizontal,
                    widget = wibox.container.margin,
                },
                bg = beautiful.color.bg[3],
                shape = gears.shape.rounded_rect,
                widget = wibox.container.background,
            },
            {
                {
                    {
                        widget = widget_textclock,
                    },
                    left   = beautiful.margin_horizontal,
                    right  = beautiful.margin_horizontal,
                    widget = wibox.container.margin,
                },
                bg = beautiful.color.bg[3],
                shape = gears.shape.rounded_rect,
                widget = wibox.container.background,
            },
            s.mylayoutbox,
            spacing = beautiful.spacing,
            layout = wibox.layout.fixed.horizontal,
        },
        layout = wibox.layout.align.horizontal,
    })
end)
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey, }, 's', hotkeys_popup.show_help,
        { description = 'show help', group = 'awesome' }),
    awful.key({ modkey, }, 'Left', awful.tag.viewprev,
        { description = 'view previous', group = 'tag' }),
    awful.key({ modkey, }, 'Right', awful.tag.viewnext,
        { description = 'view next', group = 'tag' }),
    awful.key({ modkey, }, 'Escape', awful.tag.history.restore,
        { description = 'go back', group = 'tag' }),

    awful.key({ modkey, }, 'j',
        function()
            awful.client.focus.byidx(1)
        end,
        { description = 'focus next by index', group = 'client' }
    ),
    awful.key({ modkey, }, 'k',
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = 'focus previous by index', group = 'client' }
    ),

    -- Layout manipulation
    awful.key({ modkey, 'Shift' }, 'j', function() awful.client.swap.byidx(1) end,
        { description = 'swap with next client by index', group = 'client' }),
    awful.key({ modkey, 'Shift' }, 'k', function() awful.client.swap.byidx(-1) end,
        { description = 'swap with previous client by index', group = 'client' }),
    awful.key({ modkey, 'Control' }, 'j', function() awful.screen.focus_relative(1) end,
        { description = 'focus the next screen', group = 'screen' }),
    awful.key({ modkey, 'Control' }, 'k', function() awful.screen.focus_relative(-1) end,
        { description = 'focus the previous screen', group = 'screen' }),
    awful.key({ modkey, }, 'u', awful.client.urgent.jumpto,
        { description = 'jump to urgent client', group = 'client' }),
    awful.key({ modkey, }, 'Tab',
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = 'go back', group = 'client' }),
    awful.key({ modkey }, 'w',
        function ()
            awful.screen.focused().mywibox.visible = not awful.screen.focused().mywibox.visible
        end,
        { description = 'toggle wibar', group = 'screen' }),

    -- Standard program
    awful.key({ modkey, }, 'Return', function() awful.spawn(terminal) end,
        { description = 'open a terminal', group = 'launcher' }),
    awful.key({ modkey, 'Control' }, 'r', awesome.restart,
        { description = 'reload awesome', group = 'awesome' }),
    awful.key({ modkey, 'Shift' }, 'q', awesome.quit,
        { description = 'quit awesome', group = 'awesome' }),
    awful.key({ modkey, }, 'l', function() awful.tag.incmwfact(0.05) end,
        { description = 'increase master width factor', group = 'layout' }),
    awful.key({ modkey, }, 'h', function() awful.tag.incmwfact(-0.05) end,
        { description = 'decrease master width factor', group = 'layout' }),
    awful.key({ modkey, 'Shift' }, 'h', function() awful.tag.incnmaster(1, nil, true) end,
        { description = 'increase the number of master clients', group = 'layout' }),
    awful.key({ modkey, 'Shift' }, 'l', function() awful.tag.incnmaster(-1, nil, true) end,
        { description = 'decrease the number of master clients', group = 'layout' }),
    awful.key({ modkey, 'Control' }, 'h', function() awful.tag.incncol(1, nil, true) end,
        { description = 'increase the number of columns', group = 'layout' }),
    awful.key({ modkey, 'Control' }, 'l', function() awful.tag.incncol(-1, nil, true) end,
        { description = 'decrease the number of columns', group = 'layout' }),
    awful.key({ modkey, }, 'space', function() awful.layout.inc(1) end,
        { description = 'select next', group = 'layout' }),
    awful.key({ modkey, 'Shift' }, 'space', function() awful.layout.inc(-1) end,
        { description = 'select previous', group = 'layout' }),

    awful.key({ modkey, 'Control' }, 'n',
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    'request::activate', 'key.unminimize', { raise = true }
                )
            end
        end,
        { description = 'restore minimized', group = 'client' }),

    -- Prompt
    awful.key({ modkey }, 'r',
        function()
            awful.util.spawn('rofi -show combi', false)
        end,
        { description = 'run rofi', group = 'launcher' }),

    awful.key({ modkey }, 'x',
        function()
            awful.prompt.run {
                prompt       = 'Run Lua code: ',
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. '/history_eval'
            }
        end,
        { description = 'lua execute prompt', group = 'awesome' })
)

clientkeys = gears.table.join(
    awful.key({ modkey, }, 'f',
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
            --
            -- if c.fullscreen then
            --     -- c.screen.mywibox.visible = false
            --     awful.screen.focused().mywibox.visible = false
            -- else
            --     -- c.screen.mywibox.visible = true
            --     awful.screen.focused().mywibox.visible = true
            -- end
        end,
        { description = 'toggle fullscreen', group = 'client' }),
    awful.key({ modkey, }, 'q', function(c) c:kill() end,
        { description = 'close', group = 'client' }),
    awful.key({ modkey, 'Control' }, 'space', awful.client.floating.toggle,
        { description = 'toggle floating', group = 'client' }),
    awful.key({ modkey, 'Control' }, 'Return', function(c) c:swap(awful.client.getmaster()) end,
        { description = 'move to master', group = 'client' }),
    awful.key({ modkey, }, 'o', function(c) c:move_to_screen() end,
        { description = 'move to screen', group = 'client' }),
    awful.key({ modkey, }, 't', function(c) c.ontop = not c.ontop end,
        { description = 'toggle keep on top', group = 'client' }),
    awful.key({ modkey, }, 'n',
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = 'minimize', group = 'client' }),
    awful.key({ modkey, }, 'm',
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = '(un)maximize', group = 'client' }),
    awful.key({ modkey, 'Control' }, 'm',
        function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        { description = '(un)maximize vertically', group = 'client' }),
    awful.key({ modkey, 'Shift' }, 'm',
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        { description = '(un)maximize horizontally', group = 'client' }),

    -- Volume keys
    awful.key({}, 'XF86AudioLowerVolume',
        function()
            volume.decrease_volume(widget_volume)
            -- awful.util.spawn('pactl set-sink-volume @DEFAULT_SINK@ -5%', false)
        end,
        { description = 'decrease volume', group = 'general' }),
    awful.key({}, 'XF86AudioRaiseVolume',
        function()
            volume.increase_volume(widget_volume)
            -- awful.util.spawn('pactl set-sink-volume @DEFAULT_SINK@ +5%', false)
        end,
        { description = 'increase volume', group = 'general' }),
    awful.key({}, 'XF86AudioMute',
        function()
            volume.toggle_mute(widget_volume)
            -- awful.util.spawn('pactl set-sink-mute @DEFAULT_SINK@ toggle', false)
        end,
        { description = 'mute volume', group = 'general' }),

    -- Brightness control
    awful.key({}, 'XF86MonBrightnessUp',
        function()
            awful.util.spawn('backlight_control +5', false)
        end,
        { description = 'increase brightness', group = 'general' }),
    awful.key({}, 'XF86MonBrightnessDown',
        function()
            awful.util.spawn('backlight_control -5', false)
        end,
        { description = 'decrease brightness', group = 'general' }),

    -- Media Keys
    -- awful.key({}, 'XF86AudioPlay', function()
    --     awful.util.spawn('playerctl play-pause', false)
    -- end),
    -- awful.key({}, 'XF86AudioNext', function()
    --     awful.util.spawn('playerctl next', false)
    -- end),
    -- awful.key({}, 'XF86AudioPrev', function()
    --     awful.util.spawn('playerctl previous', false)
    -- end),

    -- Resize operations
    awful.key({ modkey, 'Control' }, 'Left', function()
        local c = client.focus
        if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
            c.maximized = false
            c:relative_move(0, 0, -40, 0)
        end
    end, { description = 'resize smaller horizontally', group = 'floating client' }),
    awful.key({ modkey, 'Control' }, 'Right', function()
        local c = client.focus
        if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
            c.maximized = false
            c:relative_move(0, 0, 40, 0)
        end
    end, { description = 'resize larger horizontally', group = 'floating client' }),
    awful.key({ modkey, 'Control' }, 'Up', function()
        local c = client.focus
        if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
            c.maximized = false
            c:relative_move(0, 0, 0, -40)
        end
    end, { description = 'resize smaller vertically', group = 'floating client' }),
    awful.key({ modkey, 'Control' }, 'Down', function()
        local c = client.focus
        if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
            c.maximized = false
            c:relative_move(0, 0, 0, 40)
        end
    end, { description = 'resize larger vertically', group = 'floating client' }),

    -- Move operations
    awful.key({ modkey, 'Shift' }, 'Left', function()
        local c = client.focus
        if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
            c.maximized = false
            c:relative_move(-40, 0, 0, 0)
        end
    end, { description = 'move client left', group = 'floating client' }),
    awful.key({ modkey, 'Shift' }, 'Right', function()
        local c = client.focus
        if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
            c.maximized = false
            c:relative_move(40, 0, 0, 0)
        end
    end, { description = 'move client right', group = 'floating client' }),
    awful.key({ modkey, 'Shift' }, 'Up', function()
        local c = client.focus
        if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
            c.maximized = false
            c:relative_move(0, -40, 0, 0)
        end
    end, { description = 'move client up', group = 'floating client' }),
    awful.key({ modkey, 'Shift' }, 'Down', function()
        local c = client.focus
        if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
            c.maximized = false
            c:relative_move(0, 40, 0, 0)
        end
    end, { description = 'move client down', group = 'floating client' })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, '#' .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = 'view tag #' .. i, group = 'tag' }),
        -- Toggle tag display.
        awful.key({ modkey, 'Control' }, '#' .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            { description = 'toggle tag #' .. i, group = 'tag' }),
        -- Move client to tag.
        awful.key({ modkey, 'Shift' }, '#' .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = 'move focused client to tag #' .. i, group = 'tag' }),
        -- Toggle tag on focused client.
        awful.key({ modkey, 'Control', 'Shift' }, '#' .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            { description = 'toggle focused client on tag #' .. i, group = 'tag' })
    )
end

clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal('request::activate', 'mouse_click', { raise = true })
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the 'manage' signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                'DTA',   -- Firefox addon DownThemAll.
                'copyq', -- Includes session name in class.
                'pinentry',
            },
            class = {
                'Arandr',
                'Blueman-manager',
                'Gpick',
                'Kruler',
                'MessageWin',  -- kalarm.
                'Sxiv',
                'Tor Browser', -- Needs a fixed window size to avoid fingerprinting by screen size.
                'Wpa_gui',
                'veromix',
                'xtightvncviewer' },

            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                'Event Tester', -- xev.
            },
            role = {
                'AlarmWindow',   -- Thunderbird's calendar.
                'ConfigManager', -- Thunderbird's about:config.
                'pop-up',        -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = {
            floating = true
        },
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal('manage', function(c)
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

client.connect_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.connect_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- User defined
awful.spawn.with_shell('picom')
awful.spawn.with_shell('nitrogen --restore')
