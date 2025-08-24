RegisterNetEvent('pingNotification:show')
AddEventHandler('pingNotification:show', function(message)
    SendNUIMessage({
        action = "showPing",
        text = message
    })
end)
