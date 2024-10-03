local gears = require('gears')
local wibox = require('wibox')
local audio_utilities = require('widgets.audio-utilities')

local audio_output_module = {}

local DEFAULTS = {
    direction = audio_utilities.direction.OUTPUT,
    device = audio_utilities.device.DEFAULT_OUTPUT,
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
        muted = '\u{f075f}',
        unmuted = {
            low = '\u{f057f}',
            medium = '\u{f0580}',
            high = '\u{f057e}',
        },
    },
}

audio_output_module.toggle_mute = function(self)
    audio_utilities.toggle_mute(self.direction, self.device)
    audio_output_module.update(self)
end

audio_output_module.decrease_volume = function(self)
    audio_utilities.decrease_volume(self.direction, self.device, self.volume.step, self.volume.min)
    audio_output_module.update(self)
end

audio_output_module.increase_volume = function(self)
    audio_utilities.increase_volume(self.direction, self.device, self.volume.step, self.volume.max)
    audio_output_module.update(self)
end

audio_output_module.new = function(arguments)
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
            medium = arguments.indicator.unmuted.medium or DEFAULTS.indicator.unmuted.medium,
            high = arguments.indicator.unmuted.high or DEFAULTS.indicator.unmuted.high,
        },
    }
    self.widget = wibox.widget.textbox()
    self.timer = gears.timer({ timeout = self.timeout })
    self.timer:connect_signal('timeout', function() audio_output_module.update(self) end)
    self.timer:start()
    audio_output_module.update(self)
    return self
end

audio_output_module.update = function(self)
    local volume = audio_utilities.get_volume(self.direction, self.device)
    local mute = audio_utilities.get_mute(self.direction, self.device)
    local indicator = ''

    if mute then
        indicator = self.indicator.muted
    else
        if volume <= 30 then
            indicator = self.indicator.unmuted.low
        elseif volume <= 60 then
            indicator = self.indicator.unmuted.medium
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

return audio_output_module
