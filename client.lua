local inventory = {}
local open = false

-- mapa broni GTA V -> polska nazwa
local weaponLabels = {
    WEAPON_KNIFE = "Nóż",
    WEAPON_BAT = "Kij bejsbolowy",
    WEAPON_PISTOL = "Pistolet",
    WEAPON_COMBATPISTOL = "Pistolet bojowy",
    WEAPON_PISTOL50 = "Pistolet .50",
    WEAPON_SMG = "SMG",
    WEAPON_MICROSMG = "Micro SMG",
    WEAPON_ASSAULTRIFLE = "Karabin szturmowy",
    WEAPON_CARBINERIFLE = "Karabinek",
    WEAPON_ADVANCEDRIFLE = "Karabin zaawansowany",
    WEAPON_SPECIALCARBINE = "Karabin specjalny",
    WEAPON_BULLPUPRIFLE = "Karabin bullpup",
    WEAPON_PUMPSHOTGUN = "Strzelba pompa",
    WEAPON_SAWNOFFSHOTGUN = "Obrzyn",
    WEAPON_ASSAULTSHOTGUN = "Strzelba szturmowa",
    WEAPON_SNIPERRIFLE = "Karabin snajperski",
    WEAPON_HEAVYSNIPER = "Ciężki snajper",
    WEAPON_GRENADE = "Granat",
    WEAPON_MOLOTOV = "Koktajl Mołotowa",
    WEAPON_RPG = "RPG",
    WEAPON_GUSENBERG = "Thompson"
}

local WEAPON_LIST = {}
for name, _ in pairs(weaponLabels) do
    table.insert(WEAPON_LIST, name)
end

local function filterInventory(inv)
    local filtered = {}
    for _, item in ipairs(inv) do
        if item.amount and item.amount > 0 then
            filtered[#filtered+1] = item
        end
    end
    return filtered
end

local function getPedWeapons()
    local ped = PlayerPedId()
    local weapons = {}
    for _, weaponName in ipairs(WEAPON_LIST) do
        local hash = GetHashKey(weaponName)
        if HasPedGotWeapon(ped, hash, false) then
            local ammo = GetAmmoInPedWeapon(ped, hash) or 0
            weapons[#weapons+1] = {
                id = weaponName,
                label = weaponLabels[weaponName] or weaponName,
                amount = 1,
                type = "weapon",
                ammo = ammo,
                equipped = true
            }
        end
    end
    return weapons
end

local function updateAmmoItems()
    local ped = PlayerPedId()
    for _, item in ipairs(inventory) do
        if item.type == "weapon" and item.equipped then
            local hash = GetHashKey(item.id)
            local currentAmmo = GetAmmoInPedWeapon(ped, hash)
            local ammoItem
            for _, a in ipairs(inventory) do
                if a.type == "ammo" and a.weaponId == item.id then
                    ammoItem = a
                    break
                end
            end
            if ammoItem then
                ammoItem.amount = currentAmmo  -- aktualizacja, bez dodawania
            else
                table.insert(inventory, {id = item.id.."_ammo", weaponId = item.id, label = item.label.." Ammo", amount = currentAmmo, type = "ammo"})
            end
        end
    end
end

local function giveWeaponsFromInventory()
    local ped = PlayerPedId()
    for _, item in ipairs(inventory) do
        if item.type == "weapon" then
            local hash = GetHashKey(item.id)
            if not HasPedGotWeapon(ped, hash, false) then
                GiveWeaponToPed(ped, hash, 0, false, true)
                -- ustaw ammo
                for _, a in ipairs(inventory) do
                    if a.type == "ammo" and a.weaponId == item.id then
                        SetPedAmmo(ped, hash, a.amount or 0)
                        break
                    end
                end
            end
        end
    end
end

local function applyAmmoFromInventory()
    local ped = PlayerPedId()
    for _, item in ipairs(inventory) do
        if item.type == "ammo" and item.amount > 0 then
            local hash = GetHashKey(item.weaponId)
            SetPedAmmo(ped, hash, item.amount)
        end
    end
end

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('inventory:loadInventory')

    CreateThread(function()
        Wait(500)
        giveWeaponsFromInventory()
        applyAmmoFromInventory()
    end)
end)

