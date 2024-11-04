Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsTryingToEnter(ped)
        if DoesEntityExist(vehicle) then
            local lockStatus = GetVehicleDoorLockStatus(vehicle)

            if lockStatus == 2 or lockStatus == 7 then
                SetVehicleDoorsLocked(vehicle, 2)
                SetVehicleDoorsLockedForAllPlayers(vehicle, true)
            end

            local driverPed = GetPedInVehicleSeat(vehicle, -1)
            if driverPed ~= 0 and not IsPedAPlayer(driverPed) then
                -- taking out npc from car event here
            end
        end
    end
end)

RegisterCommand("engine", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= nil and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, 0) then
        SetVehicleEngineOn(vehicle, (not GetIsVehicleEngineRunning(vehicle)), false, true)
    end
    lib.notify({
        description = 'Engine Started/Stopped',
        icon = 'key',
        iconColor = '#58b100'
    })
end, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 182) then
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            if vehicle == 0 then
                local playerCoords = GetEntityCoords(playerPed)
                vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 50.0, 0, 71)
            end

            if DoesEntityExist(vehicle) then
                local plate = GetVehicleNumberPlateText(vehicle)
                TriggerServerEvent('vehicle:lockVehicle', plate, VehToNet(vehicle))
            end
        end
    end
end)

RegisterNetEvent('carlock:CarLockedEffect')
AddEventHandler('carlock:CarLockedEffect', function(vehicleNetId, locked)
    local vehicle = NetToVeh(vehicleNetId)
    if DoesEntityExist(vehicle) then
        
        NetworkRequestControlOfEntity(vehicle)
        while not NetworkHasControlOfEntity(vehicle) do
            Citizen.Wait(0)
        end

        if locked then
            SetVehicleDoorsLocked(vehicle, 2)
        else
            SetVehicleDoorsLocked(vehicle, 1)
        end
        
        local newLockStatus = GetVehicleDoorLockStatus(vehicle)

        SetVehicleDoorsLockedForAllPlayers(vehicle, locked)

        if locked then
            lib.notify({
                description = 'Vehicle locked',
                icon = 'key',
                iconColor = '#58b100'
            })
        else
            lib.notify({
                description = 'Vehicle unlocked',
                icon = 'key',
                iconColor = '#58b100'
            })
        end
        TriggerEvent('carlock:FlashVehicleLights', vehicle)
    end
end)

RegisterNetEvent('carlock:PlayLockAnimation')
AddEventHandler('carlock:PlayLockAnimation', function(isLocking)
    local ply = PlayerPedId()
    RequestAnimDict("anim@heists@keycard@")
    while not HasAnimDictLoaded("anim@heists@keycard@") do
        Wait(0)
    end
    TaskPlayAnim(ply, "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
    Citizen.Wait(600)
    ClearPedTasks(ply)
    PlaySoundFrontend(-1, 'Hack_Success', 'DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS', 0)
end)

RegisterNetEvent('carlock:FlashVehicleLights')
AddEventHandler('carlock:FlashVehicleLights', function(vehicle)
    SetVehicleLights(vehicle, 2)
    SetVehicleBrakeLights(vehicle, true)
    Citizen.Wait(200)
    SetVehicleBrakeLights(vehicle, false)
    Citizen.Wait(200)
    SetVehicleBrakeLights(vehicle, true)
    Citizen.Wait(200)
    SetVehicleBrakeLights(vehicle, false)
    SetVehicleLights(vehicle, 0)
end)
