--[[
    tac_bridge — shared/config.lua
    Edit these values to match your server setup.
]]

Bridge = Bridge or {}

Bridge.Config = {
    -- Force a specific framework instead of auto-detecting.
    -- Options: 'qbx' | 'qb' | 'esx' | 'ox' | 'nd' | 'mythic' | nil (auto)
    ForceFramework = nil,

    -- Force a specific module resource, or nil to auto-detect.
    -- Set to false to completely disable that module.
    Inventory   = nil,    -- nil = auto | 'ox_inventory' | 'qb-inventory' | false
    VehicleKeys = nil,    -- nil = auto | 'qbx_vehiclekeys' | 'qb-vehiclekeys' | false
    VehicleFuel = nil,    -- nil = auto | 'ox_fuel' | 'LegacyFuel' | 'cdn-fuel' | 'lc_fuel' | 'qb-fuel' | false

    -- Default notification duration (ms)
    NotifyDuration = 5000,

    -- Default progress bar duration (ms)
    ProgressDuration = 5000,

    -- ESX legacy getSharedObject event (older ESX only)
    ESXEvent = 'esx:getSharedObject',

    -- Account name map per framework.
    -- mythic: mythic-base has no built-in money; these keys are passed to your
    -- overridden AddMoney/RemoveMoney/GetMoney if you implement a custom money component.
    Accounts = {
        cash  = { qb = 'cash',   esx = 'money',      qbx = 'cash',  nd = 'cash', ox = 'cash', mythic = 'cash'  },
        bank  = { qb = 'bank',   esx = 'bank',       qbx = 'bank',  nd = 'bank', ox = 'bank', mythic = 'bank'  },
        black = { qb = 'crypto', esx = 'black_money', qbx = 'crypto', nd = 'cash', ox = 'bank', mythic = 'cash' },
    },
}
