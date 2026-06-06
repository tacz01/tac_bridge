--[[
    tac_bridge — client/exports.lua

    Registers all client exports via exports(name, fn) — the same pattern used
    by bl_bridge and community_bridge.  This requires use_experimental_fxv2_oal
    in fxmanifest.lua, which is now set.  No client_exports manifest block needed.
]]

Bridge        = Bridge        or {}
Bridge.Client = Bridge.Client or {}

-- ── Helper ─────────────────────────────────────────────────────────────────
-- Mirrors bl_bridge's pattern: exports(name, fn) in OAL runtime = client export.
local function reg(name, fn)
    exports(name, fn)
end

-- ── Player ─────────────────────────────────────────────────────────────────

reg('GetPlayerData', function()
    if type(Bridge.Client.GetPlayerData) ~= 'function' then return {} end
    return Bridge.Client.GetPlayerData() or {}
end)

reg('GetIdentifier', function()
    if type(Bridge.Client.GetIdentifier) ~= 'function' then return nil end
    return Bridge.Client.GetIdentifier()
end)

reg('GetName', function()
    if type(Bridge.Client.GetName) ~= 'function' then return 'Unknown' end
    return Bridge.Client.GetName()
end)

reg('IsPlayerLoaded', function()
    if type(Bridge.Client.IsPlayerLoaded) ~= 'function' then return false end
    return Bridge.Client.IsPlayerLoaded() == true
end)

-- ── Job ────────────────────────────────────────────────────────────────────

reg('GetJob', function()
    if type(Bridge.Client.GetJob) ~= 'function' then return {} end
    return Bridge.Client.GetJob() or {}
end)

reg('GetJobName', function()
    if type(Bridge.Client.GetJob) ~= 'function' then return nil end
    return (Bridge.Client.GetJob() or {}).name
end)

reg('GetJobGrade', function()
    if type(Bridge.Client.GetJob) ~= 'function' then return nil end
    return (Bridge.Client.GetJob() or {}).grade
end)

reg('IsOnDuty', function()
    if type(Bridge.Client.GetJob) ~= 'function' then return false end
    return (Bridge.Client.GetJob() or {}).onDuty == true
end)

reg('IsBoss', function()
    if type(Bridge.Client.GetJob) ~= 'function' then return false end
    return (Bridge.Client.GetJob() or {}).isBoss == true
end)

-- ── Gang ───────────────────────────────────────────────────────────────────

reg('GetGang', function()
    if type(Bridge.Client.GetGang) ~= 'function' then return {} end
    return Bridge.Client.GetGang() or {}
end)

reg('GetGangName', function()
    if type(Bridge.Client.GetGang) ~= 'function' then return nil end
    return (Bridge.Client.GetGang() or {}).name
end)

reg('GetGangGrade', function()
    if type(Bridge.Client.GetGang) ~= 'function' then return nil end
    return (Bridge.Client.GetGang() or {}).grade
end)

-- ── Money ──────────────────────────────────────────────────────────────────

reg('GetMoney', function(account)
    if type(Bridge.Client.GetMoney) ~= 'function' then return 0 end
    return Bridge.Client.GetMoney(account) or 0
end)

-- ── Inventory ──────────────────────────────────────────────────────────────

reg('HasItem', function(item)
    if type(Bridge.Client.HasItem) ~= 'function' then return false end
    return Bridge.Client.HasItem(item) == true
end)

reg('GetItemCount', function(item)
    if isStarted('ox_inventory') then
        return exports.ox_inventory:GetItemCount(item) or 0
    end
    if type(Bridge.Client.HasItem) ~= 'function' then return 0 end
    return Bridge.Client.HasItem(item) and 1 or 0
end)

-- ── Notify / UI ────────────────────────────────────────────────────────────

reg('Notify', function(message, notifyType, duration)
    if type(Bridge.Client.Notify) ~= 'function' then return end
    Bridge.Client.Notify(message, notifyType, duration)
end)

reg('Progress', function(opts, callback)
    if type(Bridge.Client.Progress) ~= 'function' then
        if type(callback) == 'function' then callback(false) end
        return
    end
    Bridge.Client.Progress(opts, callback)
end)

-- ── Callbacks ──────────────────────────────────────────────────────────────

reg('TriggerCallback', function(name, callback, ...)
    if type(Bridge.Client.TriggerCallback) ~= 'function' then
        print('^1[tac_bridge] TriggerCallback: Bridge.Client not ready^0')
        return
    end
    Bridge.Client.TriggerCallback(name, callback, ...)
end)

reg('RegisterCallback', function(name, handler)
    if type(Bridge.Client.RegisterCallback) ~= 'function' then return end
    Bridge.Client.RegisterCallback(name, handler)
end)

