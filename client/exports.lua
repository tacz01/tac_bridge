--[[
    tac_bridge — client/exports.lua

    Global wrapper functions that expose Bridge.Client.* as FiveM exports.
    Other resources call these via:  exports.tac_bridge:FunctionName(...)

    Usage in another resource's client script:
        local pd   = exports.tac_bridge:GetPlayerData()
        local job  = exports.tac_bridge:GetJobName()
        local fuel = exports.tac_bridge:GetFuel(vehicle)
        exports.tac_bridge:Notify('Hello!', 'success')
        exports.tac_bridge:HasVehicleKeys(plate)

    All Bridge.Client.* internals remain available inside tac_bridge itself.
    These wrappers are only for the export surface.
]]

-- ── Player ────────────────────────────────────────────────────────────────
function GetPlayerData()   return Bridge.Client.GetPlayerData()   end
function GetIdentifier()   return Bridge.Client.GetIdentifier()   end
function GetName()         return Bridge.Client.GetName()         end
function IsPlayerLoaded()  return Bridge.Client.IsPlayerLoaded()  end

-- ── Job ───────────────────────────────────────────────────────────────────
function GetJob()
    return Bridge.Client.GetJob()
end

function GetJobName()
    return Bridge.Client.GetJob().name
end

function GetJobGrade()
    return Bridge.Client.GetJob().grade
end

function IsOnDuty()
    return Bridge.Client.GetJob().onDuty == true
end

function IsBoss()
    return Bridge.Client.GetJob().isBoss == true
end

-- ── Gang ──────────────────────────────────────────────────────────────────
function GetGang()
    return Bridge.Client.GetGang()
end

function GetGangName()
    return Bridge.Client.GetGang().name
end

function GetGangGrade()
    return Bridge.Client.GetGang().grade
end

-- ── Money ─────────────────────────────────────────────────────────────────
--- account: 'cash' | 'bank' | 'black'  (default: 'cash')
function GetMoney(account)
    return Bridge.Client.GetMoney(account)
end

-- ── Inventory ─────────────────────────────────────────────────────────────
function HasItem(item)
    return Bridge.Client.HasItem(item)
end

function GetItemCount(item)
    -- client-side count via ox_inventory if available, else HasItem fallback
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:GetItemCount(item) or 0
    end
    return Bridge.Client.HasItem(item) and 1 or 0
end

-- ── Notify / UI ───────────────────────────────────────────────────────────
--- type: 'success' | 'error' | 'info' | 'warning'
function Notify(message, notifyType, duration)
    Bridge.Client.Notify(message, notifyType, duration)
end

--- See Bridge.Client.Progress for opts table shape
function Progress(opts, callback)
    Bridge.Client.Progress(opts, callback)
end

-- ── Callbacks ─────────────────────────────────────────────────────────────
function TriggerCallback(name, callback, ...)
    Bridge.Client.TriggerCallback(name, callback, ...)
end

function RegisterCallback(name, handler)
    Bridge.Client.RegisterCallback(name, handler)
end

-- ── Fuel module ───────────────────────────────────────────────────────────
--- vehicle: entity handle
function GetFuel(vehicle)
    return Bridge.Client.GetFuel(vehicle)
end

--- vehicle: entity handle, amount: 0–100
function SetFuel(vehicle, amount)
    Bridge.Client.SetFuel(vehicle, amount)
end

-- ── VehicleKeys module ────────────────────────────────────────────────────
--- plate: string (case-insensitive)
function HasVehicleKeys(plate)
    return Bridge.Client.HasVehicleKeys(plate)
end
