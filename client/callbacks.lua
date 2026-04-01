--- Client-side callback system
--- Provides a simple RPC-style callback between client and server.
--- Falls back gracefully if ox_lib is present (defers to its system).

local Constants = require('shared.constants')

---@class HelixCallback
local Callback = {}

local pendingCallbacks = {}
local callbackId = 0

--- Check if ox_lib callbacks are actually available (global `lib` may not exist even if resource is started)
local useOxLib = type(lib) == 'table' and type(lib.callback) == 'table'

if useOxLib then
    -- If ox_lib is present, wrap its callback system for API consistency
    -- This means helix_lib callbacks work identically regardless of ox_lib presence

    ---@param name string Callback name
    ---@param cb fun(result: any)
    ---@param ... any Arguments to pass to server
    function Callback.trigger(name, cb, ...)
        local result = lib.callback.await(name, false, ...)
        if cb then
            cb(result)
        end
        return result
    end

    ---@param name string Callback name
    ---@param ... any Arguments to pass to server
    ---@return any result
    function Callback.await(name, ...)
        return lib.callback.await(name, false, ...)
    end
else
    -- Native callback implementation (no ox_lib dependency)

    ---@param name string Callback name
    ---@param cb fun(result: any)
    ---@param ... any Arguments to pass to server
    function Callback.trigger(name, cb, ...)
        callbackId = callbackId + 1
        local id = callbackId

        pendingCallbacks[id] = cb
        TriggerServerEvent('helix_lib:callback:request', name, id, ...)

        -- Clean up if server never responds (30s timeout)
        SetTimeout(30000, function()
            pendingCallbacks[id] = nil
        end)
    end

    ---@param name string Callback name
    ---@param ... any Arguments to pass to server
    ---@return any result
    function Callback.await(name, ...)
        local p = promise.new()

        Callback.trigger(name, function(result)
            p:resolve(result)
        end, ...)

        return Citizen.Await(p)
    end

    -- Handle callback response from server
    RegisterNetEvent('helix_lib:callback:response', function(id, result)
        local cb = pendingCallbacks[id]
        if cb then
            pendingCallbacks[id] = nil
            cb(result)
        end
    end)
end

--- Exports — flat functions to survive FiveM export proxy

--- Trigger an async callback to the server
---@param name string Callback name
---@param cb fun(result: any)
---@param ... any Arguments to pass to server
exports('callback_trigger', function(...)
    return Callback.trigger(...)
end)

--- Trigger a synchronous (blocking) callback to the server
---@param name string Callback name
---@param ... any Arguments to pass to server
---@return any result
exports('callback_await', function(...)
    return Callback.await(...)
end)

return Callback
