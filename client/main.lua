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

--- Get a config value. Returns the full config table if no key is given.
--- Scoped to the calling resource by default.
---@param resource? string Resource name (defaults to invoking resource)
---@param key? string Specific config key to retrieve
---@return any
exports('config', function(resource, key)
    resource = resource or GetInvokingResource() or Constants.RESOURCE_NAME
    local cfg = Config.get(resource)
    if not cfg then
        return nil
    end
    if key then
        return cfg[key]
    end
    return cfg
end)

--- Register a callback for config changes (debug/dev hot-reload)
---@param resource? string Resource name (defaults to invoking resource)
---@param cb fun(newConfig: table)
exports('config_onChange', function(resource, cb)
    resource = resource or GetInvokingResource() or Constants.RESOURCE_NAME
    Config.onReload(resource, cb)
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

-- ── Client Utilities ────────────────────────────────────────────────────────

local ClientUtils = require('client.utils')

--- Get the closest player within a radius
---@param radius? number Default: 5.0
---@return number? serverId, number? distance
exports('getClosestPlayer', function(...)
    return ClientUtils.getClosestPlayer(...)
end)

--- Draw 3D text at a world position
---@param coords vector3
---@param text string
---@param scale? number Default: 0.35
exports('drawText3D', function(...)
    return ClientUtils.drawText3D(...)
end)

--- Request and load an animation dictionary
---@param dict string
---@param timeout? number Timeout in ms (default: 5000)
---@return boolean loaded
exports('loadAnimDict', function(...)
    return ClientUtils.loadAnimDict(...)
end)

--- Request and load a model
---@param model string|number
---@param timeout? number Timeout in ms (default: 5000)
---@return boolean loaded
exports('loadModel', function(...)
    return ClientUtils.loadModel(...)
end)

--- Request and load a texture dictionary
---@param dict string
---@param timeout? number Timeout in ms (default: 5000)
---@return boolean loaded
exports('loadTextureDict', function(...)
    return ClientUtils.loadTextureDict(...)
end)

--- Get the street name at coordinates
---@param coords vector3
---@return string streetName, string? crossingName
exports('getStreetName', function(...)
    return ClientUtils.getStreetName(...)
end)

--- Check if the player is in a vehicle
---@return boolean
exports('isInVehicle', function(...)
    return ClientUtils.isInVehicle(...)
end)

--- Get the vehicle the player is currently in
---@return number? vehicle
exports('getCurrentVehicle', function(...)
    return ClientUtils.getCurrentVehicle(...)
end)

--- Handle notification event from server
RegisterNetEvent('helix_lib:notify', function(message, type, duration)
    Bridge.Notify(nil, message, type, duration)
end)

--- Debug logging
if config.debug then
    print(('[helix_lib] ^2Client initialized — framework: %s, locale: %s^0'):format(Bridge.framework, localeLang))
end
