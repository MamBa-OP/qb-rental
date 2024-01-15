local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-rental:server:pricecheck', function(vehicleHash, vehiclePrice)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  local info = {}
  info.plate = vehiclePrice
  info.model = vehicleHash

  local cashBalance = Player.PlayerData.money["cash"]
  local bankBalance = Player.PlayerData.money["bank"]

  if cashBalance >= vehiclePrice then
    Player.Functions.RemoveMoney("cash", vehiclePrice)
    TriggerClientEvent("QBCore:Notify", src, "You paid " .. vehiclePrice .. " $ from cash", "success")
    TriggerClientEvent('qb-rental:client:rent', src, { vehicleHash = vehicleHash })

    TriggerClientEvent('inventory:client:ItemBox', src,  QBCore.Shared.Items["rentalpapers"], 'add')
    Player.Functions.AddItem('rentalpapers', 1, false, info)

  elseif bankBalance >= vehiclePrice then
    Player.Functions.RemoveMoney("bank", vehiclePrice)
    TriggerClientEvent("QBCore:Notify", src, "You paid " .. vehiclePrice .. " $ from bank", "success")
    TriggerClientEvent('qb-rental:client:rent', src, { vehicleHash = vehicleHash })

    TriggerClientEvent('inventory:client:ItemBox', src,  QBCore.Shared.Items["rentalpapers"], 'add')
    Player.Functions.AddItem('rentalpapers', 1, false, info)
  else
    TriggerClientEvent("QBCore:Notify", src, "You don't have enough money in cash or bank", "error")
  end
end)

RegisterNetEvent('qb-rental:server:deletepapers', function()
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)

  TriggerClientEvent('inventory:client:ItemBox', src,  QBCore.Shared.Items["rentalpapers"], 'remove')
  Player.Functions.RemoveItem('rentalpapers', 1)
end)