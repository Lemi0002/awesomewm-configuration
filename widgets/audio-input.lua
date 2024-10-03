local gears = require('gears')
local wibox = require('wibox')
local audio_utilities = require('widgets.audio-utilities')

local audio_input_module = {}

local DEFAULTS = {
    direction = audio_utilities.direction.INPUT,
    device = audio_utilities.device.DEFAULT_INPUT,
    timeout = 5,
    volume = {
        step = 5,
        min = 0,
        max = 100,
    },
    text = {
        leading = '',
        delimiter = ' ',
        trailing = '%',
    },
    indicator = {
        muted = '\u{f036d}',
        unmuted = {
            low = '\u{f036e}',
            high = '\u{f036c}',
        },
    },
}

audio_input_module.toggle_mute = function(self)
    audio_utilities.toggle_mute(self.direction, self.device)
    audio_input_module.update(self)
end

audio_input_module.decrease_volume = function(self)
    audio_utilities.decrease_volume(self.direction, self.device, self.volume.step, self.volume.min)
    audio_input_module.update(self)
end

audio_input_module.increase_volume = function(self)
    audio_utilities.increase_volume(self.direction, self.device, self.volume.step, self.volume.max)
    audio_input_module.update(self)
end

audio_input_module.new = function(arguments)
    if arguments == nil then
        arguments = {}
    end

    local self = {}
    self.direction = DEFAULTS.direction
    self.device = arguments.device or DEFAULTS.device
    self.timeout = arguments.timeout or DEFAULTS.timeout

    if arguments.volume == nil then
        arguments.volume = {}
    end

    if arguments.text == nil then
        arguments.text = {}
    end

    self.volume = {
        step = arguments.volume.step or DEFAULTS.volume.step,
        min = arguments.volume.min or DEFAULTS.volume.min,
        max = arguments.volume.max or DEFAULTS.volume.max,
    }

    self.text = {
        leading = arguments.text.leading or DEFAULTS.text.leading,
        delimiter = arguments.text.delimiter or DEFAULTS.text.delimiter,
        trailing = arguments.text.trailing or DEFAULTS.text.trailing,
    }

    if arguments.indicator == nil then
        arguments.indicator = {}
    end

    if arguments.indicator.unmuted == nil then
        arguments.indicator.unmuted = {}
    end

    self.indicator = {
        muted = arguments.indicator.muted or DEFAULTS.indicator.muted,
        unmuted = {
            low = arguments.indicator.unmuted.low or DEFAULTS.indicator.unmuted.low,
            high = arguments.indicator.unmuted.high or DEFAULTS.indicator.unmuted.high,
        },
    }
    self.widget = wibox.widget.textbox()
    self.timer = gears.timer({ timeout = self.timeout })
    self.timer:connect_signal('timeout', function() audio_input_module.update(self) end)
    self.timer:start()
    audio_input_module.update(self)
    return self
end

audio_input_module.update = function(self)
    local volume = audio_utilities.get_volume(self.direction, self.device)
    local mute = audio_utilities.get_mute(self.direction, self.device)
    local indicator = ''

    if mute then
        indicator = self.indicator.muted
    else
        if volume <= 50 then
            indicator = self.indicator.unmuted.low
        else
            indicator = self.indicator.unmuted.high
        end
    end

    self.widget.text =
        self.text.leading ..
        indicator ..
        self.text.delimiter ..
        volume ..
        self.text.trailing
end

return audio_input_module
