local Constants = require('shared.constants')

---@class HelixBridge
---@field framework string Detected framework name
---@field GetPlayer fun(source: number): HelixPlayer?
---@field GetPlayerMoney fun(source: number, moneyType?: string): number
---@field GetPlayerJob fun(source: number): HelixJob?
---@field GetPlayerIdentifier fun(source: number): string?
---@field AddMoney fun(source: number, amount: number, moneyType?: string): boolean
---@field RemoveMoney fun(source: number, amount: number, moneyType?: string): boolean
---@field HasItem fun(source: number, item: string, count?: number): boolean
---@field Notify fun(source: number, message: string, type?: string, duration?: number)
local Bridge = {}

---@class HelixPlayer
---@field source number
---@field name string
---@field identifier string
---@field job HelixJob?
---@field gang HelixGang?
---@field money table<string, number>

---@class HelixJob
---@field name string
---@field label string
---@field grade number
---@field gradeLabel string
---@field onDuty boolean

---@class HelixGang
---@field name string
---@field label string
---@field grade number
---@field gradeLabel string

local detectedFramework = nil

--- Detect the active framework
---@return string framework
local function detect()
    -- Check config override first
    local configFramework = nil
    pcall(function()
        local cfg = exports[Constants.RESOURCE_NAME]:config()
        if cfg and cfg.framework then
            configFramework = cfg.framework
        end
    end)

    if configFramework then
        return configFramework
    end

    -- Auto-detect
    if GetResourceState('qbx_core') == 'started' then
        return Constants.Framework.QBOX
    elseif GetResourceState('qb-core') == 'started' then
        return Constants.Framework.QBCORE
    elseif GetResourceState('es_extended') == 'started' then
        return Constants.Framework.ESX
    end

    return Constants.Framework.STANDALONE
end

--- Initialize the bridge
function Bridge.init()
    detectedFramework = detect()
    Bridge.framework = detectedFramework

    local bridgeModule = nil

    if detectedFramework == Constants.Framework.QBOX then
        bridgeModule = require('shared.bridge.qbox')
    elseif detectedFramework == Constants.Framework.QBCORE then
        bridgeModule = require('shared.bridge.qbcore')
    elseif detectedFramework == Constants.Framework.ESX then
        bridgeModule = require('shared.bridge.esx')
    end

    if bridgeModule then
        for k, v in pairs(bridgeModule) do
            Bridge[k] = v
        end
    end

    print(('[helix_lib] ^2Framework detected: %s^0'):format(detectedFramework))
end

--- Get detected framework
---@return string
function Bridge.getFramework()
    return detectedFramework or detect()
end

--- Check if a specific framework is active
---@param framework string
---@return boolean
function Bridge.is(framework)
    return (detectedFramework or detect()) == framework
end

-- Initialize on load
Bridge.init()

return Bridge
