local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')
local core_keymaps = require('core.keymaps')
local core_wallpaper = require('core.wallpaper')
local widgets_battery = require('widgets.battery')
local widgets_brightness = require('widgets.brightness')
local widgets_audio_input = require('widgets.audio-input')
local widgets_audio_output = require('widgets.audio-output')

local wallpaper = core_wallpaper.new()
local layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}

local shape = function()
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, beautiful.corner_radius)
    end
end

local widgets = {
    battery = widgets_battery.new(),
    brightness = widgets_brightness.new(),
    audio_input = widgets_audio_input.new(),
    audio_output = widgets_audio_output.new({ volume = { step = 2 } }),
    textclock = awful.widget.textclock('\u{f00ed} %a %Y-%m-%d  \u{f0954} %R'),
    calendar = awful.widget.calendar_popup.year({
        week_numbers = true,
        style_year = {
            shape = shape(),
            border_color = beautiful.color.highlight[2],
        },
        style_yearheader = {
            shape = shape(),
        },
        style_month = {
            shape = shape(),
        },
        style_header = {
            bg_color = beautiful.color.bg[3],
            shape = shape(),
            padding = 5,
        },
        style_weekday = {
            fg_color = beautiful.color.fg[1],
            bg_color = beautiful.color.bg[2],
            shape = shape(),
            padding = 5,
        },
        style_weeknumber = {
            fg_color = beautiful.color.fg[1],
            bg_color = beautiful.color.bg[2],
            shape = shape(),
            padding = 5,
        },
        style_normal = {
            fg_color = beautiful.color.fg[1],
            shape = shape(),
        },
        style_focus = {
            bg_color = beautiful.color.highlight[1],
            shape = shape(),
            padding = 5,
        },
    }),
}

local buttons = {
    calendar = gears.table.join(
        awful.button({}, 1, function()
            widgets.calendar:toggle()
        end)
    ),
    layoutbox = gears.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)
    ),
    tablist = gears.table.join(
        awful.button({}, 1, function(tag) tag:view_only() end),
        awful.button({ core_keymaps.modkey }, 1, function(tag)
            if client.focus then
                client.focus:move_to_tag(tag)
            end
        end)
    ),
}

core_keymaps.global.append_keys(
    -- Audio input
    awful.key({ core_keymaps.modkey }, 'XF86AudioLowerVolume',
        function() widgets_audio_input.decrease_volume(widgets.audio_input) end,
        { description = 'decrease input volume', group = 'general' }),
    awful.key({ core_keymaps.modkey }, 'XF86AudioRaiseVolume',
        function() widgets_audio_input.increase_volume(widgets.audio_input) end,
        { description = 'increase input volume', group = 'general' }),
    awful.key({ core_keymaps.modkey }, 'XF86AudioMute',
        function() widgets_audio_input.toggle_mute(widgets.audio_input) end,
        { description = 'mute input volume', group = 'general' }),

    -- Audio output
    awful.key({}, 'XF86AudioLowerVolume', function() widgets_audio_output.decrease_volume(widgets.audio_output) end,
        { description = 'decrease output volume', group = 'general' }),
    awful.key({}, 'XF86AudioRaiseVolume', function() widgets_audio_output.increase_volume(widgets.audio_output) end,
        { description = 'increase output volume', group = 'general' }),
    awful.key({}, 'XF86AudioMute', function() widgets_audio_output.toggle_mute(widgets.audio_output) end,
        { description = 'mute output volume', group = 'general' }),

    -- Brightness
    awful.key({}, 'XF86MonBrightnessUp', function() widgets_brightness.increase_brightness(widgets.brightness) end,
        { description = 'increase brightness', group = 'general' }),
    awful.key({}, 'XF86MonBrightnessDown', function() widgets_brightness.decrease_brightness(widgets.brightness) end,
        { description = 'decrease brightness', group = 'general' })
)

awful.layout.layouts = layouts
widgets.calendar:call_calendar(0, 'tr', awful.screen.focused())

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal('property::geometry', function() core_wallpaper.set_wallpaper(wallpaper, nil) end)

awful.screen.connect_for_each_screen(function(screen)
    core_wallpaper.set_wallpaper(wallpaper, screen)

    -- Each screen has its own tag table.
    awful.tag({ '1', '2', '3', '4', '5', '6', '7', '8', '9' }, screen, awful.layout.layouts[1])

    screen.mypromptbox = awful.widget.prompt()
    screen.mylayoutbox = awful.widget.layoutbox(screen)
    screen.mylayoutbox:buttons(buttons.layoutbox)

    screen.mytaglist = awful.widget.taglist({
        screen          = screen,
        filter          = awful.widget.taglist.filter.all,
        buttons         = buttons.tablist,
        style           = {
            bg_empty = beautiful.color.bg[2],
            bg_occupied = beautiful.color.bg[3],
            bg_focus = beautiful.color.highlight[1],
            bg_urgent = beautiful.color.highlight[3],
            bg_volatile = beautiful.color.highlight[3],
            shape = shape(),
        },
        layout          = {
            spacing = beautiful.spacing,
            layout = wibox.layout.fixed.horizontal,
        },
        widget_template = {
            {
                {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                },
                left   = beautiful.margin_horizontal,
                right  = beautiful.margin_horizontal,
                widget = wibox.container.margin,
            },
            id     = 'background_role',
            widget = wibox.container.background,
        },
    })

    screen.mywibox = awful.wibar({
        position = 'top',
        screen = screen,
        border_width = beautiful.border_width,
        border_color = beautiful.color.bg[1],
    })
    screen.mywibox:setup({
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = beautiful.spacing,
            screen.mytaglist,
            screen.mypromptbox,
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
                        widget = widgets.audio_input.widget,
                    },
                    left   = beautiful.margin_horizontal,
                    right  = beautiful.margin_horizontal,
                    widget = wibox.container.margin,
                },
                bg = beautiful.color.bg[3],
                shape = shape(),
                widget = wibox.container.background,
            },
            {
                {
                    {
                        widget = widgets.audio_output.widget,
                    },
                    left   = beautiful.margin_horizontal,
                    right  = beautiful.margin_horizontal,
                    widget = wibox.container.margin,
                },
                bg = beautiful.color.bg[3],
                shape = shape(),
                widget = wibox.container.background,
            },
            {
                {
                    {
                        widget = widgets.brightness.widget,
                    },
                    left   = beautiful.margin_horizontal,
                    right  = beautiful.margin_horizontal,
                    widget = wibox.container.margin,
                },
                bg = beautiful.color.bg[3],
                shape = shape(),
                widget = wibox.container.background,
            },
            {
                {
                    {
                        widget = widgets.battery.widget,
                    },
                    left   = beautiful.margin_horizontal,
                    right  = beautiful.margin_horizontal,
                    widget = wibox.container.margin,
                },
                bg = beautiful.color.bg[3],
                shape = shape(),
                widget = wibox.container.background,
            },
            {
                {
                    {
                        widget = widgets.textclock,
                    },
                    left   = beautiful.margin_horizontal,
                    right  = beautiful.margin_horizontal,
                    widget = wibox.container.margin,
                },
                bg = beautiful.color.bg[3],
                shape = shape(),
                buttons = buttons.calendar,
                widget = wibox.container.background,
            },
            screen.mylayoutbox,
            spacing = beautiful.spacing,
            layout = wibox.layout.fixed.horizontal,
        },
        layout = wibox.layout.align.horizontal,
    })
end)
