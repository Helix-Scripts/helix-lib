--- NUI bridge — client-side communication with React NUI layer

---@class HelixUI
local UI = {}

local isNuiOpen = false
local nuiCallbackId = 0
local nuiCallbacks = {}

--- Send data to the NUI layer
---@param action string Action name (maps to useNuiEvent hook)
---@param data? table Data payload
function UI.send(action, data)
    SendNUIMessage({
        action = action,
        data = data or {},
    })
end

--- Open the NUI focus (show cursor, capture keyboard)
---@param hasCursor? boolean Default: true
---@param hasKeyboard? boolean Default: true
function UI.focus(hasCursor, hasKeyboard)
    if hasCursor == nil then hasCursor = true end
    if hasKeyboard == nil then hasKeyboard = true end

    SetNuiFocus(true, hasCursor)
    isNuiOpen = true
end

--- Close the NUI focus
function UI.unfocus()
    SetNuiFocus(false, false)
    isNuiOpen = false
end

--- Toggle NUI visibility
---@param visible boolean
---@param hasCursor? boolean
function UI.setVisible(visible, hasCursor)
    UI.send('setVisible', { visible = visible })

    if visible then
        UI.focus(hasCursor)
    else
        UI.unfocus()
    end
end

--- Check if NUI is currently focused
---@return boolean
function UI.isOpen()
    return isNuiOpen
end

--- Register a NUI callback (from React → Lua)
---@param name string Callback name
---@param cb fun(data: table, cb: fun(response: any))
function UI.registerCallback(name, cb)
    RegisterNUICallback(name, function(data, nuiCb)
        cb(data, nuiCb)
    end)
end

--- Close NUI on Escape key by default
UI.registerCallback('close', function(_, cb)
    UI.setVisible(false)
    cb('ok')
end)

return UI
