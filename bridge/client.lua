Framework = nil

PlayerLoaded = nil

local function InitializeFramework()
    if GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        Framework = 'esx'

        RegisterNetEvent('esx:playerLoaded', function(xPlayer)
            PlayerLoaded = true
            Wait(1000)
            TriggerEvent('zombie_killboard:onPlayerLoaded')
        end)

        RegisterNetEvent('esx:onPlayerLogout', function()
            PlayerLoaded = false
        end)

        AddEventHandler('onResourceStart', function(resourceName)
            if GetCurrentResourceName() ~= resourceName then return end
            PlayerLoaded = true
            Wait(1000)
            TriggerEvent('zombie_killboard:onPlayerLoaded')
        end)
    elseif GetResourceState('qbx_core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'qbx'

        AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            PlayerLoaded = true
            Wait(1000)
            TriggerEvent('zombie_killboard:onPlayerLoaded')
        end)

        RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
            PlayerLoaded = false
        end)

        AddEventHandler('onResourceStart', function(resourceName)
            if GetCurrentResourceName() ~= resourceName then return end
            PlayerLoaded = true
            Wait(1000)
            TriggerEvent('zombie_killboard:onPlayerLoaded')
        end)
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        Framework = 'qb'

        AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            PlayerLoaded = true
            Wait(1000)
            TriggerEvent('zombie_killboard:onPlayerLoaded')
        end)

        RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
            PlayerLoaded = false
        end)

        AddEventHandler('onResourceStart', function(resourceName)
            if GetCurrentResourceName() ~= resourceName then return end
            PlayerLoaded = true
            Wait(1000)
            TriggerEvent('zombie_killboard:onPlayerLoaded')
        end)
    end
end

function serverCallback(name, cb, ...)
    if Framework == 'esx' then
        ESX.TriggerServerCallback(name, cb, ...)
    elseif Framework == 'qb' or Framework == 'qbx' then
        QBCore.Functions.TriggerCallback(name, cb, ...)
    end
end

function awaitServerCallback(name, ...)
    local args = { ... }
    local promise = promise.new()
    if Framework == 'esx' then
        ESX.TriggerServerCallback(name, function(...)
            promise:resolve(...)
        end, table.unpack(args))
    elseif Framework == 'qb' or Framework == 'qbx' then
        QBCore.Functions.TriggerCallback(name, function(...)
            promise:resolve(...)
        end, table.unpack(args))
    end
    return table.unpack({ Citizen.Await(promise) })
end

InitializeFramework()
