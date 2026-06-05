--[[
    tac_bridge — client/target.lua

    Unified target bridge for ox_target and qb-target.

    ─────────────────────────────────────────────────────────────────────
    UNIFIED OPTION FORMAT  (pass these to every Bridge.Client.Target.* call)
    ─────────────────────────────────────────────────────────────────────
    {
        name       = 'unique_id',   -- required; used for removal
        label      = 'Do Thing',
        icon       = 'fa-solid fa-hand',
        distance   = 2.0,
        onSelect   = function(data) end,   -- callback when selected
        canInteract = function(entity, distance, coords, name, bone)
                          return true
                      end,
        groups     = { police = 0, ambulance = 2 }, -- job requirements
        items      = { 'lockpick' },                -- item requirements
    }

    ZONE DATA FORMAT  (addBoxZone / addSphereZone / addPolyZone)
    {
        name     = 'zone_name',
        coords   = vector3(x, y, z),
        -- box only:
        size     = vector3(width, length, height),
        heading  = 0.0,
        -- sphere only:
        radius   = 2.0,
        -- poly only:
        points   = { vector3(...), ... },
        -- common:
        options  = { { ... } },  -- unified option format above
        distance = 2.5,
        debug    = false,
        minZ     = nil,   -- optional z-floor override (qb-target)
        maxZ     = nil,   -- optional z-ceiling override (qb-target)
    }

    SUPPORTED RESOURCES  (auto-detected, or set Bridge.Config.Target)
      ox_target  — github.com/overextended/ox_target
      qb-target  — github.com/qbcore-framework/qb-target
    ─────────────────────────────────────────────────────────────────────
]]

Bridge        = Bridge        or {}
Bridge.Client = Bridge.Client or {}

local mods = Bridge.Modules or {}

