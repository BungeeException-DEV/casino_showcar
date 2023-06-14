spawned = nil

Citizen.CreateThread(function()
    while true do
        local pCoords = GetEntityCoords(PlayerPedId())
        for i=1, #Auto do
            if #(pCoords - Auto[i].pos) < DrawDistance then
                if Auto[i].spawned == nil then
                    SpawnLocalCar(i)
                end
            else
                DeleteEntity(Auto[i].spawned)
                Auto[i].spawned = nil
            end
            Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        for i=1, #Auto do
            if Auto[i].spawned ~= nil and Auto[i].spin then
                SetEntityHeading(Auto[i].spawned, GetEntityHeading(Auto[i].spawned) - 0.3)
            end
        end
        Wait(5)
    end
end)

function SpawnLocalCar(i)
    Citizen.CreateThread(function()
        local hash = GetHashKey(Auto[i].model)
        RequestModel(hash)
        local tryAgain = 0
        while not HasModelLoaded(hash) do
            tryAgain = tryAgain + 1
            if tryAgain > 2000 then return end
            Wait(0)
        end
        local vehicle = CreateVehicle(hash, Auto[i].pos.x, Auto[i].pos.y, Auto[i].pos.z-1,Auto[i].heading, false, false)
        SetModelAsNoLongerNeeded(hash)
        SetVehicleEngineOn(vehicle, false)
        SetVehicleBrakeLights(vehicle, false)
        SetVehicleLights(vehicle, 0)
        SetVehicleLightsMode(vehicle, 0)
        SetVehicleInteriorlight(vehicle, false)
        SetVehicleOnGroundProperly(vehicle)
        FreezeEntityPosition(vehicle, true)
        SetVehicleCanBreak(vehicle, true)
        SetVehicleFullbeam(vehicle, false)
        if autoGodmode then
        SetVehicleReceivesRampDamage(vehicle, true)
        RemoveDecalsFromVehicle(vehicle)
        SetVehicleCanBeVisiblyDamaged(vehicle, true)
        SetVehicleLightsCanBeVisiblyDamaged(vehicle, true)
        SetVehicleWheelsCanBreakOffWhenBlowUp(vehicle, false)  
        SetDisableVehicleWindowCollisions(vehicle, true)    
        SetEntityInvincible(vehicle, true)
        end
        if AutoLock then
            SetVehicleDoorsLocked(vehicle, 2)
        end
        SetVehicleNumberPlateText(vehicle, Auto[i].plate)
        Auto[i].spawned = vehicle
    end)
end

AddEventHandler('onResourceStop', function (res)
    if res == GetCurrentResourceName() then
        for i=1, #Auto do
            if Auto[i].spawned ~= nil then
                DeleteEntity(Auto[i].spawned)
            end
        end
    end
end)