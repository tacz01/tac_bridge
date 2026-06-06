--[[
    tac_bridge — client/exports.lua

    All functions are declared as plain Lua globals so FiveM's client_exports
    system can resolve them.  Each one nil-guards Bridge.Client so callers
    never crash if tac_bridge hasn't finished initialising yet.
]]

Bridge        = Bridge        or {}
Bridge.Client = Bridge.Client or {}

print('^2[tac_bridge] client/exports.lua: loading (fw=' .. tostring(Bridge.Framework) .. ')^0')

-- ── Player ─────────────────────────────────────────────────────────────────

function GetPlayerData()
    if type(Bridge.Client.GetPlayerData) ~= 'function' then return {} end
    return Bridge.Client.GetPlayerData() or {}
end

function GetIdentifier()
    if type(Bridge.Client.GetIdentifier) ~= 'function' then return nil end
    return Bridge.Client.GetIdentifier()
end

function GetName()
    if type(Bridge.Client.GetName) ~= 'function' then return 'Unknown' end
    return Bridge.Client.GetName()
end

function IsPlayerLoaded()
    if type(Bridge.Client.IsPlayerLoaded) ~= 'function' then return false end
    return Bridge.Client.IsPlayerLoaded() == true
end

-- ── Job ────────────────────────────────────────────────────────────────────

function GetJob()
    if type(Bridge.Client.GetJob) ~= 'function' then return {} end
    return Bridge.Client.GetJob() or {}
end

function GetJobName()
    if type(Bridge.Client.GetJob) ~= 'function' then return nil end
    return (Bridge.Client.GetJob() or {}).name
end

function GetJobGrade()
    if type(Bridge.Client.GetJob) ~= 'function' then return nil end
    return (Bridge.Client.GetJob() or {}).grade
end

function IsOnDuty()
    if type(Bridge.Client.GetJob) ~= 'function' then return false end
    return (Bridge.Client.GetJob() or {}).onDuty == true
end

function IsBoss()
    if type(Bridge.Client.GetJob) ~= 'function' then return false end
    return (Bridge.Client.GetJob() or {}).isBoss == true
end

-- ── Gang ───────────────────────────────────────────────────────────────────

function GetGang()
    if type(Bridge.Client.GetGang) ~= 'function' then return {} end
    return Bridge.Client.GetGang() or {}
end

function GetGangName()
    if type(Bridge.Client.GetGang) ~= 'function' then return nil end
    return (Bridge.Client.GetGang() or {}).name
end

function GetGangGrade()
    if type(Bridge.Client.GetGang) ~= 'function' then return nil end
    return (Bridge.Client.GetGang() or {}).grade
end

-- ── Money ──────────────────────────────────────────────────────────────────

function GetMoney(account)
    if type(Bridge.Client.GetMoney) ~= 'function' then return 0 end
    return Bridge.Client.GetMoney(account) or 0
end

-- ── Inventory ──────────────────────────────────────────────────────────────

function HasItem(item)
    if type(Bridge.Client.HasItem) ~= 'function' then return false end
    return Bridge.Client.HasItem(item) == true
end

function GetItemCount(item)
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:GetItemCount(item) or 0
    end
    if type(Bridge.Client.HasItem) ~= 'function' then return 0 end
    return Bridge.Client.HasItem(item) and 1 or 0
end

-- ── Notify / UI ────────────────────────────────────────────────────────────

function Notify(message, notifyType, duration)
    if type(Bridge.Client.Notify) ~= 'function' then return end
    Bridge.Client.Notify(message, notifyType, duration)
end

function Progress(opts, callback)
    if type(Bridge.Client.Progress) ~= 'function' then
        if type(callback) == 'function' then callback(false) end
        return
    end
    Bridge.Client.Progress(opts, callback)
end

-- ── Callbacks ──────────────────────────────────────────────────────────────

function TriggerCallback(name, callback, ...)
    if type(Bridge.Client.TriggerCallback) ~= 'function' then
        print('^1[tac_bridge] TriggerCallback: Bridge.Client not initialised^0')
        return
    end
    Bridge.Client.TriggerCallback(name, callback, ...)
end

function RegisterCallback(name, handler)
    if type(Bridge.Client.RegisterCallback) ~= 'function' then return end
    Bridge.Client.RegisterCallback(name, handler)
end

-- ── Fuel ───────────────────────────────────────────────────────────────────

