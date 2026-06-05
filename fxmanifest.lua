fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'tac_bridge'
description 'Universal FiveM framework bridge — QBX / QBCore / ESX / ox_core / ND / Mythic'
version     '1.0.0'
author      'tac'

shared_scripts {
    'shared/config.lua',
    'shared/framework.lua',
    'shared/modules.lua',
}

client_scripts {
    'client/bridge.lua',
    'client/modules.lua',
    'client/exports.lua',
}

server_scripts {
    'server/bridge.lua',
    'server/modules.lua',
    'server/exports.lua',
}

-- Client exports  (exports.tac_bridge:FunctionName())

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
}

-- Server exports  (exports.tac_bridge:FunctionName())

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
