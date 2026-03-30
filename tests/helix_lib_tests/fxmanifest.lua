fx_version('cerulean')
game('gta5')

name('helix_lib_tests')
author('Helix Scripts')
description('End-to-end test harness for helix_lib')
version('1.0.0')

lua54('yes')

dependency('helix_lib')

shared_scripts({
    'shared/runner.lua',
})

server_scripts({
    'server/test_config.lua',
    'server/test_locale.lua',
    'server/test_bridge.lua',
    'server/test_callbacks.lua',
    'server/test_version.lua',
    'server/test_utils.lua',
    'server/main.lua',
})

client_scripts({
    'client/test_config.lua',
    'client/test_locale.lua',
    'client/test_bridge.lua',
    'client/test_callbacks.lua',
    'client/test_nui.lua',
    'client/test_utils.lua',
    'client/main.lua',
})

ui_page('html/index.html')

files({
    'config.lua',
    'locales/*.lua',
    'html/**/*',
})
