local Constants = require 'shared.constants'

---@class HelixConfig
local Config = {}

local loadedConfigs = {}
local configWatchers = {}

--- Load a config file with type validation and defaults
---@param resourceName string
---@param defaults? table Default values to merge
---@return table config
function Config.load(resourceName, defaults)
    local configFile = LoadResourceFile(resourceName, 'config.lua')
    if not configFile then
        Config.log('warn', ('No config.lua found for %s, using defaults'):format(resourceName))
        loadedConfigs[resourceName] = defaults or {}
        return loadedConfigs[resourceName]
    end

    local fn, err = load(configFile, ('@%s/config.lua'):format(resourceName))
    if not fn then
        Config.log('error', ('Failed to parse config for %s: %s'):format(resourceName, err))
        loadedConfigs[resourceName] = defaults or {}
        return loadedConfigs[resourceName]
    end

    local ok, result = pcall(fn)
    if not ok then
        Config.log('error', ('Failed to execute config for %s: %s'):format(resourceName, result))
        loadedConfigs[resourceName] = defaults or {}
        return loadedConfigs[resourceName]
    end

    -- Merge with defaults (config values override defaults)
    if defaults then
        result = Config.merge(defaults, result)
    end

    loadedConfigs[resourceName] = result
    return result
end

--- Get a previously loaded config
---@param resourceName string
---@return table|nil config
function Config.get(resourceName)
    return loadedConfigs[resourceName]
end

--- Deep merge two tables (target values override source)
---@param source table Base table
---@param target table Override table
---@return table merged
function Config.merge(source, target)
    local result = {}

    for k, v in pairs(source) do
        if type(v) == 'table' and type(target[k]) == 'table' then
            result[k] = Config.merge(v, target[k])
        elseif target[k] ~= nil then
            result[k] = target[k]
        else
            result[k] = v
        end
    end

    -- Include keys only in target
    for k, v in pairs(target) do
        if result[k] == nil then
            result[k] = v
        end
    end

    return result
end

--- Register a callback for config reload (debug/dev mode only)
---@param resourceName string
---@param cb fun(newConfig: table)
function Config.onReload(resourceName, cb)
    if not configWatchers[resourceName] then
        configWatchers[resourceName] = {}
    end
    table.insert(configWatchers[resourceName], cb)
end

--- Reload a config and notify watchers
---@param resourceName string
function Config.reload(resourceName)
    local newConfig = Config.load(resourceName)
    loadedConfigs[resourceName] = newConfig

    if configWatchers[resourceName] then
        for _, cb in ipairs(configWatchers[resourceName]) do
            pcall(cb, newConfig)
        end
    end

    Config.log('info', ('Config reloaded for %s'):format(resourceName))
end

--- Internal logging helper
---@param level string
---@param message string
function Config.log(level, message)
    local prefix = '[helix_lib:config]'
    if level == 'error' then
        print('^1' .. prefix .. ' ERROR: ' .. message .. '^0')
    elseif level == 'warn' then
        print('^3' .. prefix .. ' WARN: ' .. message .. '^0')
    elseif level == 'info' then
        print('^5' .. prefix .. ' ' .. message .. '^0')
    elseif level == 'debug' then
        print('^7' .. prefix .. ' DEBUG: ' .. message .. '^0')
    end
end

return Config
