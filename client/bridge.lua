--[[
    tac_bridge — client/bridge.lua

    Unified client-side API verified against real framework source code.

    ┌──────────────────────────────────────────────────────────────────┐
    │  Bridge.Client.GetPlayerData()  → table                          │
    │  Bridge.Client.GetIdentifier()  → string                         │
    │  Bridge.Client.GetName()        → string                         │
    │  Bridge.Client.GetJob()         → { name, label, grade, ... }    │
    │  Bridge.Client.GetGang()        → { name, label, grade, ... }    │
    │  Bridge.Client.GetMoney(acct)   → number                         │
    │  Bridge.Client.HasItem(item)    → bool                           │
    │  Bridge.Client.Notify(msg,type,dur)                               │
    │  Bridge.Client.Progress(opts, cb)                                │
    │  Bridge.Client.TriggerCallback(name, cb, ...)                    │
    │  Bridge.Client.RegisterCallback(name, handler)                   │
    │  Bridge.Client.IsPlayerLoaded() → bool                           │
    │  Bridge.Client.OnPlayerUpdated(key, value)   — hookable          │
    │  Bridge.Client.OnMoneyChange(acct, amt, action, reason) — hook   │
    └──────────────────────────────────────────────────────────────────┘

    Mythic client notes:
      • No GetPlayerData() equivalent in mythic-base.
      • Character data is synced via "Characters:Client:SetData" events.
      • Bridge maintains a local _mythicChar table updated by those events.
      • Money/jobs live in separate mythic-* component resources.
      • Override Bridge.Client functions for your server's Mythic setup.

    ox_core notes:
      • ox_core is archived (Apr 2025); esx-framework maintains a fork.
      • Client player data fetched via exports.ox_core:GetPlayerData().
      • Uses ox_lib for notifications and callbacks.
]]

Bridge        = Bridge or {}
Bridge.Client = Bridge.Client or {}

local fw  = Bridge.Framework
local cfg = Bridge.Config

-- ─────────────────────────────────────────────
-- Internal: lazy core object
-- ─────────────────────────────────────────────
local _core = nil
local function getCore()
    if _core then return _core end
    if fw == 'qbx' then
        _core = exports.qbx_core:GetCoreObject()
    elseif fw == 'qb' then
        _core = exports['qb-core']:GetCoreObject()
    elseif fw == 'esx' then
        local ok = pcall(function() _core = exports['es_extended']:getSharedObject() end)
        if not ok then TriggerEvent(cfg.ESXEvent, function(obj) _core = obj end) end
    elseif fw == 'ox' or fw == 'nd' or fw == 'mythic' then
        _core = true
    end
    return _core
end

-- ─────────────────────────────────────────────
-- Mythic: local character state (synced via DataStore events)
-- ─────────────────────────────────────────────
local _mythicChar = {}
if fw == 'mythic' then
    RegisterNetEvent('Characters:Client:SetData')
    AddEventHandler('Characters:Client:SetData', function(key, value)
        _mythicChar[key] = value
        Bridge.Client.OnPlayerUpdated(key, value)
    end)
    RegisterNetEvent('Player:Client:SetData')
    AddEventHandler('Player:Client:SetData', function(data)
        if type(data) == 'table' then
            for k, v in pairs(data) do _mythicChar[k] = v end
        end
        Bridge.Client.OnPlayerUpdated('all', data)
    end)
end

-- ─────────────────────────────────────────────
-- GetPlayerData
-- ─────────────────────────────────────────────
function Bridge.Client.GetPlayerData()
    getCore()
    if fw == 'qbx' or fw == 'qb' then
        return _core.Functions.GetPlayerData()
    elseif fw == 'esx' then
        return _core.GetPlayerData()
    elseif fw == 'ox' then
        return exports.ox_core:GetPlayerData() or {}
    elseif fw == 'nd' then
        return NDCore.player or {}
    elseif fw == 'mythic' then
        return _mythicChar
    end
    return {}
end

-- ─────────────────────────────────────────────
-- GetIdentifier
-- ─────────────────────────────────────────────
function Bridge.Client.GetIdentifier()
    local pd = Bridge.Client.GetPlayerData()
    if fw == 'qbx' or fw == 'qb' then
        return pd.citizenid
    elseif fw == 'esx' then
        return pd.identifier
    elseif fw == 'ox' then
        return pd.stateId or pd.identifier
    elseif fw == 'nd' then
        return pd.identifier
    elseif fw == 'mythic' then
        return _mythicChar.AccountID
    end
    return nil
end

