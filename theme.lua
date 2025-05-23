local theme_assets         = require('beautiful.theme_assets')
local xresources           = require('beautiful.xresources')
local dpi                  = xresources.apply_dpi
local gfs                  = require('gears.filesystem')
local themes_path          = gfs.get_themes_dir()

local theme                = {}

theme.font                 = 'FiraCodeNerdFont 10'
theme.color                = {
    bg = {
        [1] = '#131313',
        [2] = '#292929',
        [3] = '#555555',
    },
    fg = {
        [1] = '#bbbbbb',
        [2] = '#ffffff',
    },
    highlight = {
        [1] = '#78573a',
        [2] = '#7b4d47',
        [3] = '#714857',
        [4] = '#5c4861',
        [5] = '#434961',
    },
}

theme.bg_normal            = theme.color.bg[1]
theme.bg_focus             = theme.color.highlight[1]

theme.fg_normal            = theme.color.fg[2]
theme.fg_focus             = theme.color.fg[2]

theme.border_normal        = theme.bg_normal
theme.border_focus         = theme.bg_focus

theme.hotkeys_bg           = theme.color.bg[1]
theme.hotkeys_border_color = theme.color.highlight[2]
theme.snap_bg              = theme.color.highlight[3]

theme.useless_gap          = dpi(5)
theme.border_width         = dpi(5)
theme.spacing              = dpi(10)
theme.margin_horizontal    = dpi(12)
theme.corner_radius        = dpi(7)


theme.menu_submenu_icon                         = themes_path .. 'default/submenu.png'
theme.menu_height                               = dpi(15)
theme.menu_width                                = dpi(100)

theme.titlebar_close_button_normal              = themes_path .. 'default/titlebar/close_normal.png'
theme.titlebar_close_button_focus               = themes_path .. 'default/titlebar/close_focus.png'

theme.titlebar_minimize_button_normal           = themes_path .. 'default/titlebar/minimize_normal.png'
theme.titlebar_minimize_button_focus            = themes_path .. 'default/titlebar/minimize_focus.png'

theme.titlebar_ontop_button_normal_inactive     = themes_path .. 'default/titlebar/ontop_normal_inactive.png'
theme.titlebar_ontop_button_focus_inactive      = themes_path .. 'default/titlebar/ontop_focus_inactive.png'
theme.titlebar_ontop_button_normal_active       = themes_path .. 'default/titlebar/ontop_normal_active.png'
theme.titlebar_ontop_button_focus_active        = themes_path .. 'default/titlebar/ontop_focus_active.png'

theme.titlebar_sticky_button_normal_inactive    = themes_path .. 'default/titlebar/sticky_normal_inactive.png'
theme.titlebar_sticky_button_focus_inactive     = themes_path .. 'default/titlebar/sticky_focus_inactive.png'
theme.titlebar_sticky_button_normal_active      = themes_path .. 'default/titlebar/sticky_normal_active.png'
theme.titlebar_sticky_button_focus_active       = themes_path .. 'default/titlebar/sticky_focus_active.png'

theme.titlebar_floating_button_normal_inactive  = themes_path .. 'default/titlebar/floating_normal_inactive.png'
theme.titlebar_floating_button_focus_inactive   = themes_path .. 'default/titlebar/floating_focus_inactive.png'
theme.titlebar_floating_button_normal_active    = themes_path .. 'default/titlebar/floating_normal_active.png'
theme.titlebar_floating_button_focus_active     = themes_path .. 'default/titlebar/floating_focus_active.png'

theme.titlebar_maximized_button_normal_inactive = themes_path .. 'default/titlebar/maximized_normal_inactive.png'
theme.titlebar_maximized_button_focus_inactive  = themes_path .. 'default/titlebar/maximized_focus_inactive.png'
theme.titlebar_maximized_button_normal_active   = themes_path .. 'default/titlebar/maximized_normal_active.png'
theme.titlebar_maximized_button_focus_active    = themes_path .. 'default/titlebar/maximized_focus_active.png'

theme.wallpaper                                 = themes_path .. 'default/background.png'

theme.layout_fairh                              = themes_path .. 'default/layouts/fairhw.png'
theme.layout_fairv                              = themes_path .. 'default/layouts/fairvw.png'
theme.layout_floating                           = themes_path .. 'default/layouts/floatingw.png'
theme.layout_magnifier                          = themes_path .. 'default/layouts/magnifierw.png'
theme.layout_max                                = themes_path .. 'default/layouts/maxw.png'
theme.layout_fullscreen                         = themes_path .. 'default/layouts/fullscreenw.png'
theme.layout_tilebottom                         = themes_path .. 'default/layouts/tilebottomw.png'
theme.layout_tileleft                           = themes_path .. 'default/layouts/tileleftw.png'
theme.layout_tile                               = themes_path .. 'default/layouts/tilew.png'
theme.layout_tiletop                            = themes_path .. 'default/layouts/tiletopw.png'
theme.layout_spiral                             = themes_path .. 'default/layouts/spiralw.png'
theme.layout_dwindle                            = themes_path .. 'default/layouts/dwindlew.png'
theme.layout_cornernw                           = themes_path .. 'default/layouts/cornernww.png'
theme.layout_cornerne                           = themes_path .. 'default/layouts/cornernew.png'
theme.layout_cornersw                           = themes_path .. 'default/layouts/cornersww.png'
theme.layout_cornerse                           = themes_path .. 'default/layouts/cornersew.png'

theme.awesome_icon                              = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme                                = nil

return theme
