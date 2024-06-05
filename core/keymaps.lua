local gears = require('gears')
local awful = require('awful')
local hotkeys_popup = require('awful.hotkeys_popup')
local core_globals = require('core.globals')

local keymaps_module = {
    modkey = 'Mod4',
    global = {},
    client = {},
}

local step_size_resize = 80
local step_size_move = 120

keymaps_module.global.keys = gears.table.join(
    -- Awesome
    awful.key({ keymaps_module.modkey, }, 's', hotkeys_popup.show_help,
        { description = 'show help', group = 'awesome' }),
    awful.key({ keymaps_module.modkey, 'Control' }, 'r', awesome.restart,
        { description = 'reload awesome', group = 'awesome' }),
    awful.key({ keymaps_module.modkey, 'Shift' }, 'q', awesome.quit,
        { description = 'quit awesome', group = 'awesome' }),

    -- Client
    awful.key({ keymaps_module.modkey, }, 'j', function() awful.client.focus.byidx(1) end,
        { description = 'focus next by index', group = 'client' }),
    awful.key({ keymaps_module.modkey, }, 'k', function() awful.client.focus.byidx(-1) end,
        { description = 'focus previous by index', group = 'client' }),
    awful.key({ keymaps_module.modkey, 'Shift' }, 'j', function() awful.client.swap.byidx(1) end,
        { description = 'swap with next client by index', group = 'client' }),
    awful.key({ keymaps_module.modkey, 'Shift' }, 'k', function() awful.client.swap.byidx(-1) end,
        { description = 'swap with previous client by index', group = 'client' }),
    awful.key({ keymaps_module.modkey, }, 'u', awful.client.urgent.jumpto,
        { description = 'jump to urgent client', group = 'client' }),
    awful.key({ keymaps_module.modkey, }, 'Tab',
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = 'go back', group = 'client' }),
    awful.key({ keymaps_module.modkey, 'Control' }, 'n',
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

    -- General
    awful.key({}, 'XF86AudioPlay', function() awful.util.spawn('playerctl play', false) end,
        { description = 'play media', group = 'general' }),
    awful.key({}, 'XF86AudioPause', function() awful.util.spawn('playerctl pause', false) end,
        { description = 'pause media', group = 'general' }),
    awful.key({}, 'XF86AudioPrev', function() awful.util.spawn('playerctl previous', false) end,
        { description = 'previous media', group = 'general' }),
    awful.key({}, 'XF86AudioNext', function() awful.util.spawn('playerctl next', false) end,
        { description = 'next media', group = 'general' }),

    -- Launcher
    awful.key({ keymaps_module.modkey, }, 'Return', function() awful.spawn(core_globals.terminal) end,
        { description = 'open a terminal', group = 'launcher' }),
    awful.key({ keymaps_module.modkey }, 'r', function() awful.util.spawn('rofi -show combi', false) end,
        { description = 'run rofi', group = 'launcher' }),
    awful.key({ keymaps_module.modkey }, 'x',
        function()
            awful.prompt.run {
                prompt       = 'Run Lua code: ',
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. '/history_eval'
            }
        end,
        { description = 'lua execute prompt', group = 'launcher' }),

    -- Layout
    awful.key({ keymaps_module.modkey, }, 'l', function() awful.tag.incmwfact(0.05) end,
        { description = 'increase master width factor', group = 'layout' }),
    awful.key({ keymaps_module.modkey, }, 'h', function() awful.tag.incmwfact(-0.05) end,
        { description = 'decrease master width factor', group = 'layout' }),
    awful.key({ keymaps_module.modkey, 'Shift' }, 'h', function() awful.tag.incnmaster(1, nil, true) end,
        { description = 'increase the number of master clients', group = 'layout' }),
    awful.key({ keymaps_module.modkey, 'Shift' }, 'l', function() awful.tag.incnmaster(-1, nil, true) end,
        { description = 'decrease the number of master clients', group = 'layout' }),
    awful.key({ keymaps_module.modkey, 'Control' }, 'h', function() awful.tag.incncol(1, nil, true) end,
        { description = 'increase the number of columns', group = 'layout' }),
    awful.key({ keymaps_module.modkey, 'Control' }, 'l', function() awful.tag.incncol(-1, nil, true) end,
        { description = 'decrease the number of columns', group = 'layout' }),
    awful.key({ keymaps_module.modkey, }, 'space', function() awful.layout.inc(1) end,
        { description = 'select next', group = 'layout' }),
    awful.key({ keymaps_module.modkey, 'Shift' }, 'space', function() awful.layout.inc(-1) end,
        { description = 'select previous', group = 'layout' }),

    -- Screen
    awful.key({ keymaps_module.modkey, 'Control' }, 'j', function() awful.screen.focus_relative(1) end,
        { description = 'focus the next screen', group = 'screen' }),
    awful.key({ keymaps_module.modkey, 'Control' }, 'k', function() awful.screen.focus_relative(-1) end,
        { description = 'focus the previous screen', group = 'screen' }),
    awful.key({ keymaps_module.modkey }, 'w',
        function()
            awful.screen.focused().mywibox.visible = not awful.screen.focused().mywibox.visible
        end,
        { description = 'toggle wibar', group = 'screen' }),

    -- Tag
    awful.key({ keymaps_module.modkey, }, 'Escape', awful.tag.history.restore,
        { description = 'go back', group = 'tag' })
    -- awful.key({ keymaps_module.modkey, }, 'Left', awful.tag.viewprev,
    --     { description = 'view previous', group = 'tag' }),
    -- awful.key({ keymaps_module.modkey, }, 'Right', awful.tag.viewnext,
    --     { description = 'view next', group = 'tag' }),
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    keymaps_module.global.keys = gears.table.join(keymaps_module.global.keys,
        awful.key({ keymaps_module.modkey }, '#' .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = 'view tag #' .. i, group = 'tag' }),
        awful.key({ keymaps_module.modkey, 'Control' }, '#' .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            { description = 'toggle tag #' .. i, group = 'tag' }),
        awful.key({ keymaps_module.modkey, 'Shift' }, '#' .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = 'move focused client to tag #' .. i, group = 'tag' }),
        awful.key({ keymaps_module.modkey, 'Control', 'Shift' }, '#' .. i + 9,
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

keymaps_module.client.keys = gears.table.join(
    -- Client
    awful.key({ keymaps_module.modkey, }, 'f',
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = 'toggle fullscreen', group = 'client' }),
    awful.key({ keymaps_module.modkey, }, 'q', function(c) c:kill() end,
        { description = 'close', group = 'client' }),
    awful.key({ keymaps_module.modkey, 'Control' }, 'space', awful.client.floating.toggle,
        { description = 'toggle floating', group = 'client' }),
    awful.key({ keymaps_module.modkey, 'Shift' }, 'Return', function(c) c:swap(awful.client.getmaster()) end,
        { description = 'move to master', group = 'client' }),
    awful.key({ keymaps_module.modkey, }, 'o', function(c) c:move_to_screen() end,
        { description = 'move to screen', group = 'client' }),
    -- awful.key({ keymaps_module.modkey, }, 't', function(c) c.ontop = not c.ontop end,
    --     { description = 'toggle keep on top', group = 'client' }),
    awful.key({ keymaps_module.modkey, }, 't', function(c) awful.titlebar.toggle(c) end,
        { description = 'toggle titlebar', group = 'client' }),
    awful.key({ keymaps_module.modkey, }, 'n',
        function(c)
            c.minimized = true
        end,
        { description = 'minimize', group = 'client' }),
    awful.key({ keymaps_module.modkey, }, 'm',
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = '(un)maximize', group = 'client' }),
    awful.key({ keymaps_module.modkey, 'Control' }, 'm',
        function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        { description = '(un)maximize vertically', group = 'client' }),
    awful.key({ keymaps_module.modkey, 'Shift' }, 'm',
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        { description = '(un)maximize horizontally', group = 'client' }),

    -- Floating client
    awful.key({ keymaps_module.modkey, 'Control' }, 'Left',
        function()
            local c = client.focus
            if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
                c.maximized = false
                c:relative_move(0, 0, -step_size_resize, 0)
            end
        end,
        { description = 'resize smaller horizontally', group = 'floating client' }),
    awful.key({ keymaps_module.modkey, 'Control' }, 'Right',
        function()
            local c = client.focus
            if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
                c.maximized = false
                c:relative_move(0, 0, step_size_resize, 0)
            end
        end,
        { description = 'resize larger horizontally', group = 'floating client' }),
    awful.key({ keymaps_module.modkey, 'Control' }, 'Up',
        function()
            local c = client.focus
            if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
                c.maximized = false
                c:relative_move(0, 0, 0, -step_size_resize)
            end
        end,
        { description = 'resize smaller vertically', group = 'floating client' }),
    awful.key({ keymaps_module.modkey, 'Control' }, 'Down',
        function()
            local c = client.focus
            if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
                c.maximized = false
                c:relative_move(0, 0, 0, step_size_resize)
            end
        end,
        { description = 'resize larger vertically', group = 'floating client' }),
    awful.key({ keymaps_module.modkey, 'Shift' }, 'Left',
        function()
            local c = client.focus
            if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
                c.maximized = false
                c:relative_move(-step_size_move, 0, 0, 0)
            end
        end,
        { description = 'move client left', group = 'floating client' }),
    awful.key({ keymaps_module.modkey, 'Shift' }, 'Right',
        function()
            local c = client.focus
            if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
                c.maximized = false
                c:relative_move(step_size_move, 0, 0, 0)
            end
        end,
        { description = 'move client right', group = 'floating client' }),
    awful.key({ keymaps_module.modkey, 'Shift' }, 'Up',
        function()
            local c = client.focus
            if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
                c.maximized = false
                c:relative_move(0, -step_size_move, 0, 0)
            end
        end,
        { description = 'move client up', group = 'floating client' }),
    awful.key({ keymaps_module.modkey, 'Shift' }, 'Down',
        function()
            local c = client.focus
            if c.floating or c.first_tag and c.first_tag.layout.name == 'floating' then
                c.maximized = false
                c:relative_move(0, step_size_move, 0, 0)
            end
        end,
        { description = 'move client down', group = 'floating client' })
)

keymaps_module.client.buttons = gears.table.join(
    awful.button({}, 1, function(c) c:emit_signal('request::activate', 'mouse_click', { raise = true }) end)
)

keymaps_module.global.append_keys = function(...)
    keymaps_module.global.keys = gears.table.join(keymaps_module.global.keys, ...)
end

keymaps_module.global.apply_keys = function()
    root.keys(keymaps_module.global.keys)
end

return keymaps_module
