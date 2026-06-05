--[[
    tac_bridge — client/exports.lua

    All export wrappers are assigned directly into _G so FiveM's export
    system can always locate them, regardless of how @ox_lib/init.lua
    or Lua 5.4's _ENV handling affects the script environment.
]]

-- Guarantee Bridge.Client exists no matter what happened in earlier scripts.
Bridge        = Bridge        or {}
Bridge.Client = Bridge.Client or {}

-- ── Player ─────────────────────────────────────────────────────────────────
_G.GetPlayerData = function()
    if type(Bridge.Client.GetPlayerData) ~= 'function' then return {} end
    return Bridge.Client.GetPlayerData() or {}
end

_G.GetIdentifier = function()
    if type(Bridge.Client.GetIdentifier) ~= 'function' then return nil end
    return Bridge.Client.GetIdentifier()
end

_G.GetName = function()
    if type(Bridge.Client.GetName) ~= 'function' then return 'Unknown' end
    return Bridge.Client.GetName()
end

_G.IsPlayerLoaded = function()
    if type(Bridge.Client.IsPlayerLoaded) ~= 'function' then return false end
    return Bridge.Client.IsPlayerLoaded() == true
end

-- ── Job ────────────────────────────────────────────────────────────────────
_G.GetJob = function()
    if type(Bridge.Client.GetJob) ~= 'function' then return {} end
    return Bridge.Client.GetJob() or {}
end

_G.GetJobName = function()
    return _G.GetJob().name
end

_G.GetJobGrade = function()
    return _G.GetJob().grade
end

_G.IsOnDuty = function()
    return _G.GetJob().onDuty == true
end

_G.IsBoss = function()
    return _G.GetJob().isBoss == true
end

-- ── Gang ───────────────────────────────────────────────────────────────────
_G.GetGang = function()
    if type(Bridge.Client.GetGang) ~= 'function' then return {} end
    return Bridge.Client.GetGang() or {}
end

_G.GetGangName = function()
    return _G.GetGang().name
end

_G.GetGangGrade = function()
    return _G.GetGang().grade
end

-- ── Money ──────────────────────────────────────────────────────────────────
_G.GetMoney = function(account)
    if type(Bridge.Client.GetMoney) ~= 'function' then return 0 end
    return Bridge.Client.GetMoney(account) or 0
end

-- ── Inventory ──────────────────────────────────────────────────────────────
_G.HasItem = function(item)
    if type(Bridge.Client.HasItem) ~= 'function' then return false end
    return Bridge.Client.HasItem(item) == true
end

_G.GetItemCount = function(item)
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:GetItemCount(item) or 0
    end
    return _G.HasItem(item) and 1 or 0
end

-- ── Notify / UI ────────────────────────────────────────────────────────────
_G.Notify = function(message, notifyType, duration)
    if type(Bridge.Client.Notify) ~= 'function' then return end
    Bridge.Client.Notify(message, notifyType, duration)
end

_G.Progress = function(opts, callback)
    if type(Bridge.Client.Progress) ~= 'function' then
        if type(callback) == 'function' then callback(false) end
        return
    end
    Bridge.Client.Progress(opts, callback)
end

-- ── Callbacks ──────────────────────────────────────────────────────────────
_G.TriggerCallback = function(name, callback, ...)
    if type(Bridge.Client.TriggerCallback) ~= 'function' then
        print('^1[tac_bridge] TriggerCallback: Bridge.Client not initialised^0')
        return
    end
    Bridge.Client.TriggerCallback(name, callback, ...)
end

_G.RegisterCallback = function(name, handler)
    if type(Bridge.Client.RegisterCallback) ~= 'function' then return end
    Bridge.Client.RegisterCallback(name, handler)
end

-- ── Fuel ───────────────────────────────────────────────────────────────────
_G.GetFuel = function(vehicle)
    if type(Bridge.Client.GetFuel) ~= 'function' then return 100 end
    return Bridge.Client.GetFuel(vehicle) or 100
end

_G.SetFuel = function(vehicle, amount)
    if type(Bridge.Client.SetFuel) ~= 'function' then return end
    Bridge.Client.SetFuel(vehicle, amount)
end

