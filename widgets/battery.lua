local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local naughty = require('naughty')

local battery = {}
local PATH_POWER_SUPPLY = '/sys/class/power_supply/'

local DEFAULTS = {
    adapter = 'BAT0',
    timeout = 20,
    prefix = {
        plugged = '\u{f0084}',
        unavailable = '\u{f0091}',
        unplugged = {
            ['10'] = '\u{f007a}',
            ['20'] = '\u{f007b}',
            ['30'] = '\u{f007c}',
            ['40'] = '\u{f007d}',
            ['50'] = '\u{f007e}',
            ['60'] = '\u{f007f}',
            ['70'] = '\u{f0080}',
            ['80'] = '\u{f0081}',
            ['90'] = '\u{f0082}',
            ['100'] = '\u{f0079}',
        },
    },
}

local read_file = function(file)
    local file = io.open(file)

    if not file then
        return nil
    end

    local text = file:read('*all')
    file:close()
    return text
end

local trim = function(s)
    if not s then
        return nil
    end

    return (s:gsub('^%s*(.-)%s*$', '%1'))
end

local read_trim = function(file_name)
    return trim(read_file(file_name)) or ''
end

battery.initialize = function(arguments)
    if arguments == nil then
        arguments = {}
    end

    local self = {}
    self.adapter = arguments.adapter or DEFAULTS.adapter
    self.timeout = arguments.timeout or DEFAULTS.timeout

    if arguments.prefix == nil then
        arguments.prefix = {}
    end

    if arguments.prefix.unplugged == nil then
        arguments.prefix.unplugged = {}
    end

    self.prefix = {
        plugged = arguments.prefix.plugged or DEFAULTS.prefix.plugged,
        unavailable = arguments.prefix.unavailable or DEFAULTS.prefix.unavailable,
        unplugged = {
            ['10'] = arguments.prefix.unplugged['10'] or DEFAULTS.prefix.unplugged['10'],
            ['20'] = arguments.prefix.unplugged['20'] or DEFAULTS.prefix.unplugged['20'],
            ['30'] = arguments.prefix.unplugged['30'] or DEFAULTS.prefix.unplugged['30'],
            ['40'] = arguments.prefix.unplugged['40'] or DEFAULTS.prefix.unplugged['40'],
            ['50'] = arguments.prefix.unplugged['50'] or DEFAULTS.prefix.unplugged['50'],
            ['60'] = arguments.prefix.unplugged['60'] or DEFAULTS.prefix.unplugged['60'],
            ['70'] = arguments.prefix.unplugged['70'] or DEFAULTS.prefix.unplugged['70'],
            ['80'] = arguments.prefix.unplugged['80'] or DEFAULTS.prefix.unplugged['80'],
            ['90'] = arguments.prefix.unplugged['90'] or DEFAULTS.prefix.unplugged['90'],
            ['100'] = arguments.prefix.unplugged['100'] or DEFAULTS.prefix.unplugged['100'],
        },
    }
    self.path = {
        battery = PATH_POWER_SUPPLY .. self.adapter,
        capacity = PATH_POWER_SUPPLY .. self.adapter .. '/capacity',
        status = PATH_POWER_SUPPLY .. self.adapter .. '/status',
    }
    self.widget = wibox.widget.textbox()
    self.timer = gears.timer({ timeout = self.timeout })
    self.timer:connect_signal('timeout', function() battery.update(self) end)
    self.timer:start()
    battery.update(self)
    return self
end

battery.update = function(self)
    if gears.filesystem.dir_readable(self.path.battery) == false
        or gears.filesystem.file_readable(self.path.capacity) == false
        or gears.filesystem.file_readable(self.path.status) == false then
        return
    end

    local capacity = tonumber(read_trim(self.path.capacity))
    self.widget.text = self.prefix.plugged .. ' ' .. capacity
end

return battery
