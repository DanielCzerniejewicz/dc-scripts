-- natywny ping / powiadomienia
RegisterNetEvent('pingNotification:show')
AddEventHandler('pingNotification:show', function(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, true)
end)

-- Event do dodawania broni
RegisterNetEvent("inventory:addWeapon")
AddEventHandler("inventory:addWeapon", function(weaponId, ammo)
    TriggerServerEvent("inventory:addWeapon", weaponId, ammo or 0)
end)

-- Event do dodawania itemów
RegisterNetEvent("inventory:addItem")
AddEventHandler("inventory:addItem", function(itemId, amount)
    TriggerServerEvent("inventory:addItem", itemId, amount or 1)
end)