-- ─────────────────────────────────────────────
-- GetName
-- ─────────────────────────────────────────────
function Bridge.Client.GetName()
    local pd = Bridge.Client.GetPlayerData()
    if fw == 'qbx' or fw == 'qb' then
        local ci = pd.charinfo
        return ci and ((ci.firstname or '') .. ' ' .. (ci.lastname or '')) or 'Unknown'
    elseif fw == 'esx' then
        return (pd.firstName or '') .. ' ' .. (pd.lastName or '')
    elseif fw == 'ox' then
        return ((pd.firstname or '') .. ' ' .. (pd.lastname or '')):gsub('^%s+$', 'Unknown')
    elseif fw == 'nd' then
        return pd.fullname or ((pd.firstname or '') .. ' ' .. (pd.lastname or ''))
    elseif fw == 'mythic' then
        return ((_mythicChar.First or '') .. ' ' .. (_mythicChar.Last or ''))
    end
    return 'Unknown'
end

-- ─────────────────────────────────────────────
-- GetJob → { name, label, grade, gradeLabel, onDuty, isBoss }
-- ox_core: groups-based, getGroupByType not available client-side directly
-- Mythic: no built-in job — returns stub
-- ─────────────────────────────────────────────
function Bridge.Client.GetJob()
    local pd = Bridge.Client.GetPlayerData()
    if fw == 'qbx' or fw == 'qb' then
        local j = pd.job or {}
        return { name = j.name, label = j.label, grade = j.grade and j.grade.level, gradeLabel = j.grade and j.grade.name, onDuty = j.onduty, isBoss = j.isboss }
    elseif fw == 'esx' then
        local j = pd.job or {}
        return { name = j.name, label = j.label, grade = j.grade, gradeLabel = j.grade_label, onDuty = true }
    elseif fw == 'ox' then
        -- ox_core client: player groups stored in pd.groups table
        if pd.groups then
            for name, grade in pairs(pd.groups) do
                -- ox_core doesn't expose type on client by default; check grade ~= false
                -- Override this if your server distinguishes job vs gang groups
                return { name = name, label = name, grade = grade, gradeLabel = tostring(grade), onDuty = true }
            end
        end
        return { name = 'unemployed', label = 'Unemployed', grade = 0, onDuty = false }
    elseif fw == 'nd' then
        local j = pd.jobInfo or {}
        return { name = j.name or pd.job, label = j.label or pd.job, grade = j.rank, gradeLabel = j.rankName, onDuty = true, isBoss = j.isBoss }
    elseif fw == 'mythic' then
        return { name = 'unknown', label = 'Unknown', grade = 0, onDuty = false }
    end
    return {}
end

-- ─────────────────────────────────────────────
-- GetGang
-- ─────────────────────────────────────────────
function Bridge.Client.GetGang()
    local pd = Bridge.Client.GetPlayerData()
    if fw == 'qbx' or fw == 'qb' then
        local g = pd.gang or {}
        return { name = g.name, label = g.label, grade = g.grade and g.grade.level, gradeLabel = g.grade and g.grade.name }
    elseif fw == 'esx' then
        return { name = 'none', label = 'None', grade = 0, gradeLabel = 'None' }
    elseif fw == 'ox' or fw == 'mythic' then
        return { name = 'none', label = 'None', grade = 0, gradeLabel = 'None' }
    elseif fw == 'nd' then
        if pd.groups then
            for _, g in pairs(pd.groups) do
                if not g.isJob then return { name = g.name, label = g.label, grade = g.rank, gradeLabel = g.rankName } end
            end
        end
        return { name = 'none', label = 'None', grade = 0, gradeLabel = 'None' }
    end
    return {}
end

-- ─────────────────────────────────────────────
-- GetMoney(account)  account: 'cash'|'bank'|'black'
-- ─────────────────────────────────────────────
function Bridge.Client.GetMoney(account)
    account = account or 'cash'
    local pd = Bridge.Client.GetPlayerData()

    if fw == 'qbx' or fw == 'qb' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].qb or account
        return pd.money and pd.money[key] or 0
    elseif fw == 'esx' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].esx or account
        if account == 'cash' then return pd.money or 0 end
        if pd.accounts then
            for _, acc in ipairs(pd.accounts) do
                if acc.name == key then return acc.money end
            end
        end
        return 0
    elseif fw == 'ox' then
        -- ox_core stores account balance in pd.accounts table
        local key = cfg.Accounts[account] and cfg.Accounts[account].ox or account
        if pd.accounts then
            for _, acc in ipairs(pd.accounts) do
                if acc.name == key then return acc.balance or 0 end
            end
        end
        return 0
    elseif fw == 'nd' then
        local key = cfg.Accounts[account] and cfg.Accounts[account].nd or account
        return pd[key] or 0
    elseif fw == 'mythic' then
        -- mythic-base has no built-in money. Key resolved for your override:
        local key = cfg.Accounts[account] and cfg.Accounts[account].mythic or account
        return _mythicChar[key] or 0
    end
    return 0
