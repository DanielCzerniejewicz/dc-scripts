local activeBlips = {}

local function createBlip(data)
    local blip = AddBlipForCoord(data.x + 0.0, data.y + 0.0, data.z + 0.0)
    SetBlipSprite(blip, data.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, data.scale + 0.0)
    SetBlipColour(blip, data.color)
    SetBlipAsShortRange(blip, false)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.name)
    EndTextCommandSetBlipName(blip)

    table.insert(activeBlips, blip)
end

RegisterNetEvent("blips:load")
AddEventHandler("blips:load", function(results)
    -- usuń stare blipy
    for _, b in ipairs(activeBlips) do
        RemoveBlip(b)
    end
    activeBlips = {}

    -- stwórz wszystkie z bazy
    for _, row in ipairs(results) do
        createBlip(row)
    end
end)
