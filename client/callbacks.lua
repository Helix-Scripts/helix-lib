--- Client-side callback system
--- Provides a simple RPC-style callback between client and server.
--- Falls back gracefully if ox_lib is present (defers to its system).

local Constants = require 'shared.constants'

---@class HelixCallback
local Callback = {}

local pendingCallbacks = {}
local callbackId = 0

--- Check if ox_lib callbacks are available
local useOxLib = GetResourceState('ox_lib') == 'started'

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

--- Export
exports('callback', function()
    return Callback
end)

return Callback
