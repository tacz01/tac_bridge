--[[
    tac_bridge — client/modules.lua
    Client-side module bridges:
      • Bridge.Client.GetFuel(vehicle)     → number (0-100)
      • Bridge.Client.SetFuel(vehicle, n)
      • Bridge.Client.HasVehicleKeys(plate) → bool

    Fuel resources supported:
      ox_fuel     — reads Entity(vehicle).state.fuel (statebag set server-side)
      LegacyFuel  — exports.LegacyFuel:GetFuel / SetFuel
      cdn-fuel    — exports['cdn-fuel']:GetFuel / SetFuel
      lc_fuel     — exports['lc_fuel']:GetFuel / SetFuel
      qb-fuel     — exports['qb-fuel']:GetFuel / SetFuel

    VehicleKeys resources supported:
      qbx_vehiclekeys — exports.qbx_vehiclekeys:GetVehicleKeys() → { [plate]=true, ... }
      qb-vehiclekeys  — player metadata 'vehiclekeys' table
]]

Bridge        = Bridge or {}
Bridge.Client = Bridge.Client or {}

-- Grab module/framework refs safely — if shared scripts failed for any reason
-- these will be empty tables rather than nil, preventing load-time crashes.
local mods = Bridge.Modules or {}
local fw   = Bridge.Framework

-- ─────────────────────────────────────────────
-- FUEL
-- ─────────────────────────────────────────────

--- Returns current fuel level (0–100) for a vehicle entity.
function Bridge.Client.GetFuel(vehicle)
    if not mods or not mods.VehicleFuel then return 100 end

    if mods.VehicleFuel == 'ox_fuel' then
        return Entity(vehicle).state.fuel or 100
    end

    local ok, val = pcall(function()
        return exports[mods.VehicleFuel]:GetFuel(vehicle)
    end)
    return (ok and tonumber(val)) or 100
end

--- Sets fuel level (0–100) on a vehicle.
function Bridge.Client.SetFuel(vehicle, amount)
    if not mods or not mods.VehicleFuel then return end
    amount = math.max(0, math.min(100, tonumber(amount) or 0))

    if mods.VehicleFuel == 'ox_fuel' then
        TriggerServerEvent('tac_bridge:setFuel', NetworkGetNetworkIdFromEntity(vehicle), amount)
        return
    end

    pcall(function()
        exports[mods.VehicleFuel]:SetFuel(vehicle, amount)
    end)
end

-- ─────────────────────────────────────────────
-- VEHICLE KEYS (client-side check)
-- ─────────────────────────────────────────────

--- Returns true if the local player has keys for the given plate.
function Bridge.Client.HasVehicleKeys(plate)
    if not mods or not mods.VehicleKeys or not plate then return false end
    plate = plate:upper():gsub('%s+', '')

    if mods.VehicleKeys == 'qbx_vehiclekeys' then
        local ok, keys = pcall(function()
            return exports.qbx_vehiclekeys:GetVehicleKeys()
        end)
        return ok and keys ~= nil and keys[plate] == true

    elseif mods.VehicleKeys == 'qb-vehiclekeys' then
        local pd   = Bridge.Client.GetPlayerData and Bridge.Client.GetPlayerData() or {}
        local meta = pd and pd.metadata
        if meta and meta.vehiclekeys then
            for _, p in ipairs(meta.vehiclekeys) do
                if p:upper():gsub('%s+', '') == plate then return true end
            end
        end
        return false
    end
    return false
end

-- ─────────────────────────────────────────────
-- ox_fuel client relay
-- nil-guarded so a missing Bridge.Modules never crashes this file
-- ─────────────────────────────────────────────
if mods and mods.VehicleFuel == 'ox_fuel' then
    RegisterNetEvent('tac_bridge:fuelSet')
    AddEventHandler('tac_bridge:fuelSet', function(netId, amount)
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(vehicle) then
            Entity(vehicle).state:set('fuel', amount, false)
        end
    end)
end
