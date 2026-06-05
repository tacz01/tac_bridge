--[[
    tac_bridge — server/exports.lua

    Global wrapper functions that expose Bridge.Server.* as FiveM exports.
    Other resources call these via:  exports.tac_bridge:FunctionName(...)

    Usage in another resource's server script:
        local player = exports.tac_bridge:GetPlayer(source)
        local job    = exports.tac_bridge:GetJobName(source)
        exports.tac_bridge:AddMoney(source, 'cash', 500, 'payment')
        exports.tac_bridge:GiveVehicleKeys(source, plate)
        exports.tac_bridge:Notify(source, 'Done!', 'success')
]]

-- ── Player lookup ─────────────────────────────────────────────────────────
function GetPlayer(src)              return Bridge.Server.GetPlayer(src)              end
function GetPlayerByCitizenId(cid)   return Bridge.Server.GetPlayerByCitizenId(cid)   end
function GetAllPlayers()             return Bridge.Server.GetAllPlayers()             end

function GetPlayerCoords(src)
    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 then return GetEntityCoords(ped) end
    return vector3(0, 0, 0)
end

-- ── Identity ──────────────────────────────────────────────────────────────
function GetIdentifier(src)  return Bridge.Server.GetIdentifier(src)  end
function GetName(src)        return Bridge.Server.GetName(src)        end

-- ── Job ───────────────────────────────────────────────────────────────────
function GetJob(src)
    return Bridge.Server.GetJob(src)
end

function GetJobName(src)
    return Bridge.Server.GetJob(src).name
end

function GetJobGrade(src)
    return Bridge.Server.GetJob(src).grade
end

function GetGang(src)
    return Bridge.Server.GetGang(src)
end

function SetJob(src, jobName, grade)
    return Bridge.Server.SetJob(src, jobName, grade)
end

function SetGang(src, gangName, grade)
    return Bridge.Server.SetGang(src, gangName, grade)
end

-- ── Money ─────────────────────────────────────────────────────────────────
--- account: 'cash' | 'bank' | 'black'
function GetMoney(src, account)
    return Bridge.Server.GetMoney(src, account)
end

function AddMoney(src, account, amount, reason)
    return Bridge.Server.AddMoney(src, account, amount, reason)
end

function RemoveMoney(src, account, amount, reason)
    return Bridge.Server.RemoveMoney(src, account, amount, reason)
end

function SetMoney(src, account, amount, reason)
    return Bridge.Server.SetMoney(src, account, amount, reason)
end

-- ── Metadata / Save ───────────────────────────────────────────────────────
function SetMetaData(src, key, value)
    return Bridge.Server.SetMetaData(src, key, value)
end

function SavePlayer(src)
    return Bridge.Server.SavePlayer(src)
end

-- ── Inventory ─────────────────────────────────────────────────────────────
function HasItem(src, item)
    return Bridge.Server.HasItem(src, item)
end

function GetItemCount(src, item)
    return Bridge.Server.GetItemCount(src, item)
end

function AddItem(src, item, amount)
    return Bridge.Server.AddItem(src, item, amount)
end

function RemoveItem(src, item, amount)
    return Bridge.Server.RemoveItem(src, item, amount)
end

function CanCarryItem(src, item, amount)
    return Bridge.Server.CanCarryItem(src, item, amount)
end

-- ── VehicleKeys module ────────────────────────────────────────────────────
function GiveVehicleKeys(src, plate)
    return Bridge.Server.GiveVehicleKeys(src, plate)
end

function RemoveVehicleKeys(src, plate)
    return Bridge.Server.RemoveVehicleKeys(src, plate)
end

-- ── Notify ────────────────────────────────────────────────────────────────
--- type: 'success' | 'error' | 'info' | 'warning'
function Notify(src, message, notifyType, duration)
    Bridge.Server.Notify(src, message, notifyType, duration)
end

-- ── Callbacks ─────────────────────────────────────────────────────────────
function RegisterCallback(name, handler)
    Bridge.Server.RegisterCallback(name, handler)
end
