local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local utilities = require('utilities')

local volume_module = {}

local DEFAULTS = {
    device = '@DEFAULT_SINK@',
    timeout = 5,
    volume = {
        step = 5,
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

local get_mute = function(device)
    local stdout = utilities.pipe_process('pactl get-sink-mute ' .. device) or ''

    if string.find(stdout, 'yes') then
        return true
    else
        return false
    end
end

local get_volume = function(device)
    local stdout = utilities.pipe_process('pactl get-sink-volume ' .. device) or ''
    local volume_sum = 0
    local volume_count = 0

    for volume_string in string.gmatch(stdout, '(%d?%d?%d)%%') do
        local volume = tonumber(volume_string)

        if volume ~= nil then
            volume_sum = volume_sum + volume
            volume_count = volume_count + 1
        end
    end

    if volume_count == 0 then
        return 0
    end

    return math.floor(volume_sum / volume_count)
end

volume_module.toggle_mute = function(self)
    awful.spawn('pactl set-sink-mute ' .. self.device .. ' toggle', false)
    volume_module.update(self)
end

volume_module.decrease_volume = function(self)
    awful.spawn('pactl set-sink-volume ' .. self.device .. ' -' .. self.volume.step .. '%', false)
    volume_module.update(self)
end

volume_module.increase_volume = function(self)
    local volume_level = get_volume(self.device)

    if volume_level + self.volume.step > self.volume.max then
        awful.spawn('pactl set-sink-volume ' .. self.device .. ' ' .. self.volume.max .. '%', false)
    else
        awful.spawn('pactl set-sink-volume ' .. self.device .. ' +' .. self.volume.step .. '%', false)
    end

    volume_module.update(self)
end

volume_module.new = function(arguments)
    if arguments == nil then
        arguments = {}
    end

    local self = {}
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
    self.timer:connect_signal('timeout', function() volume_module.update(self) end)
    self.timer:start()
    volume_module.update(self)
    return self
end

volume_module.update = function(self)
    local volume = get_volume(self.device)
    local mute = get_mute(self.device)
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

return volume_module
