--- QBCore framework bridge
--- Maps QBCore API to the unified Helix bridge interface.
--- Structurally near-identical to Qbox (Qbox is a QBCore fork) but uses
--- the qb-core export path instead of qbx_core.
---@class QBCoreBridge
local QBCore = {}

local QBCoreObj = nil

--- Get the QBCore shared object (cached)
---@return table
local function getQB()
    if not QBCoreObj then
        QBCoreObj = exports['qb-core']:GetCoreObject()
    end
    return QBCoreObj
end

---@param source number
---@return HelixPlayer?
function QBCore.GetPlayer(source)
    if not IsDuplicityVersion() then return nil end

    local player = getQB().Functions.GetPlayer(source)
    if not player then return nil end

    return {
        source = source,
        name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
        identifier = player.PlayerData.citizenid,
        job = {
            name = player.PlayerData.job.name,
            label = player.PlayerData.job.label,
            grade = player.PlayerData.job.grade.level,
            gradeLabel = player.PlayerData.job.grade.name,
            onDuty = player.PlayerData.job.onduty,
        },
        gang = player.PlayerData.gang and {
            name = player.PlayerData.gang.name,
            label = player.PlayerData.gang.label,
            grade = player.PlayerData.gang.grade.level,
            gradeLabel = player.PlayerData.gang.grade.name,
        } or nil,
        money = {
            cash = player.PlayerData.money.cash or 0,
            bank = player.PlayerData.money.bank or 0,
            crypto = player.PlayerData.money.crypto or 0,
        },
    }
end

---@param source number
---@param moneyType? string
---@return number
function QBCore.GetPlayerMoney(source, moneyType)
    if not IsDuplicityVersion() then return 0 end

    local player = getQB().Functions.GetPlayer(source)
    if not player then return 0 end

    moneyType = moneyType or 'cash'
    return player.PlayerData.money[moneyType] or 0
end

---@param source number
---@return HelixJob?
function QBCore.GetPlayerJob(source)
    if not IsDuplicityVersion() then return nil end

    local player = getQB().Functions.GetPlayer(source)
    if not player then return nil end

    return {
        name = player.PlayerData.job.name,
        label = player.PlayerData.job.label,
        grade = player.PlayerData.job.grade.level,
        gradeLabel = player.PlayerData.job.grade.name,
        onDuty = player.PlayerData.job.onduty,
    }
end

---@param source number
---@return string?
function QBCore.GetPlayerIdentifier(source)
    if not IsDuplicityVersion() then return nil end

    local player = getQB().Functions.GetPlayer(source)
    if not player then return nil end

    return player.PlayerData.citizenid
end

---@param source number
---@param amount number
---@param moneyType? string
---@return boolean
function QBCore.AddMoney(source, amount, moneyType)
    if not IsDuplicityVersion() then return false end

    local player = getQB().Functions.GetPlayer(source)
    if not player then return false end

    moneyType = moneyType or 'cash'
    return player.Functions.AddMoney(moneyType, amount, 'helix_lib')
end

---@param source number
---@param amount number
---@param moneyType? string
---@return boolean
function QBCore.RemoveMoney(source, amount, moneyType)
    if not IsDuplicityVersion() then return false end

    local player = getQB().Functions.GetPlayer(source)
    if not player then return false end

    moneyType = moneyType or 'cash'
    return player.Functions.RemoveMoney(moneyType, amount, 'helix_lib')
end

---@param source number
---@param item string
---@param count? number
---@return boolean
function QBCore.HasItem(source, item, count)
    if not IsDuplicityVersion() then return false end

    count = count or 1

    if GetResourceState('ox_inventory') == 'started' then
        local itemData = exports.ox_inventory:GetItem(source, item, nil, false)
        if not itemData then return false end
        return (itemData.count or 0) >= count
    end

    local player = getQB().Functions.GetPlayer(source)
    if not player then return false end

    local itemData = player.Functions.GetItemByName(item)
    if not itemData then return false end
    return (itemData.amount or 0) >= count
end

---@param source number
---@param message string
---@param type? string
---@param duration? number
function QBCore.Notify(source, message, type, duration)
    if IsDuplicityVersion() then
        TriggerClientEvent('helix_lib:notify', source, message, type or 'info', duration or 5000)
    else
        if GetResourceState('ox_lib') == 'started' then
            exports.ox_lib:notify({
                description = message,
                type = type or 'info',
                duration = duration or 5000,
            })
        else
            TriggerEvent('QBCore:Notify', message, type or 'info', duration or 5000)
        end
    end
end

return QBCore
