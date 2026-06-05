--[[
    tac_bridge — shared/modules.lua
    Auto-detects which addon resources are available.
    Results stored in Bridge.Modules.* (read-only after init).

    Detection priority order:
      Inventory  : ox_inventory → qb-inventory
      VehicleKeys: qbx_vehiclekeys → qb-vehiclekeys
      VehicleFuel: ox_fuel → LegacyFuel → cdn-fuel → lc_fuel → qb-fuel
]]

Bridge         = Bridge or {}
Bridge.Modules = Bridge.Modules or {}

local function detect(forced, ...)
    if forced == false then return false end  -- explicitly disabled
    if forced ~= nil   then return forced end -- explicitly set
    for _, name in ipairs({...}) do
        if GetResourceState(name) == 'started' then return name end
    end
    return false
end

Bridge.Modules.OxLib      = GetResourceState('ox_lib') == 'started'

Bridge.Modules.Inventory  = detect(
    Bridge.Config.Inventory,
    'ox_inventory', 'qb-inventory'
)

Bridge.Modules.VehicleKeys = detect(
    Bridge.Config.VehicleKeys,
    'qbx_vehiclekeys', 'qb-vehiclekeys'
)

Bridge.Modules.VehicleFuel = detect(
    Bridge.Config.VehicleFuel,
    'ox_fuel', 'LegacyFuel', 'cdn-fuel', 'lc_fuel', 'qb-fuel'
)

-- Print detected modules on server startup
if IsDuplicityVersion() then
    local function status(v) return v and ('^2' .. v .. '^0') or '^3none^0' end
    print(string.format(
        '^5[tac_bridge] Modules — Inventory: %s | VehicleKeys: %s | Fuel: %s | ox_lib: %s^0',
        status(Bridge.Modules.Inventory),
        status(Bridge.Modules.VehicleKeys),
        status(Bridge.Modules.VehicleFuel),
        Bridge.Modules.OxLib and '^2yes^0' or '^3no^0'
    ))
end
