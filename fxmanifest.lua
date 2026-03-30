fx_version('cerulean')
game('gta5')

name('helix_lib')
author('Helix Scripts')
description('Shared utility library — framework bridge, UI components, config system')
version('0.1.0')
url('https://github.com/Helix-Scripts/helix-lib')

lua54('yes')

-- Module loader — MUST run first on both sides. Sets up require() override
-- so shared.* modules resolve via LoadResourceFile on both client and server.
shared_scripts({
    'shared/init.lua',
})

-- Client entry points
client_scripts({
    'client/main.lua',
    'client/callbacks.lua',
    'client/utils.lua',
    'client/ui.lua',
})

-- Server entry points
server_scripts({
    'server/main.lua',
    'server/callbacks.lua',
    'server/utils.lua',
    'server/version.lua',
})

-- NUI
ui_page('html/index.html')

-- Shared modules (loaded on-demand via require() through the init.lua loader)
-- files({}) is needed for client-side LoadResourceFile access.
-- Server-side LoadResourceFile reads the filesystem directly.
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

-- Exports — flat per-function to avoid FiveM export proxy stripping table methods
exports({
    -- Bridge
    'bridge_framework',
    'bridge_getFramework',
    'bridge_is',
    'bridge_GetPlayerMoney',
    'bridge_GetPlayerJob',
    'bridge_GetPlayerIdentifier',
    'bridge_AddMoney',
    'bridge_RemoveMoney',
    'bridge_HasItem',
    'bridge_Notify',
    -- Config
    'config',
    -- Locale
    'locale_t',
    'locale_has',
    'locale_current',
    'locale_set',
    'locale_load',
    'locale_loadFile',
    -- Callbacks (client)
    'callback_trigger',
    'callback_await',
    -- Notify (client convenience)
    'notify',
})

server_exports({
    -- Bridge
    'bridge_framework',
    'bridge_getFramework',
    'bridge_is',
    'bridge_GetPlayer',
    'bridge_GetPlayerMoney',
    'bridge_GetPlayerJob',
    'bridge_GetPlayerIdentifier',
    'bridge_AddMoney',
    'bridge_RemoveMoney',
    'bridge_HasItem',
    'bridge_Notify',
    -- Config
    'config',
    -- Locale
    'locale_t',
    'locale_has',
    'locale_current',
    'locale_set',
    'locale_load',
    'locale_loadFile',
    -- Callbacks (server)
    'callback_register',
    -- Player convenience
    'getPlayer',
    'getPlayers',
})
