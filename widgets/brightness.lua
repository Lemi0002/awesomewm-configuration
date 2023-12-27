local gears = require('gears')
local wibox = require('wibox')
local utilities = require('utilities')

local brightness_module = {}

local PATH_BACKLIGHT = '/sys/class/backlight/'
local DEFAULTS = {
    backlight = 'intel_backlight',
    timeout = 10,
    brightness = {
        step = 5,
        min = 1,
        max = 100,
    },
    text = {
        leading = '',
        delimiter = ' ',
        trailing = '%',
    },
    indicator = {
        [25] = '\u{f00de}',
        [75] = '\u{f00df}',
        [100] = '\u{f00e0}',
    },
}

local get_brightness = function(self)
    local brightness = tonumber(utilities.read_line(self.file.brightness) or '0') or 0
    local max = tonumber(utilities.read_line(self.file.max_brightness) or '100') or 100
    return math.floor(brightness * 100 / max)
end

local set_brightness = function(self, brightness)
    local max = tonumber(utilities.read_line(self.file.max_brightness) or '100') or 100

    if brightness < self.brightness.min then
        brightness = self.brightness.min
    elseif brightness > self.brightness.max then
        brightness = self.brightness.max
    end

    brightness = math.floor(brightness * max / 100)
    utilities.write_file(self.file.brightness, tostring(brightness))
end

brightness_module.decrease_brightness = function(self)
    set_brightness(self, get_brightness(self) - self.brightness.step)
    brightness_module.update(self)
end

brightness_module.increase_brightness = function(self)
    set_brightness(self, get_brightness(self) + self.brightness.step)
    brightness_module.update(self)
end

brightness_module.initialize = function(arguments)
    if arguments == nil then
        arguments = {}
    end

    local self = {}
    self.backlight = arguments.backlight or DEFAULTS.backlight
    self.timeout = arguments.timeout or DEFAULTS.timeout

    if arguments.brightness == nil then
        arguments.brightness = {}
    end

    self.brightness = {
        step = arguments.brightness.step or DEFAULTS.brightness.step,
        min = arguments.brightness.min or DEFAULTS.brightness.min,
        max = arguments.brightness.max or DEFAULTS.brightness.max,
    }

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

    self.indicator = {
        [25] = arguments.indicator[25] or DEFAULTS.indicator[25],
        [75] = arguments.indicator[75] or DEFAULTS.indicator[75],
        [100] = arguments.indicator[100] or DEFAULTS.indicator[100],
    }
    self.file = {
        brightness = PATH_BACKLIGHT .. self.backlight .. '/brightness',
        max_brightness = PATH_BACKLIGHT .. self.backlight .. '/max_brightness',
    }
    self.widget = wibox.widget.textbox()
    self.timer = gears.timer({ timeout = self.timeout })
    self.timer:connect_signal('timeout', function() brightness_module.update(self) end)
    self.timer:start()
    brightness_module.update(self)
    return self
end

brightness_module.update = function(self)
    local brightness = get_brightness(self)
    local indicator = ''

    if brightness <= 25 then
        indicator = self.indicator[25]
    elseif brightness <= 75 then
        indicator = self.indicator[75]
    else
        indicator = self.indicator[100]
    end

    self.widget.text =
        self.text.leading ..
        indicator ..
        self.text.delimiter ..
        brightness ..
        self.text.trailing
end

return brightness_module
