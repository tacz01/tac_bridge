--[[
    tac_bridge — shared/modules.lua
    Auto-detects which addon resources are available.

    Detection priority:
      Inventory  : ox_inventory → qb-inventory
      VehicleKeys: qbx_vehiclekeys → qb-vehiclekeys
      VehicleFuel: ox_fuel → LegacyFuel → cdn-fuel → lc_fuel → qb-fuel
      Target     : ox_target → qb-target
]]

Bridge         = Bridge         or {}
Bridge.Modules = Bridge.Modules or {}

local function detect(forced, ...)
    if forced == false then return false end
    if forced ~= nil   then return forced end
    for _, name in ipairs({...}) do
        if GetResourceState(name) == 'started' then return name end
    end
    return false
end

Bridge.Modules.OxLib       = GetResourceState('ox_lib') == 'started'
Bridge.Modules.Inventory   = detect(Bridge.Config.Inventory,   'ox_inventory', 'qb-inventory')
Bridge.Modules.VehicleKeys = detect(Bridge.Config.VehicleKeys, 'qbx_vehiclekeys', 'qb-vehiclekeys')
Bridge.Modules.VehicleFuel = detect(Bridge.Config.VehicleFuel, 'ox_fuel', 'LegacyFuel', 'cdn-fuel', 'lc_fuel', 'qb-fuel')
Bridge.Modules.Target      = detect(Bridge.Config.Target,      'ox_target', 'qb-target')

if IsDuplicityVersion() then
    local function s(v) return v and ('^2'..v..'^0') or '^3none^0' end
    print(string.format(
        '^5[tac_bridge] Modules — Inventory: %s | VehicleKeys: %s | Fuel: %s | Target: %s | ox_lib: %s^0',
        s(Bridge.Modules.Inventory), s(Bridge.Modules.VehicleKeys),
        s(Bridge.Modules.VehicleFuel), s(Bridge.Modules.Target),
        Bridge.Modules.OxLib and '^2yes^0' or '^3no^0'
    ))
end
