local gears = require('gears')
local wibox = require('wibox')
local utilities = require('utilities')

local battery_module = {}

local PATH_POWER_SUPPLY = '/sys/class/power_supply/'
local DEFAULTS = {
    adapter = 'BAT0',
    timeout = 10,
    text = {
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

battery_module.initialize = function(arguments)
    if arguments == nil then
        arguments = {}
    end

    local self = {}
    self.adapter = arguments.adapter or DEFAULTS.adapter
    self.timeout = arguments.timeout or DEFAULTS.timeout

    if arguments.text == nil then
        arguments.text = {}
    end

    self.text = {
        leading = arguments.text.leading or DEFAULTS.text.leading,
        delimiter = arguments.text.delimiter or DEFAULTS.text.delimiter,
        trailing = arguments.text.trailing or DEFAULTS.text.trailing,
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
    self.timer:connect_signal('timeout', function() battery_module.update(self) end)
    self.timer:start()
    battery_module.update(self)
    return self
end

battery_module.update = function(self)
    local capacity = tonumber(utilities.read_line(self.file.capacity) or '0') or 0
    local status = string.lower(utilities.read_line(self.file.status) or '')
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
        self.text.leading ..
        indicator ..
        self.text.delimiter ..
        capacity ..
        self.text.trailing
end

return battery_module