-- ─────────────────────────────────────────────
-- Internal: convert unified options → qb-target format
-- ─────────────────────────────────────────────
local function toQBOpt(opt)
    local job = nil
    if opt.groups then
        local list = {}
        for name in pairs(opt.groups) do list[#list+1] = name end
        job = #list == 1 and list[1] or (#list > 0 and list or nil)
    end
    local item = nil
    if opt.items then
        item = type(opt.items) == 'table' and opt.items[1] or opt.items
    end
    return {
        label       = opt.label or opt.name or 'Interact',
        icon        = opt.icon or 'fas fa-hand-paper',
        action      = opt.onSelect or opt.action,
        canInteract = opt.canInteract,
        job         = job,
        item        = item,
        distance    = opt.distance,
    }
end

local function toQBOpts(options)
    local result = {}
    for i, opt in ipairs(options) do result[i] = toQBOpt(opt) end
    return result
end

-- Wrap qb-target targetoptions table
local function qbTargetOpts(options, distance)
    return { distance = distance or 2.5, options = toQBOpts(options) }
end

-- ─────────────────────────────────────────────
-- AddBoxZone(data)
--   data: { name, coords, size(vec3), heading, options, distance, debug, minZ, maxZ }
-- ─────────────────────────────────────────────
function Bridge.Client.AddBoxZone(data)
    if not mods.Target or not data then return end
    local opts = data.options or {}
    local dist = data.distance or 2.5

    if mods.Target == 'ox_target' then
        return exports.ox_target:addBoxZone({
            name     = data.name,
            coords   = data.coords,
            size     = data.size or vec3(1, 1, 1),
            rotation = data.heading or 0.0,
            debug    = data.debug or false,
            options  = opts,
        })

    elseif mods.Target == 'qb-target' then
        local sz   = data.size or vec3(1, 1, 1)
        local z    = data.coords and data.coords.z or 0
        local minZ = data.minZ or (z - sz.z / 2)
        local maxZ = data.maxZ or (z + sz.z / 2)
        exports['qb-target']:AddBoxZone(
            data.name,
            data.coords,
            sz.y, sz.x,  -- qb-target: length (Y), width (X)
            { heading = data.heading or 0.0, debugPoly = data.debug or false, minZ = minZ, maxZ = maxZ },
            qbTargetOpts(opts, dist)
        )
    end
end

-- ─────────────────────────────────────────────
-- AddSphereZone(data)
--   data: { name, coords, radius, options, distance, debug }
-- ─────────────────────────────────────────────
function Bridge.Client.AddSphereZone(data)
    if not mods.Target or not data then return end
    local opts = data.options or {}
    local dist = data.distance or 2.5

    if mods.Target == 'ox_target' then
        return exports.ox_target:addSphereZone({
            name    = data.name,
            coords  = data.coords,
            radius  = data.radius or 1.0,
            debug   = data.debug or false,
            options = opts,
        })

    elseif mods.Target == 'qb-target' then
        exports['qb-target']:AddCircleZone(
            data.name,
            data.coords,
            data.radius or 1.0,
            { debugPoly = data.debug or false },
            qbTargetOpts(opts, dist)
        )
    end
end

-- ─────────────────────────────────────────────
-- AddPolyZone(data)
--   data: { name, points, options, distance, debug, minZ, maxZ }
-- ─────────────────────────────────────────────
function Bridge.Client.AddPolyZone(data)
    if not mods.Target or not data then return end
    local opts = data.options or {}
    local dist = data.distance or 2.5

    if mods.Target == 'ox_target' then
        return exports.ox_target:addPolyZone({
            name    = data.name,
            points  = data.points,
            debug   = data.debug or false,
            options = opts,
        })

    elseif mods.Target == 'qb-target' then
        exports['qb-target']:AddPolyZone(
            data.name,
            data.points,
            { debugPoly = data.debug or false, minZ = data.minZ, maxZ = data.maxZ },
            qbTargetOpts(opts, dist)
        )
    end
end

-- ─────────────────────────────────────────────
-- RemoveZone(name)
-- ─────────────────────────────────────────────
function Bridge.Client.RemoveZone(name)
    if not mods.Target or not name then return end
    if mods.Target == 'ox_target' then
        exports.ox_target:removeZone(name)
    elseif mods.Target == 'qb-target' then
        exports['qb-target']:RemoveZone(name)
    end
end

-- ─────────────────────────────────────────────
-- AddTargetEntity(entities, options, distance)
--   entities: number | number[]  (net IDs for ox_target, handles for qb-target)
-- ─────────────────────────────────────────────
function Bridge.Client.AddTargetEntity(entities, options, distance)
    if not mods.Target then return end
    if type(entities) ~= 'table' then entities = { entities } end

    if mods.Target == 'ox_target' then
        exports.ox_target:addEntity(entities, options)

    elseif mods.Target == 'qb-target' then
        exports['qb-target']:AddTargetEntity(entities, qbTargetOpts(options, distance))
    end
end

-- ─────────────────────────────────────────────
-- RemoveTargetEntity(entities, labels)
--   labels: option name(s) to remove (nil = remove all)
-- ─────────────────────────────────────────────
function Bridge.Client.RemoveTargetEntity(entities, labels)
    if not mods.Target then return end
    if type(entities) ~= 'table' then entities = { entities } end

    if mods.Target == 'ox_target' then
        exports.ox_target:removeEntity(entities, labels)
    elseif mods.Target == 'qb-target' then
        exports['qb-target']:RemoveTargetEntity(entities, labels)
    end
end

-- ─────────────────────────────────────────────
-- AddLocalEntity(entities, options, distance)
--   entities: entity handle(s)
-- ─────────────────────────────────────────────
function Bridge.Client.AddLocalEntity(entities, options, distance)
    if not mods.Target then return end
    if type(entities) ~= 'table' then entities = { entities } end

    if mods.Target == 'ox_target' then
        exports.ox_target:addLocalEntity(entities, options)

    elseif mods.Target == 'qb-target' then
        -- qb-target AddEntityZone per entity
        for _, entity in ipairs(entities) do
            exports['qb-target']:AddEntityZone(
                'local_entity_' .. entity,
                entity,
                { debugPoly = false },
                qbTargetOpts(options, distance)
            )
        end
    end
end

-- ─────────────────────────────────────────────
-- RemoveLocalEntity(entities, labels)
-- ─────────────────────────────────────────────
function Bridge.Client.RemoveLocalEntity(entities, labels)
    if not mods.Target then return end
    if type(entities) ~= 'table' then entities = { entities } end

    if mods.Target == 'ox_target' then
        exports.ox_target:removeLocalEntity(entities, labels)
    elseif mods.Target == 'qb-target' then
        for _, entity in ipairs(entities) do
            exports['qb-target']:RemoveZone('local_entity_' .. entity)
        end
    end
end

-- ─────────────────────────────────────────────
-- AddTargetModel(models, options, distance)
--   models: model name(s) or hash(es)
-- ─────────────────────────────────────────────
function Bridge.Client.AddTargetModel(models, options, distance)
    if not mods.Target then return end
    if type(models) ~= 'table' then models = { models } end

    if mods.Target == 'ox_target' then
        exports.ox_target:addModel(models, options)

    elseif mods.Target == 'qb-target' then
        exports['qb-target']:AddTargetModel(models, qbTargetOpts(options, distance))
    end
end

-- ─────────────────────────────────────────────
-- RemoveTargetModel(models, labels)
-- ─────────────────────────────────────────────
function Bridge.Client.RemoveTargetModel(models, labels)
    if not mods.Target then return end
    if type(models) ~= 'table' then models = { models } end

    if mods.Target == 'ox_target' then
        exports.ox_target:removeModel(models, labels)
    elseif mods.Target == 'qb-target' then
        exports['qb-target']:RemoveTargetModel(models, labels)
    end
end

-- ─────────────────────────────────────────────
-- Global types
-- ─────────────────────────────────────────────
local function addGlobal(fn_ox, fn_qb, options, distance)
    if not mods.Target then return end
    if mods.Target == 'ox_target' then
        fn_ox(options)
    elseif mods.Target == 'qb-target' then
        fn_qb(qbTargetOpts(options, distance))
    end
end

local function removeGlobal(fn_ox, fn_qb, labels)
    if not mods.Target then return end
    if mods.Target == 'ox_target' then fn_ox(labels)
    elseif mods.Target == 'qb-target' then fn_qb(labels) end
end

function Bridge.Client.AddGlobalPlayer(options, distance)
    addGlobal(
        function(o) exports.ox_target:addGlobalPlayer(o) end,
        function(o) exports['qb-target']:AddGlobalPlayer(o) end,
        options, distance
    )
end

function Bridge.Client.RemoveGlobalPlayer(labels)
    removeGlobal(
        function(l) exports.ox_target:removeGlobalPlayer(l) end,
        function(l) exports['qb-target']:RemoveGlobalPlayer(l) end,
        labels
    )
end

function Bridge.Client.AddGlobalPed(options, distance)
    addGlobal(
        function(o) exports.ox_target:addGlobalPed(o) end,
        function(o) exports['qb-target']:AddGlobalPed(o) end,
        options, distance
    )
end

function Bridge.Client.RemoveGlobalPed(labels)
    removeGlobal(
        function(l) exports.ox_target:removeGlobalPed(l) end,
        function(l) exports['qb-target']:RemoveGlobalPed(l) end,
        labels
    )
end

function Bridge.Client.AddGlobalVehicle(options, distance)
    addGlobal(
        function(o) exports.ox_target:addGlobalVehicle(o) end,
        function(o) exports['qb-target']:AddGlobalVehicle(o) end,
        options, distance
    )
end

function Bridge.Client.RemoveGlobalVehicle(labels)
    removeGlobal(
        function(l) exports.ox_target:removeGlobalVehicle(l) end,
        function(l) exports['qb-target']:RemoveGlobalVehicle(l) end,
        labels
    )
end

function Bridge.Client.AddGlobalObject(options, distance)
    addGlobal(
        function(o) exports.ox_target:addGlobalObject(o) end,
        function(o) exports['qb-target']:AddGlobalObject(o) end,
        options, distance
    )
end

function Bridge.Client.RemoveGlobalObject(labels)
    removeGlobal(
        function(l) exports.ox_target:removeGlobalObject(l) end,
        function(l) exports['qb-target']:RemoveGlobalObject(l) end,
        labels
    )
end

-- ─────────────────────────────────────────────
-- HasTarget() → bool  (is any target resource running?)
-- ─────────────────────────────────────────────
function Bridge.Client.HasTarget()
    return mods.Target ~= false and mods.Target ~= nil
end
