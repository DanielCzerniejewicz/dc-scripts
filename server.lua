-- Funkcja sprawdzająca admina
local function isAdmin(playerId, cb)
    local license
    for i = 0, GetNumPlayerIdentifiers(playerId)-1 do
        local id = GetPlayerIdentifier(playerId, i)
        if string.sub(id, 1, 8) == "license:" then
            license = id
            break
        end
    end

    if not license then
        cb(false)
        return
    end

    MySQL.Async.fetchScalar('SELECT 1 FROM admins WHERE identifier = @identifier LIMIT 1', {
        ['@identifier'] = license
    }, function(result)
        cb(result ~= nil)
    end)
end

-- Komenda /giveitem [ID] [ITEM] [ILOŚĆ]
RegisterCommand("giveitem", function(src, args, raw)
    if #args < 3 then
        TriggerClientEvent("pingNotification:show", src, "Użycie: /giveitem [id] [item] [ilość]")
        return
    end

    local targetId = tonumber(args[1])
    local item = tostring(args[2])
    local amount = tonumber(args[3]) or 1

    if not GetPlayerName(targetId) then
        TriggerClientEvent("pingNotification:show", src, "Nie znaleziono gracza o ID " .. args[1])
        return
    end

    isAdmin(src, function(admin)
        if admin then
            if string.sub(item,1,7) == "WEAPON_" then
                TriggerClientEvent("inventory:addWeapon", targetId, item, amount)
                TriggerClientEvent("pingNotification:show", src, "Dałeś broń " .. item .. " graczowi " .. targetId)
                TriggerClientEvent("pingNotification:show", targetId, "Otrzymałeś broń " .. item .. " od admina")
            else
                TriggerClientEvent("inventory:addItem", targetId, item, amount)
                TriggerClientEvent("pingNotification:show", src, "Dałeś " .. amount .. "x " .. item .. " graczowi " .. targetId)
                TriggerClientEvent("pingNotification:show", targetId, "Otrzymałeś " .. amount .. "x " .. item .. " od admina")
            end
        else
            TriggerClientEvent("pingNotification:show", src, "Nie jesteś administratorem!")
        end
    end)
end)