RegisterNetEvent('inventory:setInventory')
AddEventHandler('inventory:setInventory', function(data)
    inventory = filterInventory(data or {})
end)

RegisterCommand('toggleInventory', function()
    if open then closeInventory() else openInventory() end
end)
RegisterKeyMapping('toggleInventory', 'Otwórz ekwipunek', 'keyboard', 'f2')

function openInventory()
    open = true
    SetNuiFocus(true, true)
    SendNUIMessage({ type = "open", inventory = inventory })
end

function closeInventory()
    open = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "close" })
end

RegisterNUICallback('useItem', function(data, cb)
    for _, item in ipairs(inventory) do
        if item.id == data.item and item.type == "item" and item.amount > 0 then
            item.amount = item.amount - 1
            break
        end
    end
    inventory = filterInventory(inventory)
    updateAmmoItems()
    TriggerServerEvent('inventory:saveInventory', inventory)
    SendNUIMessage({ type = "open", inventory = inventory })
    cb('ok')
end)

RegisterNUICallback('equipWeapon', function(data, cb)
    local ped = PlayerPedId()
    local weaponId = data.item
    local hash = GetHashKey(weaponId)
    for _, item in ipairs(inventory) do
        if item.id == weaponId and item.type == "weapon" then
            if item.equipped then
                local currentAmmo = GetAmmoInPedWeapon(ped, hash)
                local ammoItem
                for _, a in ipairs(inventory) do
                    if a.type == "ammo" and a.weaponId == weaponId then
                        ammoItem = a
                        break
                    end
                end
                if ammoItem then
                    ammoItem.amount = currentAmmo  -- aktualizacja, nie dodawanie
                else
                    table.insert(inventory, {id = weaponId.."_ammo", weaponId = weaponId, label = item.label.." Ammo", amount = currentAmmo, type = "ammo"})
                end
                RemoveWeaponFromPed(ped, hash)
                item.equipped = false
            else
                GiveWeaponToPed(ped, hash, 0, false, true)
                for _, a in ipairs(inventory) do
                    if a.type == "ammo" and a.weaponId == weaponId then
                        SetPedAmmo(ped, hash, a.amount or 0)
                        break
                    end
                end
                SetCurrentPedWeapon(ped, hash, true)
                item.equipped = true
            end
            break
        end
    end
    updateAmmoItems()
    TriggerServerEvent('inventory:saveInventory', inventory)
    SendNUIMessage({ type = "open", inventory = inventory })
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    inventory = filterInventory(inventory)
    updateAmmoItems()
    TriggerServerEvent('inventory:saveInventory', inventory)
    closeInventory()
    if cb then cb('ok') end
end)

-- auto-sync PED bez nadpisywania inventory
CreateThread(function()
    while true do
        Wait(5000)
        local pedWeapons = getPedWeapons()
        for _, pedWeapon in ipairs(pedWeapons) do
            local exists = false
            for _, invWeapon in ipairs(inventory) do
                if invWeapon.id == pedWeapon.id then
                    invWeapon.equipped = true
                    exists = true
                    break
                end
            end
            if not exists then
                pedWeapon.equipped = true
                table.insert(inventory, pedWeapon)
            end
        end
        updateAmmoItems()
        TriggerServerEvent('inventory:saveInventory', inventory)
        if open then
            SendNUIMessage({ type = "open", inventory = inventory })
        end
    end
end)

-- aktualizacja ammo w czasie rzeczywistym
CreateThread(function()
    while true do
        Wait(500)
        updateAmmoItems()
        if open then
            SendNUIMessage({ type = "open", inventory = inventory })
        end
    end
end)

-- zapis inventory po śmierci PED-a
AddEventHandler('baseevents:onPlayerDied', function()
    updateAmmoItems()
    TriggerServerEvent('inventory:saveInventory', inventory)
end)
