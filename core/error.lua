local naughty = require('naughty')

if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = 'Error occurred during startup',
        text = awesome.startup_errors
    })
end

local in_error = false
awesome.connect_signal('debug::error', function(error)
    if in_error then return end
    in_error = true

    naughty.notify({
        preset = naughty.config.presets.critical,
        title = 'Error occurred',
        text = tostring(error),
    })
    in_error = false
end)
