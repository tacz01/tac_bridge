fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'tac_bridge'
description 'Universal FiveM framework bridge — QBX / QBCore / ESX / ox_core / ND / Mythic'
version     '1.0.2'
author      'tac'

-- ──────────────────────────────────────────────────────────────────────────
-- Load order:
--   shared (config → framework detection → module detection)
--   client / server bridge internals
--   client / server modules (fuel, vehiclekeys, inventory)
--   client / server exports (the public API other resources call)
-- ──────────────────────────────────────────────────────────────────────────

shared_scripts {
    -- ox_lib: required for QBX / ND / ox_core callbacks, notifications and progress.
    -- Safe to include because qbx_core, ND_Core, and ox_core all list ox_lib as a
    -- mandatory dependency — if any of those are running, ox_lib IS installed.
    -- If you run pure QB or ESX WITHOUT ox_lib, comment this line out.
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/framework.lua',
    'shared/modules.lua',
}

client_scripts {
    'client/bridge.lua',
    'client/modules.lua',
    'client/target.lua',
    'client/exports.lua',
}

server_scripts {
    'server/bridge.lua',
    'server/modules.lua',
    'server/exports.lua',
}

-- ──────────────────────────────────────────────────────────────────────────
-- Client exports  (exports.tac_bridge:FunctionName())
-- ──────────────────────────────────────────────────────────────────────────
client_exports {
    -- Player
    'GetPlayerData',
    'GetIdentifier',
    'GetName',
    'IsPlayerLoaded',
    -- Job / Gang
    'GetJob',
    'GetJobName',
    'GetJobGrade',
    'IsOnDuty',
    'IsBoss',
    'GetGang',
    'GetGangName',
    'GetGangGrade',
    -- Money
    'GetMoney',
    -- Inventory
    'HasItem',
    'GetItemCount',
    -- Notify / UI
    'Notify',
    'Progress',
    -- Callbacks
    'TriggerCallback',
    'RegisterCallback',
    -- Fuel module
    'GetFuel',
    'SetFuel',
    -- VehicleKeys module
    'HasVehicleKeys',
    -- Target module
    'HasTarget',
    'AddBoxZone',
    'AddSphereZone',
    'AddPolyZone',
    'RemoveZone',
    'AddTargetEntity',
    'RemoveTargetEntity',
    'AddLocalEntity',
    'RemoveLocalEntity',
    'AddTargetModel',
    'RemoveTargetModel',
    'AddGlobalPlayer',
    'RemoveGlobalPlayer',
    'AddGlobalPed',
    'RemoveGlobalPed',
    'AddGlobalVehicle',
    'RemoveGlobalVehicle',
    'AddGlobalObject',
    'RemoveGlobalObject',
}

-- ──────────────────────────────────────────────────────────────────────────
-- Server exports  (exports.tac_bridge:FunctionName())
-- ──────────────────────────────────────────────────────────────────────────
server_exports {
    -- Player lookup
    'GetPlayer',
    'GetPlayerByCitizenId',
    'GetAllPlayers',
    'GetPlayerCoords',
    -- Identity
    'GetIdentifier',
    'GetName',
    -- Job / Gang
    'GetJob',
    'GetJobName',
    'GetJobGrade',
    'GetGang',
    'SetJob',
    'SetGang',
    -- Money
    'GetMoney',
    'AddMoney',
    'RemoveMoney',
    'SetMoney',
    -- Metadata / Save
    'SetMetaData',
    'SavePlayer',
    -- Inventory
    'HasItem',
    'GetItemCount',
    'AddItem',
    'RemoveItem',
    'CanCarryItem',
    -- VehicleKeys module
    'GiveVehicleKeys',
    'RemoveVehicleKeys',
    -- Notify / Callbacks
    'Notify',
    'RegisterCallback',
}
