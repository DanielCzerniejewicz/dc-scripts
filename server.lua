RegisterCommand('ping', function(source, args, rawCommand)
    local src = source
    if #args < 1 then
        TriggerClientEvent('pingNotification:show', src, "Użycie: /ping <wiadomość>")
        return
    end

    local message = table.concat(args, " ")
    TriggerClientEvent('pingNotification:show', src, message)
end, false)
