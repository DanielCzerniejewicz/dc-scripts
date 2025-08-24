local defaultInventory = {
    { id = "bread", label = "Chleb", amount = 5, type = "item" },
    { id = "water", label = "Woda", amount = 3, type = "item" }
}

-- Załaduj inventory gracza
RegisterServerEvent('inventory:loadInventory')
AddEventHandler('inventory:loadInventory', function()
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)

    MySQL.Async.fetchAll('SELECT inventory FROM player_inventory WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        local inv = {}
        if result[1] and result[1].inventory then
            inv = json.decode(result[1].inventory) or defaultInventory
        else
            for _, v in ipairs(defaultInventory) do
                table.insert(inv, v)
            end
        end
        TriggerClientEvent('inventory:setInventory', src, inv)
    end)
end)

-- Zapisz inventory gracza
RegisterServerEvent('inventory:saveInventory')
AddEventHandler('inventory:saveInventory', function(inv)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)

    MySQL.Async.execute([[
        INSERT INTO player_inventory (identifier, inventory)
        VALUES (@identifier, @inventory)
        ON DUPLICATE KEY UPDATE inventory = @inventory
    ]], {
        ['@identifier'] = identifier,
        ['@inventory'] = json.encode(inv or {})
    })
end)

-- Synchronizacja broni z PED-em
RegisterServerEvent('inventory:syncPedWeapons')
AddEventHandler('inventory:syncPedWeapons', function(weapons)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)

    MySQL.Async.fetchAll('SELECT inventory FROM player_inventory WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        local inv = {}
        if result[1] and result[1].inventory then
            inv = json.decode(result[1].inventory) or {}
        else
            for _, v in ipairs(defaultInventory) do
                table.insert(inv, v)
            end
        end

        local pedMap = {}
        for _, w in ipairs(weapons or {}) do
            pedMap[w.id] = { ammo = tonumber(w.ammo) or 0 }
        end

        for i = #inv, 1, -1 do
            local item = inv[i]
            if item.type == "weapon" then
                local pedEntry = pedMap[item.id]
                if pedEntry then
                    local hasAmmoItem = false
                    for _, a in ipairs(inv) do
                        if a.type == "ammo" and a.weaponId == item.id then
                            hasAmmoItem = true
                            a.amount = pedEntry.ammo
                            break
                        end
                    end
                    if not hasAmmoItem then
                        table.insert(inv, {
                            id = item.id.."_ammo",
                            label = "Amunicja do " .. (item.label or item.id),
                            amount = pedEntry.ammo,
                            type = "ammo",
                            weaponId = item.id
                        })
                    end
                    pedMap[item.id] = nil
                else
                    table.remove(inv, i)
                end
            end
        end

        for pedWeaponId, pedWeaponData in pairs(pedMap) do
            table.insert(inv, {
                id = pedWeaponId,
                label = "Broń: " .. pedWeaponId,
                amount = 1,
                type = "weapon"
            })
            table.insert(inv, {
                id = pedWeaponId.."_ammo",
                label = "Amunicja do " .. pedWeaponId,
                amount = pedWeaponData.ammo,
                type = "ammo",
                weaponId = pedWeaponId
            })
        end

        MySQL.Async.execute([[
            INSERT INTO player_inventory (identifier, inventory)
            VALUES (@identifier, @inventory)
            ON DUPLICATE KEY UPDATE inventory = @inventory
        ]], {
            ['@identifier'] = identifier,
            ['@inventory'] = json.encode(inv)
        })

        TriggerClientEvent('inventory:setInventory', src, inv)
    end)
end)
