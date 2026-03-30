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

--- Get the bridge module (wrap to ensure methods survive FiveM export proxy)
---@return HelixBridge
exports('bridge', function()
    return {
        framework = Bridge.framework,
        getFramework = function(...) return Bridge.getFramework(...) end,
        is = function(...) return Bridge.is(...) end,
        GetPlayer = function(...) return Bridge.GetPlayer(...) end,
        GetPlayerMoney = function(...) return Bridge.GetPlayerMoney(...) end,
        GetPlayerJob = function(...) return Bridge.GetPlayerJob(...) end,
        GetPlayerIdentifier = function(...) return Bridge.GetPlayerIdentifier(...) end,
        AddMoney = function(...) return Bridge.AddMoney(...) end,
        RemoveMoney = function(...) return Bridge.RemoveMoney(...) end,
        HasItem = function(...) return Bridge.HasItem(...) end,
        Notify = function(...) return Bridge.Notify(...) end,
    }
end)

--- Get the config module
---@return HelixConfig
exports('config', function()
    return Config
end)

--- Get the locale module (wrap to ensure methods survive FiveM export proxy)
---@return HelixLocale
exports('locale', function()
    return {
        t = function(...) return Locale.t(...) end,
        has = function(...) return Locale.has(...) end,
        current = function(...) return Locale.current(...) end,
        set = function(...) return Locale.set(...) end,
        load = function(...) return Locale.load(...) end,
        loadFile = function(...) return Locale.loadFile(...) end,
    }
end)

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
