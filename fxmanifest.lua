fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name        'tac_bridge'
description 'Universal FiveM framework bridge — QBX / QBCore / ESX / ox_core / ND / Mythic'
version     '1.1.0'
author      'tac'

dependencies {
    '/onesync',
    'ox_lib',
}

-- ──────────────────────────────────────────────────────────────────────────
-- Load order:
--   shared  → config, utils (isStarted), framework detection, module detection
--   client  → bridge, modules, target, exports
--   server  → bridge, modules, exports
--
-- Client exports are registered via exports(name, fn) in client/exports.lua.
-- The use_experimental_fxv2_oal runtime enables this pattern (same as
-- bl_bridge / community_bridge).  No client_exports manifest block needed.
-- ──────────────────────────────────────────────────────────────────────────

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/utils.lua',
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

-- Server exports
server_exports {
    'GetPlayer',
    'GetPlayerByCitizenId',
    'GetAllPlayers',
    'GetPlayerCoords',
    'GetIdentifier',
    'GetName',
    'GetJob',
    'GetJobName',
    'GetJobGrade',
    'GetGang',
    'SetJob',
    'SetGang',
    'GetMoney',
    'AddMoney',
    'RemoveMoney',
    'SetMoney',
    'SetMetaData',
    'SavePlayer',
    'HasItem',
    'GetItemCount',
    'AddItem',
    'RemoveItem',
    'CanCarryItem',
    'GiveVehicleKeys',
    'RemoveVehicleKeys',
    'Notify',
    'RegisterCallback',
}
