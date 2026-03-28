fx_version('cerulean')
game('gta5')

name('helix_lib')
author('Helix Scripts')
description('Shared utility library — framework bridge, UI components, config system')
version('0.1.0')
url('https://github.com/Helix-Scripts/helix-lib')

lua54('yes')

-- Shared (loaded first)
shared_scripts({
    'shared/constants.lua',
    'shared/config.lua',
    'shared/locale.lua',
    'shared/bridge/init.lua',
})

-- Client
client_scripts({
    'client/main.lua',
    'client/callbacks.lua',
    'client/utils.lua',
    'client/ui.lua',
})

-- Server
server_scripts({
    'server/main.lua',
    'server/callbacks.lua',
    'server/utils.lua',
    'server/version.lua',
})

-- NUI
ui_page('html/index.html')

files({
    'html/**/*',
    'locales/*.lua',
    'config.lua',
    'shared/bridge/qbox.lua',
    'shared/bridge/qbcore.lua',
    'shared/bridge/esx.lua',
})

-- Exports
exports({
    'bridge',
    'config',
    'locale',
    'callback',
    'notify',
})

server_exports({
    'bridge',
    'config',
    'locale',
    'callback',
    'getPlayer',
    'getPlayers',
})