end

-- ─────────────────────────────────────────────
-- HasItem(item) → bool
-- ─────────────────────────────────────────────
function Bridge.Client.HasItem(item)
    if GetResourceState('ox_inventory') == 'started' then
        return (exports.ox_inventory:GetItemCount(item) or 0) > 0
    end
    if fw == 'qbx' then
        return exports.qbx_core:HasItem(item)
    elseif fw == 'qb' then
        return _core and _core.Functions.HasItem(item) or false
    elseif fw == 'esx' then
        local pd = Bridge.Client.GetPlayerData()
        if pd.inventory then
            for _, v in ipairs(pd.inventory) do
                if v.name == item and v.count > 0 then return true end
            end
        end
        return false
    end
    return false
end

-- ─────────────────────────────────────────────
-- Notify(message, type, duration)
--   type: 'success'|'error'|'info'|'warning'
-- ─────────────────────────────────────────────
function Bridge.Client.Notify(message, notifyType, duration)
    notifyType = notifyType or 'info'
    duration   = duration   or cfg.NotifyDuration

    if GetResourceState('ox_lib') == 'started' then
        lib.notify({ title = message, type = notifyType, duration = duration })
        return
    end

    if fw == 'qbx' then
        exports.qbx_core:Notify(message, notifyType, duration)
    elseif fw == 'qb' then
        _core.Functions.Notify(message, notifyType == 'info' and 'primary' or notifyType, duration)
    elseif fw == 'esx' then
        _core.ShowNotification(message, notifyType, duration)
    elseif fw == 'mythic' then
        -- Mythic: trigger via component system
        TriggerEvent('Core:Client:Notify', { message = message, type = notifyType, duration = duration })
    end
end

-- ─────────────────────────────────────────────
-- Progress(opts, callback)
-- ─────────────────────────────────────────────
function Bridge.Client.Progress(opts, callback)
    opts     = opts     or {}
    callback = callback or function() end
    local label    = opts.label    or 'Working...'
    local duration = opts.duration or cfg.ProgressDuration

    if GetResourceState('ox_lib') == 'started' then
        local done = lib.progressBar({
            duration     = duration,
            label        = label,
            useWhileDead = opts.useWhileDead or false,
            canCancel    = opts.canCancel    ~= false,
            disable      = { move = opts.disableMovement or false, car = opts.disableMovement or false, combat = opts.disableCombat ~= false },
            anim = opts.anim and { dict = opts.anim.dict, clip = opts.anim.clip, flag = opts.anim.flag or 49 } or nil,
            prop = opts.prop,
        })
        callback(done)
        return
    end

    if fw == 'qbx' or fw == 'qb' then
        exports['qb-progressbar']:Progress({
            name               = label:lower():gsub('%s', '_'),
            duration           = duration,
            label              = label,
            useWhileDead       = opts.useWhileDead  or false,
            canCancel          = opts.canCancel      ~= false,
            disableMovement    = opts.disableMovement or false,
            disableCarMovement = opts.disableMovement or false,
            disableMouse       = false,
            disableCombat      = opts.disableCombat  ~= false,
            animDict           = opts.anim and opts.anim.dict or nil,
            anim               = opts.anim and opts.anim.clip or nil,
            animFlag           = opts.anim and opts.anim.flag or 49,
        }, function(cancelled) callback(not cancelled) end)
    elseif fw == 'esx' then
        _core.Progressbar(label:gsub('%s', '_'), label, duration,
            opts.useWhileDead or false, opts.canCancel ~= false,
            { disableMovement = opts.disableMovement or false, disableCarMovement = false, disableMouse = false, disableCombat = opts.disableCombat ~= false },
            opts.anim and { animDict = opts.anim.dict, anim = opts.anim.clip, flags = opts.anim.flag or 49 } or {},
            {}, {},
            function() callback(true) end,
            function() callback(false) end
        )
    end
end

