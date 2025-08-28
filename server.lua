local blipsCache = {}

-- Ładowanie blipów przy starcie resource’a
AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        MySQL.Async.fetchAll("SELECT * FROM blips", {}, function(results)
            blipsCache = results or {}
            TriggerClientEvent("blips:load", -1, blipsCache)
            print(("[BLIPS] Załadowano %s blipów z bazy."):format(#blipsCache))
        end)
    end
end)

-- Komenda do dodawania blipa
RegisterCommand("addblip", function(source, args)
    if source == 0 then
        print("Ta komenda jest tylko dla graczy.")
        return
    end

    local ped = GetPlayerPed(source)
    local x, y, z = table.unpack(GetEntityCoords(ped))
    local sprite = tonumber(args[1]) or 280
    local color = tonumber(args[2]) or 2
    local scale = tonumber(args[3]) or 0.9
    local name = args[4] or "Blip"

    MySQL.Async.insert(
        "INSERT INTO blips (x, y, z, sprite, color, scale, name) VALUES (@x, @y, @z, @sprite, @color, @scale, @name)",
        {
            ['@x'] = x, ['@y'] = y, ['@z'] = z,
            ['@sprite'] = sprite, ['@color'] = color,
            ['@scale'] = scale, ['@name'] = name
        },
        function(id)
            if id then
                local newBlip = {
                    id = id, x = x, y = y, z = z,
                    sprite = sprite, color = color,
                    scale = scale, name = name
                }
                table.insert(blipsCache, newBlip)
                TriggerClientEvent("blips:load", -1, blipsCache)
                TriggerClientEvent("chat:addMessage", source, { args = {"^2SYSTEM", "Blip zapisany i rozesłany!"}})
            end
        end
    )
end)

-- Wysyłanie cache nowym graczom
AddEventHandler("playerJoining", function(playerId)
    TriggerClientEvent("blips:load", playerId, blipsCache)
end)