function GetFuel(vehicle)
    if type(Bridge.Client.GetFuel) ~= 'function' then return 100 end
    return Bridge.Client.GetFuel(vehicle) or 100
end

function SetFuel(vehicle, amount)
    if type(Bridge.Client.SetFuel) ~= 'function' then return end
    Bridge.Client.SetFuel(vehicle, amount)
end

-- ── VehicleKeys ────────────────────────────────────────────────────────────

function HasVehicleKeys(plate)
    if type(Bridge.Client.HasVehicleKeys) ~= 'function' then return false end
    return Bridge.Client.HasVehicleKeys(plate) == true
end

-- ── Target ─────────────────────────────────────────────────────────────────

function HasTarget()
    if type(Bridge.Client.HasTarget) ~= 'function' then return false end
    return Bridge.Client.HasTarget()
end

function AddBoxZone(data)
    if type(Bridge.Client.AddBoxZone) ~= 'function' then return end
    return Bridge.Client.AddBoxZone(data)
end

function AddSphereZone(data)
    if type(Bridge.Client.AddSphereZone) ~= 'function' then return end
    return Bridge.Client.AddSphereZone(data)
end

function AddPolyZone(data)
    if type(Bridge.Client.AddPolyZone) ~= 'function' then return end
    return Bridge.Client.AddPolyZone(data)
end

function RemoveZone(name)
    if type(Bridge.Client.RemoveZone) ~= 'function' then return end
    Bridge.Client.RemoveZone(name)
end

function AddTargetEntity(entities, options, distance)
    if type(Bridge.Client.AddTargetEntity) ~= 'function' then return end
    Bridge.Client.AddTargetEntity(entities, options, distance)
end

function RemoveTargetEntity(entities, labels)
    if type(Bridge.Client.RemoveTargetEntity) ~= 'function' then return end
    Bridge.Client.RemoveTargetEntity(entities, labels)
end

function AddLocalEntity(entities, options, distance)
    if type(Bridge.Client.AddLocalEntity) ~= 'function' then return end
    Bridge.Client.AddLocalEntity(entities, options, distance)
end

function RemoveLocalEntity(entities, labels)
    if type(Bridge.Client.RemoveLocalEntity) ~= 'function' then return end
    Bridge.Client.RemoveLocalEntity(entities, labels)
end

function AddTargetModel(models, options, distance)
    if type(Bridge.Client.AddTargetModel) ~= 'function' then return end
    Bridge.Client.AddTargetModel(models, options, distance)
end

function RemoveTargetModel(models, labels)
    if type(Bridge.Client.RemoveTargetModel) ~= 'function' then return end
    Bridge.Client.RemoveTargetModel(models, labels)
end

function AddGlobalPlayer(options, distance)
    if type(Bridge.Client.AddGlobalPlayer) ~= 'function' then return end
    Bridge.Client.AddGlobalPlayer(options, distance)
end

function RemoveGlobalPlayer(labels)
    if type(Bridge.Client.RemoveGlobalPlayer) ~= 'function' then return end
    Bridge.Client.RemoveGlobalPlayer(labels)
end

function AddGlobalPed(options, distance)
    if type(Bridge.Client.AddGlobalPed) ~= 'function' then return end
    Bridge.Client.AddGlobalPed(options, distance)
end

function RemoveGlobalPed(labels)
    if type(Bridge.Client.RemoveGlobalPed) ~= 'function' then return end
    Bridge.Client.RemoveGlobalPed(labels)
end

function AddGlobalVehicle(options, distance)
    if type(Bridge.Client.AddGlobalVehicle) ~= 'function' then return end
    Bridge.Client.AddGlobalVehicle(options, distance)
end

function RemoveGlobalVehicle(labels)
    if type(Bridge.Client.RemoveGlobalVehicle) ~= 'function' then return end
    Bridge.Client.RemoveGlobalVehicle(labels)
end

function AddGlobalObject(options, distance)
    if type(Bridge.Client.AddGlobalObject) ~= 'function' then return end
    Bridge.Client.AddGlobalObject(options, distance)
end

function RemoveGlobalObject(labels)
    if type(Bridge.Client.RemoveGlobalObject) ~= 'function' then return end
    Bridge.Client.RemoveGlobalObject(labels)
end

print('^2[tac_bridge] client/exports.lua: all exports registered^0')
