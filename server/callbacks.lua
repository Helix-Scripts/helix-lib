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
    -- Handle callback requests from client (only when ox_lib is not available)
    RegisterNetEvent('helix_lib:callback:request', function(name, id, ...)
        local source = source
        local cb = registeredCallbacks[name]

        if not cb then
            print(('[helix_lib] ^1Callback not found: %s^0'):format(name))
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
end

--- Exports — flat functions to survive FiveM export proxy

--- Register a server callback
---@param name string Callback name
---@param cb fun(source: number, ...): any
exports('callback_register', function(...)
    return Callback.register(...)
end)

return Callback
