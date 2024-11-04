local Config = Config or {}

if Config.Framework == 'esx' then
    ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
end

local vehiclesCache = {}

RegisterServerEvent('vehicle:lockVehicle')
AddEventHandler('vehicle:lockVehicle', function(plate, vehicleNetId)
    local xPlayer

    if Config.Framework == 'esx' then
        xPlayer = ESX.GetPlayerFromId(source)
    elseif Config.Framework == 'qb' then
        xPlayer = QBCore.Functions.GetPlayer(source)
    end

    if not vehiclesCache[plate] then
        if Config.Framework == 'esx' then
            local result = MySQL.Sync.fetchAll('SELECT owner FROM owned_vehicles WHERE plate = @plate', {
                ['@plate'] = plate
            })
            if result and result[1] then
                vehiclesCache[plate] = result[1].owner
            end
        elseif Config.Framework == 'qb' then
            local result = MySQL.Sync.fetchAll('SELECT citizenid FROM player_vehicles WHERE plate = @plate', {
                ['@plate'] = plate
            })
            if result and result[1] then
                vehiclesCache[plate] = result[1].citizenid
            end
        end
    end

    if vehiclesCache[plate] and vehiclesCache[plate] == (Config.Framework == 'esx' and xPlayer.identifier or xPlayer.PlayerData.citizenid) then
        local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
        if DoesEntityExist(vehicle) then
            local lockStatus = GetVehicleDoorLockStatus(vehicle)

            if lockStatus == 0 or lockStatus == 1 then
                SetVehicleDoorsLocked(vehicle, 2)
                TriggerClientEvent('carlock:CarLockedEffect', -1, vehicleNetId, true)
                TriggerClientEvent('carlock:PlayLockAnimation', xPlayer.source, true)
            elseif lockStatus == 2 or lockStatus == 3 then
                SetVehicleDoorsLocked(vehicle, 1)
                TriggerClientEvent('carlock:CarLockedEffect', -1, vehicleNetId, false)
                TriggerClientEvent('carlock:PlayLockAnimation', xPlayer.source, false)
            else
                SetVehicleDoorsLocked(vehicle, 1)
                TriggerClientEvent('carlock:CarLockedEffect', -1, vehicleNetId, false)
                TriggerClientEvent('carlock:PlayLockAnimation', xPlayer.source, false)
            end
        end
    else
        TriggerClientEvent('ox_lib:notify', xPlayer.source, {
            description = 'No vehicle nearby',
            icon = 'key',
            iconColor = '#ff0000'
        })
    end
end)
