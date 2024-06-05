local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')
local core_keymaps = require('core.keymaps')

client.connect_signal('focus', function(client) client.border_color = beautiful.border_focus end)
client.connect_signal('unfocus', function(client) client.border_color = beautiful.border_normal end)

client.connect_signal('manage', function(client)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and not client.size_hints.user_position and not client.size_hints.program_position then
        awful.placement.no_offscreen(client)
    end
end)

client.connect_signal('request::titlebars', function(client)
    local titlebar = awful.titlebar(client, {
        size = 35,
    })

    local buttons = gears.table.join(
        awful.button({}, 1, function()
            client:emit_signal('request::activate', 'titlebar', { raise = true })
            awful.mouse.client.move(client)
        end),
        awful.button({ core_keymaps.modkey }, 1, function()
            client:emit_signal('request::activate', 'titlebar', { raise = true })
            awful.mouse.client.resize(client)
        end)
    )

    titlebar:setup({
        {
            -- awful.titlebar.widget.iconwidget(c),
            -- buttons = buttons,
            layout = wibox.layout.fixed.horizontal
        },
        {
            {
                align  = 'center',
                widget = awful.titlebar.widget.titlewidget(client)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        {
            -- awful.titlebar.widget.floatingbutton (c),
            -- awful.titlebar.widget.maximizedbutton(c),
            -- awful.titlebar.widget.stickybutton   (c),
            -- awful.titlebar.widget.ontopbutton    (c),
            -- awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    })

    if client.type ~= 'dialog' then
        awful.titlebar.hide(client)
    end
end)