-- ── VehicleKeys ────────────────────────────────────────────────────────────
_G.HasVehicleKeys = function(plate)
    if type(Bridge.Client.HasVehicleKeys) ~= 'function' then return false end
    return Bridge.Client.HasVehicleKeys(plate) == true
end

-- ── Target module ──────────────────────────────────────────────────────────
-- Returns true if ox_target or qb-target is running.
_G.HasTarget = function()
    if type(Bridge.Client.HasTarget) ~= 'function' then return false end
    return Bridge.Client.HasTarget()
end

-- Zone creation
_G.AddBoxZone = function(data)
    if type(Bridge.Client.AddBoxZone) ~= 'function' then return end
    return Bridge.Client.AddBoxZone(data)
end

_G.AddSphereZone = function(data)
    if type(Bridge.Client.AddSphereZone) ~= 'function' then return end
    return Bridge.Client.AddSphereZone(data)
end

_G.AddPolyZone = function(data)
    if type(Bridge.Client.AddPolyZone) ~= 'function' then return end
    return Bridge.Client.AddPolyZone(data)
end

_G.RemoveZone = function(name)
    if type(Bridge.Client.RemoveZone) ~= 'function' then return end
    Bridge.Client.RemoveZone(name)
end

-- Entity targeting
_G.AddTargetEntity = function(entities, options, distance)
    if type(Bridge.Client.AddTargetEntity) ~= 'function' then return end
    Bridge.Client.AddTargetEntity(entities, options, distance)
end

_G.RemoveTargetEntity = function(entities, labels)
    if type(Bridge.Client.RemoveTargetEntity) ~= 'function' then return end
    Bridge.Client.RemoveTargetEntity(entities, labels)
end

_G.AddLocalEntity = function(entities, options, distance)
    if type(Bridge.Client.AddLocalEntity) ~= 'function' then return end
    Bridge.Client.AddLocalEntity(entities, options, distance)
end

_G.RemoveLocalEntity = function(entities, labels)
    if type(Bridge.Client.RemoveLocalEntity) ~= 'function' then return end
    Bridge.Client.RemoveLocalEntity(entities, labels)
end

-- Model targeting
_G.AddTargetModel = function(models, options, distance)
    if type(Bridge.Client.AddTargetModel) ~= 'function' then return end
    Bridge.Client.AddTargetModel(models, options, distance)
end

_G.RemoveTargetModel = function(models, labels)
    if type(Bridge.Client.RemoveTargetModel) ~= 'function' then return end
    Bridge.Client.RemoveTargetModel(models, labels)
end

-- Global types
_G.AddGlobalPlayer = function(options, distance)
    if type(Bridge.Client.AddGlobalPlayer) ~= 'function' then return end
    Bridge.Client.AddGlobalPlayer(options, distance)
end

_G.RemoveGlobalPlayer = function(labels)
    if type(Bridge.Client.RemoveGlobalPlayer) ~= 'function' then return end
    Bridge.Client.RemoveGlobalPlayer(labels)
end

_G.AddGlobalPed = function(options, distance)
    if type(Bridge.Client.AddGlobalPed) ~= 'function' then return end
    Bridge.Client.AddGlobalPed(options, distance)
end

_G.RemoveGlobalPed = function(labels)
    if type(Bridge.Client.RemoveGlobalPed) ~= 'function' then return end
    Bridge.Client.RemoveGlobalPed(labels)
end

_G.AddGlobalVehicle = function(options, distance)
    if type(Bridge.Client.AddGlobalVehicle) ~= 'function' then return end
    Bridge.Client.AddGlobalVehicle(options, distance)
end

_G.RemoveGlobalVehicle = function(labels)
    if type(Bridge.Client.RemoveGlobalVehicle) ~= 'function' then return end
    Bridge.Client.RemoveGlobalVehicle(labels)
end

_G.AddGlobalObject = function(options, distance)
    if type(Bridge.Client.AddGlobalObject) ~= 'function' then return end
    Bridge.Client.AddGlobalObject(options, distance)
end

_G.RemoveGlobalObject = function(labels)
    if type(Bridge.Client.RemoveGlobalObject) ~= 'function' then return end
    Bridge.Client.RemoveGlobalObject(labels)
end
