pcall(require, 'luarocks.loader')

local awful = require('awful')
local beautiful = require('beautiful')
require('awful.autofocus')
require('awful.hotkeys_popup.keys')

beautiful.init(os.getenv('HOME') .. '/.config/awesome/theme.lua')
require('core')

awful.spawn.with_shell('picom')
awful.spawn.with_shell('playerctld deamon')
