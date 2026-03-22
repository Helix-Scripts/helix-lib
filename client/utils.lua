--- Client-side utility functions

---@class HelixClientUtils
local Utils = {}

--- Get the closest player within a radius
---@param radius? number Default: 5.0
---@return number? serverId Closest player server ID
---@return number? distance Distance to closest player
function Utils.getClosestPlayer(radius)
    radius = radius or 5.0
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestPlayer = nil
    local closestDistance = radius

    local activePlayers = GetActivePlayers()
    for _, playerId in ipairs(activePlayers) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)

            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = GetPlayerServerId(playerId)
            end
        end
    end

    return closestPlayer, closestDistance
end

--- Draw 3D text at a world position
---@param coords vector3
---@param text string
---@param scale? number Default: 0.35
function Utils.drawText3D(coords, text, scale)
    scale = scale or 0.35
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline()
        SetTextEntry('STRING')
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(x, y)
    end
end

--- Request and load an animation dictionary
---@param dict string Animation dictionary name
---@param timeout? number Timeout in ms (default: 5000)
---@return boolean loaded
function Utils.loadAnimDict(dict, timeout)
    if HasAnimDictLoaded(dict) then
        return true
    end

    RequestAnimDict(dict)
    timeout = timeout or 5000
    local startTime = GetGameTimer()

    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() - startTime > timeout then
            return false
        end
        Wait(10)
    end

    return true
end

--- Request and load a model
---@param model string|number Model name or hash
---@param timeout? number Timeout in ms (default: 5000)
---@return boolean loaded
function Utils.loadModel(model, timeout)
    if type(model) == 'string' then
        model = joaat(model)
    end

    if HasModelLoaded(model) then
        return true
    end

    RequestModel(model)
    timeout = timeout or 5000
    local startTime = GetGameTimer()

    while not HasModelLoaded(model) do
        if GetGameTimer() - startTime > timeout then
            return false
        end
        Wait(10)
    end

    return true
end

--- Request and load a texture dictionary
---@param dict string Texture dictionary name
---@param timeout? number Timeout in ms (default: 5000)
---@return boolean loaded
function Utils.loadTextureDict(dict, timeout)
    if HasStreamedTextureDictLoaded(dict) then
        return true
    end

    RequestStreamedTextureDict(dict, true)
    timeout = timeout or 5000
    local startTime = GetGameTimer()

    while not HasStreamedTextureDictLoaded(dict) do
        if GetGameTimer() - startTime > timeout then
            return false
        end
        Wait(10)
    end

    return true
end

--- Get the street name at coords
---@param coords vector3
---@return string streetName
---@return string? crossingName
function Utils.getStreetName(coords)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    local crossingName = crossingHash ~= 0 and GetStreetNameFromHashKey(crossingHash) or nil
    return streetName, crossingName
end

--- Check if player is in a vehicle
---@return boolean
function Utils.isInVehicle()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end

--- Get the vehicle the player is currently in
---@return number? vehicle Vehicle entity handle
function Utils.getCurrentVehicle()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        return GetVehiclePedIsIn(ped, false)
    end
    return nil
end

return Utils
