local utilities = {}

utilities.pipe_process = function(command)
    local file = io.popen(command)

    if file == nil then
        return nil
    end

    local text = file:read('*all')
    file:close()
    return text
end

utilities.read_line = function(file_name)
    local file = io.open(file_name)

    if not file then
        return nil
    end

    local text = file:read('*line')
    file:close()
    return text
end

utilities.write_file = function(file_name, text)
    local file = io.open(file_name, 'w')

    if not file then
        return nil
    end

    file:write(text)
    file:close()
end

return utilities
