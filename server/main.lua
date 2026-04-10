--- helix_lib server entry point
--- Initializes server-side modules and exposes the public API.

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

--- Get player object
---@param source number
---@return HelixPlayer?
exports('bridge_GetPlayer', function(...)
    return Bridge.GetPlayer(...)
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

-- ── Player convenience exports ───────────────────────────────────────────────

--- Get player (convenience export wrapping bridge)
---@param source number
---@return HelixPlayer?
exports('getPlayer', function(source)
    return Bridge.GetPlayer(source)
end)

--- Get all online players.
--- WARNING: This is a snapshot function that calls Bridge.GetPlayer for each
--- connected player. Do NOT call this per-tick — cache the result if you need
--- frequent access, or use getPlayer(source) for individual lookups.
---@return HelixPlayer[]
exports('getPlayers', function()
    local players = {}
    local playerList = GetPlayers()

    for _, source in ipairs(playerList) do
        local player = Bridge.GetPlayer(tonumber(source))
        if player then
            table.insert(players, player)
        end
    end

    return players
end)

-- ── Config Hot-Reload ───────────────────────────────────────────────────────

--- Console command to trigger config hot-reload for any helix resource
--- Usage: helix_reload_config <resource>
RegisterCommand('helix_reload_config', function(source, args)
    -- Console-only (source 0)
    if source ~= 0 then
        return
    end

    local resource = args[1]
    if not resource then
        print('^3[helix_lib] Usage: helix_reload_config <resource>^0')
        return
    end

    local ok, err = pcall(function()
        Config.reload(resource)
    end)

    if ok then
        print(('[helix_lib] ^2Config reloaded for %s^0'):format(resource))
    else
        print(('[helix_lib] ^1Config reload failed for %s: %s^0'):format(resource, tostring(err)))
    end
end, true) -- restricted to console/admin

-- ── Server Utilities ────────────────────────────────────────────────────────

local ServerUtils = require('server.utils')

--- Get a player's identifier by type
---@param source number Player server ID
---@param idType? string Identifier type (default: 'license')
---@return string? identifier
exports('getIdentifier', function(...)
    return ServerUtils.getIdentifier(...)
end)

--- Check if a player has an ace permission
---@param source number
---@param permission string
---@return boolean
exports('hasPermission', function(...)
    return ServerUtils.hasPermission(...)
end)

--- Generate a unique ID
---@param prefix? string
---@return string
exports('generateId', function(...)
    return ServerUtils.generateId(...)
end)

--- Startup message
print(([[

    ^5╔═══════════════════════════════════════╗
    ║         helix_lib v%s              ║
    ║         Framework: %-18s║
    ║         Locale: %-21s║
    ╚═══════════════════════════════════════╝^0

]]):format(Constants.VERSION, Bridge.framework, localeLang))
