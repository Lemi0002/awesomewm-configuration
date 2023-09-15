local gears = require('gears')
local wibox = require('wibox')

local battery = {}

local PATH_POWER_SUPPLY = '/sys/class/power_supply/'
local DEFAULTS = {
    adapter = 'BAT0',
    timeout = 10,
    character = {
        leading = '',
        delimiter = ' ',
        trailing = '%',
    },
    indicator = {
        plugged = '\u{f0084}',
        unavailable = '\u{f0091}',
        unplugged = {
            [10] = '\u{f007a}',
            [20] = '\u{f007b}',
            [30] = '\u{f007c}',
            [40] = '\u{f007d}',
            [50] = '\u{f007e}',
            [60] = '\u{f007f}',
            [70] = '\u{f0080}',
            [80] = '\u{f0081}',
            [90] = '\u{f0082}',
            [100] = '\u{f0079}',
        },
    },
}

local read_line = function(file_name)
    local file = io.open(file_name)

    if not file then
        return nil
    end

    local text = file:read('*line')
    file:close()
    return text
end

battery.initialize = function(arguments)
    if arguments == nil then
        arguments = {}
    end

    local self = {}
    self.adapter = arguments.adapter or DEFAULTS.adapter
    self.timeout = arguments.timeout or DEFAULTS.timeout

    if arguments.character == nil then
        arguments.character = {}
    end

    self.character = {
        leading = arguments.character.leading or DEFAULTS.character.leading,
        delimiter = arguments.character.delimiter or DEFAULTS.character.delimiter,
        trailing = arguments.character.trailing or DEFAULTS.character.trailing,
    }

    if arguments.indicator == nil then
        arguments.indicator = {}
    end

    if arguments.indicator.unplugged == nil then
        arguments.indicator.unplugged = {}
    end

    self.indicator = {
        plugged = arguments.indicator.plugged or DEFAULTS.indicator.plugged,
        unavailable = arguments.indicator.unavailable or DEFAULTS.indicator.unavailable,
        unplugged = {
            [10] = arguments.indicator.unplugged[10] or DEFAULTS.indicator.unplugged[10],
            [20] = arguments.indicator.unplugged[20] or DEFAULTS.indicator.unplugged[20],
            [30] = arguments.indicator.unplugged[30] or DEFAULTS.indicator.unplugged[30],
            [40] = arguments.indicator.unplugged[40] or DEFAULTS.indicator.unplugged[40],
            [50] = arguments.indicator.unplugged[50] or DEFAULTS.indicator.unplugged[50],
            [60] = arguments.indicator.unplugged[60] or DEFAULTS.indicator.unplugged[60],
            [70] = arguments.indicator.unplugged[70] or DEFAULTS.indicator.unplugged[70],
            [80] = arguments.indicator.unplugged[80] or DEFAULTS.indicator.unplugged[80],
            [90] = arguments.indicator.unplugged[90] or DEFAULTS.indicator.unplugged[90],
            [100] = arguments.indicator.unplugged[100] or DEFAULTS.indicator.unplugged[100],
        },
    }
    self.file = {
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
    local capacity = tonumber(read_line(self.file.capacity) or '0') or 0
    local status = string.lower(read_line(self.file.status) or '')
    local indicator = ''

    if status == 'discharging' then
        local index = (math.floor((capacity - 1) / 10) + 1) * 10
        indicator = self.indicator.unplugged[index]
    elseif status == 'charging' then
        indicator = self.indicator.plugged
    else
        indicator = self.indicator.unavailable
    end

    self.widget.text =
        self.character.leading ..
        indicator ..
        self.character.delimiter ..
        capacity ..
        self.character.trailing
end

return battery