-- ── Fuel ───────────────────────────────────────────────────────────────────

reg('GetFuel', function(vehicle)
    if type(Bridge.Client.GetFuel) ~= 'function' then return 100 end
    return Bridge.Client.GetFuel(vehicle) or 100
end)

reg('SetFuel', function(vehicle, amount)
    if type(Bridge.Client.SetFuel) ~= 'function' then return end
    Bridge.Client.SetFuel(vehicle, amount)
end)

-- ── VehicleKeys ────────────────────────────────────────────────────────────

reg('HasVehicleKeys', function(plate)
    if type(Bridge.Client.HasVehicleKeys) ~= 'function' then return false end
    return Bridge.Client.HasVehicleKeys(plate) == true
end)

-- ── Target ─────────────────────────────────────────────────────────────────

reg('HasTarget', function()
    if type(Bridge.Client.HasTarget) ~= 'function' then return false end
    return Bridge.Client.HasTarget()
end)

reg('AddBoxZone', function(data)
    if type(Bridge.Client.AddBoxZone) ~= 'function' then return end
    return Bridge.Client.AddBoxZone(data)
end)

reg('AddSphereZone', function(data)
    if type(Bridge.Client.AddSphereZone) ~= 'function' then return end
    return Bridge.Client.AddSphereZone(data)
end)

reg('AddPolyZone', function(data)
    if type(Bridge.Client.AddPolyZone) ~= 'function' then return end
    return Bridge.Client.AddPolyZone(data)
end)

reg('RemoveZone', function(name)
    if type(Bridge.Client.RemoveZone) ~= 'function' then return end
    Bridge.Client.RemoveZone(name)
end)

reg('AddTargetEntity', function(entities, options, distance)
    if type(Bridge.Client.AddTargetEntity) ~= 'function' then return end
    Bridge.Client.AddTargetEntity(entities, options, distance)
end)

reg('RemoveTargetEntity', function(entities, labels)
    if type(Bridge.Client.RemoveTargetEntity) ~= 'function' then return end
    Bridge.Client.RemoveTargetEntity(entities, labels)
end)

reg('AddLocalEntity', function(entities, options, distance)
    if type(Bridge.Client.AddLocalEntity) ~= 'function' then return end
    Bridge.Client.AddLocalEntity(entities, options, distance)
end)

reg('RemoveLocalEntity', function(entities, labels)
    if type(Bridge.Client.RemoveLocalEntity) ~= 'function' then return end
    Bridge.Client.RemoveLocalEntity(entities, labels)
end)

reg('AddTargetModel', function(models, options, distance)
    if type(Bridge.Client.AddTargetModel) ~= 'function' then return end
    Bridge.Client.AddTargetModel(models, options, distance)
end)

reg('RemoveTargetModel', function(models, labels)
    if type(Bridge.Client.RemoveTargetModel) ~= 'function' then return end
    Bridge.Client.RemoveTargetModel(models, labels)
end)

reg('AddGlobalPlayer', function(options, distance)
    if type(Bridge.Client.AddGlobalPlayer) ~= 'function' then return end
    Bridge.Client.AddGlobalPlayer(options, distance)
end)

reg('RemoveGlobalPlayer', function(labels)
    if type(Bridge.Client.RemoveGlobalPlayer) ~= 'function' then return end
    Bridge.Client.RemoveGlobalPlayer(labels)
end)

reg('AddGlobalPed', function(options, distance)
    if type(Bridge.Client.AddGlobalPed) ~= 'function' then return end
    Bridge.Client.AddGlobalPed(options, distance)
end)

reg('RemoveGlobalPed', function(labels)
    if type(Bridge.Client.RemoveGlobalPed) ~= 'function' then return end
    Bridge.Client.RemoveGlobalPed(labels)
end)

reg('AddGlobalVehicle', function(options, distance)
    if type(Bridge.Client.AddGlobalVehicle) ~= 'function' then return end
    Bridge.Client.AddGlobalVehicle(options, distance)
end)

reg('RemoveGlobalVehicle', function(labels)
    if type(Bridge.Client.RemoveGlobalVehicle) ~= 'function' then return end
    Bridge.Client.RemoveGlobalVehicle(labels)
end)

reg('AddGlobalObject', function(options, distance)
    if type(Bridge.Client.AddGlobalObject) ~= 'function' then return end
    Bridge.Client.AddGlobalObject(options, distance)
end)

reg('RemoveGlobalObject', function(labels)
    if type(Bridge.Client.RemoveGlobalObject) ~= 'function' then return end
    Bridge.Client.RemoveGlobalObject(labels)
end)

print('^2[tac_bridge] client exports registered (OAL)^0')
