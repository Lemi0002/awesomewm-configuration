local awful = require('awful')
local utilities = require('utilities')

local audio_utilities_module = {}

audio_utilities_module.direction = {
    INPUT = 'source',
    OUTPUT = 'sink',
}

audio_utilities_module.device = {
    DEFAULT_INPUT = '@DEFAULT_SOURCE@',
    DEFAULT_OUTPUT = '@DEFAULT_SINK@',
}

audio_utilities_module.get_mute = function(direction, device)
    local stdout = utilities.pipe_process('pactl get-' .. direction .. '-mute ' .. device) or ''

    if string.find(stdout, 'yes') then
        return true
    else
        return false
    end
end

audio_utilities_module.get_volume = function(direction, device)
    local stdout = utilities.pipe_process('pactl get-' .. direction .. '-volume ' .. device) or ''
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

audio_utilities_module.toggle_mute = function(direction, device)
    awful.spawn('pactl set-' .. direction .. '-mute ' .. device .. ' toggle', false)
end

audio_utilities_module.decrease_volume = function(direction, device, volume_step, volume_min)
    local volume_level = audio_utilities_module.get_volume(direction, device)

    if volume_level - volume_step < volume_min then
        awful.spawn('pactl set-' .. direction .. '-volume ' .. device .. ' ' .. volume_min .. '%', false)
    else
        awful.spawn('pactl set-' .. direction .. '-volume ' .. device .. ' -' .. volume_step .. '%', false)
    end
end

audio_utilities_module.increase_volume = function(direction, device, volume_step, volume_max)
    local volume_level = audio_utilities_module.get_volume(direction, device)

    if volume_level + volume_step > volume_max then
        awful.spawn('pactl set-' .. direction .. '-volume ' .. device .. ' ' .. volume_max .. '%', false)
    else
        awful.spawn('pactl set-' .. direction .. '-volume ' .. device .. ' +' .. volume_step .. '%', false)
    end
end

return audio_utilities_module