-- ─────────────────────────────────────────────
-- TriggerCallback(name, callback, ...)
-- Mythic client confirmed: COMPONENTS.Callbacks:ServerCallback(event, data, cb)
-- ─────────────────────────────────────────────
function Bridge.Client.TriggerCallback(name, callback, ...)
    local args = { ... }
    if fw == 'qbx' or fw == 'nd' or fw == 'ox' then
        lib.callback(name, false, callback, table.unpack(args))
    elseif fw == 'qb' then
        getCore().Functions.TriggerCallback(name, callback, table.unpack(args))
    elseif fw == 'esx' then
        getCore().TriggerServerCallback(name, callback, table.unpack(args))
    elseif fw == 'mythic' then
        if COMPONENTS and COMPONENTS.Callbacks then
            COMPONENTS.Callbacks:ServerCallback(name, args[1] or {}, callback)
        end
    end
end

-- ─────────────────────────────────────────────
-- RegisterCallback(name, handler)
-- Mythic: COMPONENTS.Callbacks:RegisterClientCallback(event, cb)
-- ─────────────────────────────────────────────
function Bridge.Client.RegisterCallback(name, handler)
    if fw == 'qbx' or fw == 'nd' or fw == 'ox' then
        lib.callback.register(name, handler)
    elseif fw == 'qb' then
        getCore().Functions.CreateClientCallback(name, handler)
    elseif fw == 'mythic' then
        if COMPONENTS and COMPONENTS.Callbacks then
            COMPONENTS.Callbacks:RegisterClientCallback(name, handler)
        end
    end
end

-- ─────────────────────────────────────────────
-- IsPlayerLoaded()
-- ─────────────────────────────────────────────
function Bridge.Client.IsPlayerLoaded()
    if fw == 'qbx' then
        return LocalPlayer.state.isLoggedIn
    elseif fw == 'qb' then
        return getCore() and _core.Functions.GetPlayerData().citizenid ~= nil or false
    elseif fw == 'esx' then
        local pd = getCore() and _core.GetPlayerData()
        return pd and pd.identifier ~= nil or false
    elseif fw == 'ox' then
        local pd = exports.ox_core:GetPlayerData()
        return pd ~= nil and pd.charId ~= nil
    elseif fw == 'nd' then
        return NDCore.player ~= nil
    elseif fw == 'mythic' then
        return _mythicChar.AccountID ~= nil
    end
    return false
end

-- ─────────────────────────────────────────────
-- OnPlayerUpdated hook
--   Override in your resource.
--   QB/QBX keys: 'job'|'gang'|'money'|'metadata'|'all'
--   ND keys:     'job'|'groups'|'metadata'|'all'
--   Mythic:      any key passed from DataStore SetData
--   ox_core:     fires on 'ox:playerLoaded' / 'ox:setGroup' etc.
-- ─────────────────────────────────────────────
Bridge.Client.OnPlayerUpdated = Bridge.Client.OnPlayerUpdated or function(key, value) end

if fw == 'qb' or fw == 'qbx' then
    AddEventHandler('QBCore:Client:OnPlayerUpdated', function(key, value)
        Bridge.Client.OnPlayerUpdated(key, value)
    end)
end

if fw == 'nd' then
    AddEventHandler('ND:updateCharacter', function(character, key)
        if source == '' then return end
        Bridge.Client.OnPlayerUpdated(key or 'all', character)
    end)
    AddEventHandler('ND:updateMoney', function(cash, bank)
        if source == '' then return end
        Bridge.Client.OnPlayerUpdated('money', { cash = cash, bank = bank })
    end)
    AddEventHandler('ND:characterLoaded', function(character)
        if source == '' then return end
        Bridge.Client.OnPlayerUpdated('all', character)
    end)
end

if fw == 'ox' then
    -- ox_core fires 'ox:playerLoaded' when character is ready
    AddEventHandler('ox:playerLoaded', function(data)
        Bridge.Client.OnPlayerUpdated('all', data)
    end)
    AddEventHandler('ox:setGroup', function(name, grade)
        Bridge.Client.OnPlayerUpdated('job', { name = name, grade = grade })
    end)
end

-- ─────────────────────────────────────────────
-- OnMoneyChange hook  (QB/QBX: QBCore:Client:OnMoneyChange confirmed in source)
--   Override in your resource:
--     Bridge.Client.OnMoneyChange = function(account, amount, action, reason) ... end
--   action: 'add'|'remove'|'set'
-- ─────────────────────────────────────────────
Bridge.Client.OnMoneyChange = Bridge.Client.OnMoneyChange or function(account, amount, action, reason) end

if fw == 'qb' or fw == 'qbx' then
    AddEventHandler('QBCore:Client:OnMoneyChange', function(account, amount, action, reason)
        Bridge.Client.OnMoneyChange(account, amount, action, reason)
    end)
end
