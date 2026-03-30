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

---@return HelixConfig
exports('config', function()
    return Config
end)

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

--- Get player (convenience export wrapping bridge)
---@param source number
---@return HelixPlayer?
exports('getPlayer', function(source)
    return Bridge.GetPlayer(source)
end)

--- Get all online players
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

--- Startup message
print(([[

    ^5╔═══════════════════════════════════════╗
    ║         helix_lib v%s              ║
    ║         Framework: %-18s║
    ║         Locale: %-21s║
    ╚═══════════════════════════════════════╝^0

]]):format(Constants.VERSION, Bridge.framework, localeLang))
