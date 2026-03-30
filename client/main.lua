--- helix_lib client entry point
--- Initializes client-side modules and exposes the public API.

local Config = require('shared.config')
local Bridge = require('shared.bridge.init')
local Locale = require('shared.locale')
local Constants = require('shared.constants')

--- Load config
local config = Config.load(Constants.RESOURCE_NAME)

--- Load locale
local localeLang = config.locale or 'en'
Locale.loadFile(localeLang)
Locale.set(localeLang)

--- Public API via exports
--- Each function gets its own export to avoid FiveM export proxy stripping table methods.

-- ── Bridge ───────────────────────────────────────────────────────────────────

--- Get the detected framework name
---@return string
exports('bridge_framework', function()
    return Bridge.framework
end)

--- Get the detected framework name (function form)
---@return string
exports('bridge_getFramework', function(...)
    return Bridge.getFramework(...)
end)

--- Check if a specific framework is active
---@param framework string
---@return boolean
exports('bridge_is', function(...)
    return Bridge.is(...)
end)

--- Get player money
---@param source number
---@param moneyType? string
---@return number?
exports('bridge_GetPlayerMoney', function(...)
    return Bridge.GetPlayerMoney(...)
end)

--- Get player job info
---@param source number
---@return table?
exports('bridge_GetPlayerJob', function(...)
    return Bridge.GetPlayerJob(...)
end)

--- Get player identifier
---@param source number
---@return string?
exports('bridge_GetPlayerIdentifier', function(...)
    return Bridge.GetPlayerIdentifier(...)
end)

--- Add money to player
---@param source number
---@param amount number
---@param moneyType? string
exports('bridge_AddMoney', function(...)
    return Bridge.AddMoney(...)
end)

--- Remove money from player
---@param source number
---@param amount number
---@param moneyType? string
exports('bridge_RemoveMoney', function(...)
    return Bridge.RemoveMoney(...)
end)

--- Check if player has item
---@param source number
---@param item string
---@param count? number
---@return boolean
exports('bridge_HasItem', function(...)
    return Bridge.HasItem(...)
end)

--- Send notification
---@param source? number
---@param message string
---@param type? string
---@param duration? number
exports('bridge_Notify', function(...)
    return Bridge.Notify(...)
end)

-- ── Config ───────────────────────────────────────────────────────────────────

--- Get the config module (returns the table directly — Config has no cross-proxy issue
--- because consumers call config methods inline, not stored)
---@return HelixConfig
exports('config', function()
    return Config
end)

-- ── Locale ───────────────────────────────────────────────────────────────────

--- Translate a key with optional format arguments
---@param key string
---@param ... any
---@return string
exports('locale_t', function(...)
    return Locale.t(...)
end)

--- Check if a translation key exists
---@param key string
---@param lang? string
---@return boolean
exports('locale_has', function(...)
    return Locale.has(...)
end)

--- Get the active locale language
---@return string
exports('locale_current', function(...)
    return Locale.current(...)
end)

--- Set the active locale language
---@param lang string
exports('locale_set', function(...)
    return Locale.set(...)
end)

--- Load translations into memory
---@param lang string
---@param translations table
exports('locale_load', function(...)
    return Locale.load(...)
end)

--- Load translations from a locale file
---@param lang string
---@param resourceName? string
---@return boolean
exports('locale_loadFile', function(...)
    return Locale.loadFile(...)
end)

-- ── Notify (convenience shorthand) ───────────────────────────────────────────

--- Send notification (client-side shorthand)
---@param message string
---@param type? string
---@param duration? number
exports('notify', function(message, type, duration)
    Bridge.Notify(nil, message, type, duration)
end)

--- Handle notification event from server
RegisterNetEvent('helix_lib:notify', function(message, type, duration)
    Bridge.Notify(nil, message, type, duration)
end)

--- Debug logging
if config.debug then
    print(('[helix_lib] ^2Client initialized — framework: %s, locale: %s^0'):format(Bridge.framework, localeLang))
end
