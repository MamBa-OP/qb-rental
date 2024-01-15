local QBCore = exports['qb-core']:GetCoreObject()

local display = false
local isRenting = false
local isCooldownActive = false
local currentVehicle = nil


function SendVehiclesToNUI()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "setVehicles",
        vehicles = Config.Vehicles
    })
end

function SetDisplay(_display)
    display = _display
    SetNuiFocus(display, display)
    SendNUIMessage({
        type = "setDisplay",
        value = display
    })
    if display then
        SendVehiclesToNUI()
    end
end

RegisterNUICallback('close', function(data, cb)
    SetDisplay(false)
    cb('ok')
end)

RegisterNUICallback('rent', function(data, cb)
    if not isCooldownActive then
        local vehicle = data.vehicleHash
        local price = data.vehiclePrice

        TriggerServerEvent('qb-rental:server:pricecheck', vehicle, price)
        SetDisplay(false)
        cb('ok')
        
    else
        QBCore.Functions.Notify('You must wait before renting another vehicle', 'info', 5000)
    end
end)

RegisterNetEvent('qb-rental:client:rent')
AddEventHandler('qb-rental:client:rent', function(data)
    local vehicle = data.vehicleHash
    local coords = Config.CarSpawn[1]
    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
        SetVehicleNumberPlateText(veh, Config.PlateText)
        exports[Config.Fuel]:SetFuel(veh, 100.0)
        SetVehicleFixed(veh)
        isCooldownActive = true
        SetEntityAsMissionEntity(veh, true, true)
        TaskWarpPedIntoVehicle(GetPlayerPed(-1), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
    end, coords, true)
end)

RegisterNetEvent('qb-rental:client:openMenu')
AddEventHandler('qb-rental:client:openMenu', function()
    SetDisplay(true)
end)


CreateThread(function()
    if Config.UseTarget then
        exports['qb-target']:AddTargetModel(Config.Ped, {
            options = {
            {
                type = "client",
                event = "qb-rental:client:openMenu",
                icon = 'fas fa-clipboard',
                label = 'Rent car',
            },
            {
                type = "client",
                event = "qb-rental:client:deliverVehicle",
                icon = 'fas fa-clipboard',
                label = 'Deliver back car',
            }
        },
        distance = 2.5,
        })
    else
        while true do
            local v = Config.PedSpawn[1]
            local pos = GetEntityCoords(PlayerPedId())
            local Distance = #(pos - vector3(v.x, v.y, v.z))
            
            if Distance < 2 then
                exports['qb-core']:DrawText("PRESS [E] TO OPEN MENU", 'left')
                if IsControlJustPressed(0, 38) then
                    exports['qb-core']:KeyPressed(38)
                    TriggerEvent('qb-rental:mainMenu')
                    exports['qb-core']:HideText()
                end
                Wait(500)
            else
                exports['qb-core']:HideText()
            end

            Wait(1000)
        end
    end
end)


RegisterNetEvent('qb-rental:mainMenu', function(data)
    local mainMenu = {
        {
            header = "Rental Menu",
            txt='',
            icon = 'fas fa-city',
            isMenuHeader = true,
        },
        {
            header = "Rent Vehicle",
            txt='',
            icon = 'fas fa-car',
            params = {
                event = 'qb-rental:client:openMenu'
            }
        },
        {
            header = "Return Vehicle",
            txt='',
            icon = 'fas fa-rotate-left',
            params = {
                event = 'qb-rental:client:deliverVehicle'
            }
        },
        {
            header = 'Close',
            icon = 'fas fa-xmark',
            params = {}
        },
    }
    exports['qb-menu']:openMenu(mainMenu)
end)


Citizen.CreateThread(function()
    Wait(2000)
    for i=1, #Config.PedSpawn do
      local pedModel = Config.Ped
      local pedCoords = Config.PedSpawn[i]
      local pedHeading = pedCoords.w
      local pedHash = GetHashKey(pedModel)
  
      RequestModel(pedHash)
      while not HasModelLoaded(pedHash) do
        Wait(1)
      end
      
      local ped = CreatePed(4, pedHash, pedCoords.x, pedCoords.y, pedCoords.z - 1.0, pedHeading, false, true)
      Wait(1000)
      SetEntityAsMissionEntity(ped, true, true)
      SetEntityInvincible(ped, true)
      SetBlockingOfNonTemporaryEvents(ped, true)
      FreezeEntityPosition(ped, true)
      TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_MOBILE_UPRIGHT", 0, true)
      SetModelAsNoLongerNeeded(pedHash)
    end
end)

RegisterNetEvent('qb-rental:client:deliverVehicle')
AddEventHandler('qb-rental:client:deliverVehicle', function()
    isCooldownActive = false
    local car = GetVehiclePedIsIn(PlayerPedId(),true)
    DeleteVehicle(car)
    DeleteEntity(car)
    QBCore.Functions.Notify('The vehicle has been returned!', 'success', 5000)
    TriggerServerEvent('qb-rental:server:deletepapers')
end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.PedSpawn[1])
	SetBlipSprite(blip, 326) 
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.7)
	SetBlipAsShortRange(blip, true)
	SetBlipColour(blip, 2)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName("Vehicle Rental")
    EndTextCommandSetBlipName(blip)
end)
