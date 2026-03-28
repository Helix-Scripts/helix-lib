fx_version('cerulean')
game('gta5')

name('helix_lib')
author('Helix Scripts')
description('Shared utility library — framework bridge, UI components, config system')
version('0.1.0')
url('https://github.com/Helix-Scripts/helix-lib')

lua54('yes')

-- Client entry points (require shared modules internally)
client_scripts({
    'client/main.lua',
    'client/callbacks.lua',
    'client/utils.lua',
    'client/ui.lua',
})

-- Server entry points (require shared modules internally)
server_scripts({
    'server/main.lua',
    'server/callbacks.lua',
    'server/utils.lua',
    'server/version.lua',
})

-- NUI
ui_page('html/index.html')

-- Shared modules available via require(), plus NUI and locale assets
files({
    'shared/constants.lua',
    'shared/config.lua',
    'shared/locale.lua',
    'shared/bridge/init.lua',
    'shared/bridge/qbox.lua',
    'shared/bridge/qbcore.lua',
    'shared/bridge/esx.lua',
    'html/**/*',
    'locales/*.lua',
    'config.lua',
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
