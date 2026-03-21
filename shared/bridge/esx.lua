--- ESX framework bridge
--- Maps ESX Legacy API to the unified Helix bridge interface.
---@class ESXBridge
local ESX = {}

local ESXObj = nil

--- Get the ESX shared object (cached)
---@return table
local function getESX()
    if not ESXObj then
        ESXObj = exports['es_extended']:getSharedObject()
    end
    return ESXObj
end

---@param source number
---@return HelixPlayer?
function ESX.GetPlayer(source)
    if not IsDuplicityVersion() then return nil end

    local xPlayer = getESX().GetPlayerFromId(source)
    if not xPlayer then return nil end

    return {
        source = source,
        name = xPlayer.getName(),
        identifier = xPlayer.getIdentifier(),
        job = {
            name = xPlayer.getJob().name,
            label = xPlayer.getJob().label,
            grade = xPlayer.getJob().grade,
            gradeLabel = xPlayer.getJob().grade_label,
            onDuty = true, -- ESX doesn't have native on-duty toggle
        },
        gang = nil, -- ESX doesn't have a native gang system
        money = {
            cash = xPlayer.getMoney(),
            bank = xPlayer.getAccount('bank').money,
            crypto = 0, -- ESX doesn't have native crypto
        },
    }
end

---@param source number
---@param moneyType? string
---@return number
function ESX.GetPlayerMoney(source, moneyType)
    if not IsDuplicityVersion() then return 0 end

    local xPlayer = getESX().GetPlayerFromId(source)
    if not xPlayer then return 0 end

    moneyType = moneyType or 'cash'

    if moneyType == 'cash' then
        return xPlayer.getMoney()
    elseif moneyType == 'bank' then
        return xPlayer.getAccount('bank').money
    else
        local account = xPlayer.getAccount(moneyType)
        return account and account.money or 0
    end
end

---@param source number
---@return HelixJob?
function ESX.GetPlayerJob(source)
    if not IsDuplicityVersion() then return nil end

    local xPlayer = getESX().GetPlayerFromId(source)
    if not xPlayer then return nil end

    local job = xPlayer.getJob()
    return {
        name = job.name,
        label = job.label,
        grade = job.grade,
        gradeLabel = job.grade_label,
        onDuty = true,
    }
end

---@param source number
---@return string?
function ESX.GetPlayerIdentifier(source)
    if not IsDuplicityVersion() then return nil end

    local xPlayer = getESX().GetPlayerFromId(source)
    if not xPlayer then return nil end

    return xPlayer.getIdentifier()
end

---@param source number
---@param amount number
---@param moneyType? string
---@return boolean
function ESX.AddMoney(source, amount, moneyType)
    if not IsDuplicityVersion() then return false end

    local xPlayer = getESX().GetPlayerFromId(source)
    if not xPlayer then return false end

    moneyType = moneyType or 'cash'

    if moneyType == 'cash' then
        xPlayer.addMoney(amount, 'helix_lib')
    elseif moneyType == 'bank' then
        xPlayer.addAccountMoney('bank', amount, 'helix_lib')
    else
        xPlayer.addAccountMoney(moneyType, amount, 'helix_lib')
    end

    return true
end

---@param source number
---@param amount number
---@param moneyType? string
---@return boolean
function ESX.RemoveMoney(source, amount, moneyType)
    if not IsDuplicityVersion() then return false end

    local xPlayer = getESX().GetPlayerFromId(source)
    if not xPlayer then return false end

    moneyType = moneyType or 'cash'

    if moneyType == 'cash' then
        if xPlayer.getMoney() < amount then return false end
        xPlayer.removeMoney(amount, 'helix_lib')
    elseif moneyType == 'bank' then
        if xPlayer.getAccount('bank').money < amount then return false end
        xPlayer.removeAccountMoney('bank', amount, 'helix_lib')
    else
        local account = xPlayer.getAccount(moneyType)
        if not account or account.money < amount then return false end
        xPlayer.removeAccountMoney(moneyType, amount, 'helix_lib')
    end

    return true
end

---@param source number
---@param item string
---@param count? number
---@return boolean
function ESX.HasItem(source, item, count)
    if not IsDuplicityVersion() then return false end

    count = count or 1

    if GetResourceState('ox_inventory') == 'started' then
        local itemData = exports.ox_inventory:GetItem(source, item, nil, false)
        if not itemData then return false end
        return (itemData.count or 0) >= count
    end

    local xPlayer = getESX().GetPlayerFromId(source)
    if not xPlayer then return false end

    local itemData = xPlayer.getInventoryItem(item)
    if not itemData then return false end
    return (itemData.count or 0) >= count
end

---@param source number
---@param message string
---@param type? string
---@param duration? number
function ESX.Notify(source, message, type, duration)
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
            TriggerEvent('esx:showNotification', message, type, duration)
        end
    end
end

return ESX
