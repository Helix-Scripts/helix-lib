--- Server-side callback system
--- Provides a simple RPC-style callback between client and server.
--- Falls back gracefully if ox_lib is present (defers to its system).

---@class HelixServerCallback
local Callback = {}

local registeredCallbacks = {}

--- Check if ox_lib callbacks are actually available (global `lib` may not exist even if resource is started)
local useOxLib = type(lib) == 'table' and type(lib.callback) == 'table'

--- Register a server callback
---@param name string Callback name
---@param cb fun(source: number, ...): any
function Callback.register(name, cb)
    if useOxLib then
        lib.callback.register(name, cb)
    else
        registeredCallbacks[name] = cb
    end
end

if not useOxLib then
    --- Rate-limit tracking: source -> last call timestamp (ms)
    local lastCallTime = {}

    --- Minimum interval between callback requests per player (ms)
    local RATE_LIMIT_MS = 100

    -- Handle callback requests from client (only when ox_lib is not available).
    -- Uses RegisterNetEvent which is the correct pattern for modern FiveM —
    -- the event is implicitly registered as a net event at manifest level.
    RegisterNetEvent('helix_lib:callback:request', function(name, id, ...)
        -- Capture source immediately; the global may change if the callback yields
        local source = source

        -- Input validation: name must be a non-empty string
        if type(name) ~= 'string' or name == '' then
            print(('[helix_lib] ^1Invalid callback name from player %s^0'):format(tostring(source)))
            return
        end

        -- Input validation: id must be present
        if not id then
            print(('[helix_lib] ^1Missing callback id from player %s (callback: %s)^0'):format(tostring(source), name))
            return
        end

        -- Rate limiting: reject requests that come too fast from the same source
        local now = GetGameTimer()
        if lastCallTime[source] and (now - lastCallTime[source]) < RATE_LIMIT_MS then
            print(
                ('[helix_lib] ^3Rate-limited callback request from player %s (callback: %s)^0'):format(
                    tostring(source),
                    name
                )
            )
            TriggerClientEvent('helix_lib:callback:response', source, id, nil)
            return
        end
        lastCallTime[source] = now

        -- Verify the callback exists before executing
        local cb = registeredCallbacks[name]
        if not cb then
            print(('[helix_lib] ^1Unknown callback "%s" requested by player %s^0'):format(name, tostring(source)))
            TriggerClientEvent('helix_lib:callback:response', source, id, nil)
            return
        end

        local ok, result = pcall(cb, source, ...)
        if not ok then
            print(('[helix_lib] ^1Callback error in %s: %s^0'):format(name, result))
            TriggerClientEvent('helix_lib:callback:response', source, id, nil)
            return
        end

        TriggerClientEvent('helix_lib:callback:response', source, id, result)
    end)

    -- Clean up rate-limit tracking when a player drops
    AddEventHandler('playerDropped', function()
        lastCallTime[source] = nil
    end)
end

--- Exports — flat functions to survive FiveM export proxy

--- Register a server callback
---@param name string Callback name
---@param cb fun(source: number, ...): any
exports('callback_register', function(...)
    return Callback.register(...)
end)

return Callback
