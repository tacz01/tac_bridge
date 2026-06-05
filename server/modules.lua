--[[
    tac_bridge — server/modules.lua
    Server-side module bridges:

    Inventory (Bridge.Server.* already delegates to ox_inventory when available):
      • Bridge.Inventory.CanCarryItem(src, item, amount) → bool
      — HasItem / GetItemCount / AddItem / RemoveItem are in server/bridge.lua

    VehicleKeys:
      • Bridge.Server.GiveVehicleKeys(src, plate)   → bool
      • Bridge.Server.RemoveVehicleKeys(src, plate) → bool

    VehicleKeys resources supported:
      qbx_vehiclekeys — exports.qbx_vehiclekeys:GiveKeys(src, plate) / RemoveKeys(src, plate)
      qb-vehiclekeys  — exports['qb-vehiclekeys']:GiveVehicleKeys(src, plate) / RemoveVehicleKeys(src, plate)

    Fuel (ox_fuel relay):
      Handles the 'tac_bridge:setFuel' event so ox_fuel's statebag is set with
      the replicated flag (true), making it visible to all clients.
]]

Bridge = Bridge or {}
local mods = Bridge.Modules

-- ─────────────────────────────────────────────
-- VEHICLE KEYS — server side
-- ─────────────────────────────────────────────

--- Gives vehicle keys to a player for a specific plate.
function Bridge.Server.GiveVehicleKeys(src, plate)
    if not mods.VehicleKeys or not src or not plate then return false end
    plate = plate:upper():gsub('%s+', '')

    if mods.VehicleKeys == 'qbx_vehiclekeys' then
        local ok = pcall(exports.qbx_vehiclekeys.GiveKeys, exports.qbx_vehiclekeys, src, plate)
        return ok

    elseif mods.VehicleKeys == 'qb-vehiclekeys' then
        local ok = pcall(exports['qb-vehiclekeys'].GiveVehicleKeys, exports['qb-vehiclekeys'], src, plate)
        return ok
    end
    return false
end

--- Removes vehicle keys from a player for a specific plate.
function Bridge.Server.RemoveVehicleKeys(src, plate)
    if not mods.VehicleKeys or not src or not plate then return false end
    plate = plate:upper():gsub('%s+', '')

    if mods.VehicleKeys == 'qbx_vehiclekeys' then
        local ok = pcall(exports.qbx_vehiclekeys.RemoveKeys, exports.qbx_vehiclekeys, src, plate)
        return ok

    elseif mods.VehicleKeys == 'qb-vehiclekeys' then
        local ok = pcall(exports['qb-vehiclekeys'].RemoveVehicleKeys, exports['qb-vehiclekeys'], src, plate)
        return ok
    end
    return false
end

-- ─────────────────────────────────────────────
-- INVENTORY — CanCarryItem (not in bridge.lua)
-- ─────────────────────────────────────────────

--- Returns true if the player can carry `amount` of `item`.
function Bridge.Server.CanCarryItem(src, item, amount)
    amount = amount or 1
    if mods.Inventory == 'ox_inventory' then
        return exports.ox_inventory:CanCarryItem(src, item, amount)
    elseif mods.Inventory == 'qb-inventory' then
        return exports['qb-inventory']:CanCarryItem(src, item, amount)
    end
    -- Fallback: check current count vs a hard limit (not reliable without inventory)
    return true
end

-- ─────────────────────────────────────────────
-- FUEL — ox_fuel relay
-- When client calls tac_bridge:setFuel, we set the statebag with replicated=true
-- so all clients (not just the sender) see the updated fuel level.
-- ─────────────────────────────────────────────
if mods.VehicleFuel == 'ox_fuel' then
    RegisterNetEvent('tac_bridge:setFuel', function(netId, amount)
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if vehicle and vehicle ~= 0 then
            local state = Entity(vehicle).state
            amount = math.max(0, math.min(100, tonumber(amount) or 0))
            state:set('fuel', amount, true) -- true = replicated to all clients
            -- Notify requester client so local statebag updates immediately
            TriggerClientEvent('tac_bridge:fuelSet', source, netId, amount)
        end
    end)
end
