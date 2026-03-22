--- Server-side utility functions

---@class HelixServerUtils
local Utils = {}

--- Get a player's identifier by type
---@param source number Player server ID
---@param idType? string Identifier type (default: 'license')
---@return string? identifier
function Utils.getIdentifier(source, idType)
    idType = idType or 'license'
    local identifiers = GetPlayerIdentifiers(source)

    for _, id in ipairs(identifiers) do
        if string.find(id, idType .. ':') then
            return id
        end
    end

    return nil
end

--- Check if a player has an ace permission
---@param source number
---@param permission string
---@return boolean
function Utils.hasPermission(source, permission)
    return IsPlayerAceAllowed(source, permission)
end

--- Log a message with resource prefix and color
---@param level 'info'|'warn'|'error'|'debug'
---@param message string
---@param ... any Format arguments
function Utils.log(level, message, ...)
    if select('#', ...) > 0 then
        message = string.format(message, ...)
    end

    local prefix = '[helix_lib]'
    if level == 'error' then
        print('^1' .. prefix .. ' ERROR: ' .. message .. '^0')
    elseif level == 'warn' then
        print('^3' .. prefix .. ' WARN: ' .. message .. '^0')
    elseif level == 'info' then
        print('^5' .. prefix .. ' ' .. message .. '^0')
    elseif level == 'debug' then
        local config = exports[GetCurrentResourceName()]:config()
        if config and config.debug then
            print('^7' .. prefix .. ' DEBUG: ' .. message .. '^0')
        end
    end
end

--- Generate a unique ID
---@param prefix? string
---@return string
function Utils.generateId(prefix)
    prefix = prefix or 'helix'
    return ('%s_%s_%s'):format(prefix, os.time(), math.random(1000, 9999))
end

--- Safely encode a table to JSON
---@param tbl table
---@return string?
function Utils.jsonEncode(tbl)
    local ok, result = pcall(json.encode, tbl)
    if ok then
        return result
    end
    return nil
end

--- Safely decode JSON to a table
---@param str string
---@return table?
function Utils.jsonDecode(str)
    if not str or str == '' then
        return nil
    end
    local ok, result = pcall(json.decode, str)
    if ok then
        return result
    end
    return nil
end

return Utils
