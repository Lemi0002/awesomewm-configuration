local awful = require('awful')
local gears = require('gears')
local utilities = require('utilities')

local wallpaper_module = {}

local DEFAULTS = {
    configuration = awful.util.get_configuration_dir() .. 'wallpapers/configuration.txt',
    wallpaper = awful.util.get_configuration_dir() .. 'wallpapers/mountain-road.jpg',
    maximized = true,
}

wallpaper_module.new = function(arguments)
    if arguments == nil then
        arguments = {}
    end

    local self = {}
    self.configuration = arguments.configuration or DEFAULTS.configuration
    self.maximized = arguments.maximized or DEFAULTS.maximized

    return self
end

wallpaper_module.set_wallpaper = function(self, screen)
    local wallpaper = utilities.read_line(self.configuration) or ''

    if not gears.filesystem.file_readable(wallpaper) then
        wallpaper = DEFAULTS.wallpaper
    end

    gears.wallpaper.maximized(wallpaper, screen, self.maximized)
end

return wallpaper_module
