--- Qbox framework bridge (native target)
--- Qbox is our primary framework — this bridge is the reference implementation.
---@class QboxBridge
local Qbox = {}

--- Get player data (server-side)
---@param source number Player server ID
---@return HelixPlayer?
function Qbox.GetPlayer(source)
    if not IsDuplicityVersion() then
        return nil
    end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        return nil
    end

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

--- Get player money
---@param source number
---@param moneyType? string Default: 'cash'
---@return number
function Qbox.GetPlayerMoney(source, moneyType)
    if not IsDuplicityVersion() then
        return 0
    end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        return 0
    end

    moneyType = moneyType or 'cash'
    return player.PlayerData.money[moneyType] or 0
end

--- Get player job
---@param source number
---@return HelixJob?
function Qbox.GetPlayerJob(source)
    if not IsDuplicityVersion() then
        return nil
    end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        return nil
    end

    return {
        name = player.PlayerData.job.name,
        label = player.PlayerData.job.label,
        grade = player.PlayerData.job.grade.level,
        gradeLabel = player.PlayerData.job.grade.name,
        onDuty = player.PlayerData.job.onduty,
    }
end

--- Get player identifier
---@param source number
---@return string?
function Qbox.GetPlayerIdentifier(source)
    if not IsDuplicityVersion() then
        return nil
    end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        return nil
    end

    return player.PlayerData.citizenid
end

--- Add money to player
---@param source number
---@param amount number
---@param moneyType? string Default: 'cash'
---@return boolean
function Qbox.AddMoney(source, amount, moneyType)
    if not IsDuplicityVersion() then
        return false
    end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        return false
    end

    moneyType = moneyType or 'cash'
    return player.Functions.AddMoney(moneyType, amount, 'helix_lib')
end

--- Remove money from player
---@param source number
---@param amount number
---@param moneyType? string Default: 'cash'
---@return boolean
function Qbox.RemoveMoney(source, amount, moneyType)
    if not IsDuplicityVersion() then
        return false
    end

    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        return false
    end

    moneyType = moneyType or 'cash'
    return player.Functions.RemoveMoney(moneyType, amount, 'helix_lib')
end

--- Check if player has item
---@param source number
---@param item string Item name
---@param count? number Minimum count (default 1)
---@return boolean
function Qbox.HasItem(source, item, count)
    if not IsDuplicityVersion() then
        return false
    end

    count = count or 1

    -- Prefer ox_inventory if available
    if GetResourceState('ox_inventory') == 'started' then
        local itemData = exports.ox_inventory:GetItem(source, item, nil, false)
        if not itemData then
            return false
        end
        return (itemData.count or 0) >= count
    end

    -- Fallback to Qbox inventory
    local player = exports.qbx_core:GetPlayer(source)
    if not player then
        return false
    end

    local itemData = player.Functions.GetItemByName(item)
    if not itemData then
        return false
    end
    return (itemData.amount or 0) >= count
end

--- Send notification to player
---@param source number
---@param message string
---@param type? string 'success'|'error'|'warning'|'info'
---@param duration? number ms
function Qbox.Notify(source, message, type, duration)
    if IsDuplicityVersion() then
        TriggerClientEvent('helix_lib:notify', source, message, type or 'info', duration or 5000)
    else
        -- Client-side: use ox_lib if available, else fallback
        if GetResourceState('ox_lib') == 'started' then
            exports.ox_lib:notify({
                description = message,
                type = type or 'info',
                duration = duration or 5000,
            })
        else
            -- Fallback to QBCore notification
            TriggerEvent('QBCore:Notify', message, type or 'info', duration or 5000)
        end
    end
end

return Qbox
